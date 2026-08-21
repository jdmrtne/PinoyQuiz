import { useState } from "react";
import { Card } from "../ui/Card";
import { Button } from "../ui/Button";

export function InviteBox({ roomCode }: { roomCode: string }) {
  const [codeCopied, setCodeCopied] = useState(false);
  const [linkCopied, setLinkCopied] = useState(false);
  const inviteLink = `${window.location.origin}/join/${roomCode}`;

  async function copy(text: string, mark: (v: boolean) => void) {
    try {
      await navigator.clipboard.writeText(text);
      mark(true);
      setTimeout(() => mark(false), 1800);
    } catch {
      // Clipboard API can be blocked (permissions, non-secure context). The
      // text is still visible/selectable, so this is a soft failure.
    }
  }

  return (
    <Card className="p-6 flex flex-col gap-5">
      <div>
        <p className="text-xs font-semibold uppercase tracking-wide text-sampaguita/50 mb-2">
          Game code
        </p>
        <div className="flex items-center gap-3">
          <span className="font-display text-4xl font-bold tracking-[0.25em] text-mango">
            {roomCode}
          </span>
          <Button
            type="button"
            size="md"
            variant="ghost"
            onClick={() => copy(roomCode, setCodeCopied)}
          >
            {codeCopied ? "Copied!" : "Copy Code"}
          </Button>
        </div>
      </div>

      <div>
        <p className="text-xs font-semibold uppercase tracking-wide text-sampaguita/50 mb-2">
          Invite link
        </p>
        <div className="flex items-center gap-3 flex-wrap">
          <span className="text-sm text-sampaguita/70 break-all">
            {inviteLink}
          </span>
          <Button
            type="button"
            size="md"
            variant="ghost"
            onClick={() => copy(inviteLink, setLinkCopied)}
          >
            {linkCopied ? "Copied!" : "Copy Link"}
          </Button>
        </div>
      </div>
    </Card>
  );
}
