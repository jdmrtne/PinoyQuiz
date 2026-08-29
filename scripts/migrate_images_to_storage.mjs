// scripts/migrate_images_to_storage.mjs
//
// One-time migration: finds every "image" type question whose image_url
// points at an external host (Wikimedia, etc.), downloads the image,
// re-uploads it into a Supabase Storage bucket you control, and rewrites
// the row's image_url to point at that stable, self-hosted copy.
//
// Why: hotlinked URLs (esp. Wikimedia "thumb" derivatives) can go dead
// when the source file is renamed/deleted upstream — that's what broke
// the Mayon Volcano question. Once an image lives in your own bucket,
// nothing outside your control can break it.
//
// Usage:
//   1. In the Supabase dashboard: Project Settings > API > copy the
//      "service_role" key (NOT the anon key — this script needs elevated
//      access to write to Storage and bypass RLS on the questions table).
//   2. Run:
//        SUPABASE_URL=https://your-project-ref.supabase.co \
//        SUPABASE_SERVICE_ROLE_KEY=your-service-role-key \
//        node scripts/migrate_images_to_storage.mjs
//
//      (Or copy .env.local, add SUPABASE_SERVICE_ROLE_KEY to it, and
//      `node --env-file=.env.local scripts/migrate_images_to_storage.mjs`.)
//   3. Never commit the service_role key or use it in frontend code.
//
// Flags:
//   --dry-run   Show what would happen without uploading or writing to
//               the database.
//   --bucket=NAME   Override the storage bucket name (default: below).

import { createClient } from "@supabase/supabase-js";

const BUCKET_NAME =
  process.argv.find((a) => a.startsWith("--bucket="))?.split("=")[1] ??
  "question-images";
const DRY_RUN = process.argv.includes("--dry-run");

const SUPABASE_URL = process.env.SUPABASE_URL ?? process.env.VITE_SUPABASE_URL;
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
  console.error(
    "Missing env vars. Set SUPABASE_URL (or VITE_SUPABASE_URL) and " +
      "SUPABASE_SERVICE_ROLE_KEY before running this script."
  );
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});

async function ensureBucketExists() {
  const { data: buckets, error } = await supabase.storage.listBuckets();
  if (error) throw error;

  if (buckets.some((b) => b.name === BUCKET_NAME)) {
    console.log(`Bucket "${BUCKET_NAME}" already exists.`);
    return;
  }

  if (DRY_RUN) {
    console.log(`[dry-run] Would create public bucket "${BUCKET_NAME}".`);
    return;
  }

  const { error: createError } = await supabase.storage.createBucket(
    BUCKET_NAME,
    { public: true }
  );
  if (createError) throw createError;
  console.log(`Created public bucket "${BUCKET_NAME}".`);
}

function extensionFromUrlOrContentType(url, contentType) {
  const fromUrl = url.split("?")[0].split(".").pop();
  if (fromUrl && fromUrl.length <= 5 && /^[a-zA-Z0-9]+$/.test(fromUrl)) {
    return fromUrl.toLowerCase();
  }
  const map = {
    "image/jpeg": "jpg",
    "image/png": "png",
    "image/webp": "webp",
    "image/gif": "gif",
  };
  return map[contentType] ?? "jpg";
}

function slugify(text) {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "")
    .slice(0, 60);
}

async function migrateRow(row) {
  const { id, prompt, image_url: imageUrl } = row;
  const label = `[${id}] "${prompt.slice(0, 60)}${prompt.length > 60 ? "…" : ""}"`;

  // Already pointing at our own bucket — nothing to do.
  if (imageUrl.includes(`/storage/v1/object/public/${BUCKET_NAME}/`)) {
    console.log(`${label}: already self-hosted, skipping.`);
    return { status: "skipped" };
  }

  console.log(`${label}: downloading ${imageUrl}`);
  let response;
  try {
    response = await fetch(imageUrl);
  } catch (err) {
    console.error(`${label}: FAILED to fetch — ${err.message}`);
    return { status: "failed", reason: err.message };
  }

  if (!response.ok) {
    console.error(`${label}: FAILED — HTTP ${response.status}`);
    return { status: "failed", reason: `HTTP ${response.status}` };
  }

  const contentType = response.headers.get("content-type") ?? "image/jpeg";
  const bytes = new Uint8Array(await response.arrayBuffer());
  const ext = extensionFromUrlOrContentType(imageUrl, contentType);
  const path = `${slugify(prompt)}-${id.slice(0, 8)}.${ext}`;

  if (DRY_RUN) {
    console.log(
      `${label}: [dry-run] would upload ${bytes.byteLength} bytes to ${BUCKET_NAME}/${path}`
    );
    return { status: "dry-run" };
  }

  const { error: uploadError } = await supabase.storage
    .from(BUCKET_NAME)
    .upload(path, bytes, { contentType, upsert: true });

  if (uploadError) {
    console.error(`${label}: FAILED to upload — ${uploadError.message}`);
    return { status: "failed", reason: uploadError.message };
  }

  const {
    data: { publicUrl },
  } = supabase.storage.from(BUCKET_NAME).getPublicUrl(path);

  const { error: updateError } = await supabase
    .from("questions")
    .update({ image_url: publicUrl })
    .eq("id", id);

  if (updateError) {
    console.error(`${label}: FAILED to update row — ${updateError.message}`);
    return { status: "failed", reason: updateError.message };
  }

  console.log(`${label}: done -> ${publicUrl}`);
  return { status: "migrated", publicUrl };
}

async function main() {
  console.log(
    `Migrating question images into bucket "${BUCKET_NAME}"${DRY_RUN ? " (dry run)" : ""}...\n`
  );

  await ensureBucketExists();

  const { data: rows, error } = await supabase
    .from("questions")
    .select("id, prompt, image_url")
    .eq("question_type", "image")
    .not("image_url", "is", null);

  if (error) throw error;

  console.log(`Found ${rows.length} image question(s).\n`);

  const results = [];
  for (const row of rows) {
    results.push(await migrateRow(row));
  }

  const counts = results.reduce((acc, r) => {
    acc[r.status] = (acc[r.status] ?? 0) + 1;
    return acc;
  }, {});

  console.log("\nSummary:", counts);
  if (counts.failed) {
    console.log(
      "\nSome images failed to migrate (likely dead source URLs). " +
        "Replace those manually with a working source image and re-run."
    );
    process.exitCode = 1;
  }
}

main().catch((err) => {
  console.error("Migration failed:", err);
  process.exit(1);
});
