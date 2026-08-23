import { useEffect, useState } from "react";
import { useNavigate, useParams, Link } from "react-router-dom";
import { Button } from "../components/ui/Button";
import { Card } from "../components/ui/Card";
import { TextField } from "../components/ui/TextField";
import { joinGame, lookupGame, GameApiError, type RoomLookup } from "../lib/gameApi";
import { categoryDisplayLabel, DIFFICULTY_LABELS } from "../data/gameOptions";

type LookupState =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "ready"; info: RoomLookup }
  | { status: "error"; message: string };

export default function JoinGame() {
  const navigate = useNavigate();
  const { roomCode: roomCodeFromUrl } = useParams();
  const [roomCode, setRoomCode] = useState(roomCodeFromUrl?.toUpperCase() ?? "");
  const [nickname, setNickname] = useState("");
  const [lookup, setLookup] = useState<LookupState>({ status: "idle" });
  const [joinError, setJoinError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  // Pre-filled from an invite link (/join/:roomCode) — validate it right
  // away so a broken link tells the person immediately, before they type a
  // nickname just to find out.
  useEffect(() => {
    if (!roomCodeFromUrl) return;
    let cancelled = false;
    setLookup({ status: "loading" });
    lookupGame(roomCodeFromUrl)
      .then((info) => {
        if (cancelled) return;
        if (!info.found) {
          setLookup({ status: "error", message: "This invite link doesn't lead anywhere — the room may have ended." });
        } else {
          setLookup({ status: "ready", info });
        }
      })
      .catch((err) => {
        if (cancelled) return;
        setLookup({
          status: "error",
          message: err instanceof GameApiError ? err.message : "Couldn't check that room right now.",
        });
      });
    return () => {
      cancelled = true;
    };
  }, [roomCodeFromUrl]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setJoinError(null);

    const code = roomCode.trim().toUpperCase();
    if (code.length !== 6) {
      setJoinError("Room codes are 6 characters.");
      return;
    }
    if (nickname.trim().length < 1) {
      setJoinError("Enter a nickname first.");
      return;
    }

    setSubmitting(true);
    try {
      const result = await joinGame(code, nickname.trim());
      navigate(`/game/${code}`, {
        state: { playerId: result.playerId, isHost: result.isHost },
      });
    } catch (err) {
      setJoinError(
        err instanceof GameApiError ? err.message : "Couldn't join that room. Please try again."
      );
      setSubmitting(false);
    }
  }

  return (
    <div className="min-h-dvh px-5 py-10 flex flex-col items-center">
      <div className="w-full max-w-md">
        <Link to="/" className="text-sm text-sampaguita/50 hover:text-mango">
          ← Back
        </Link>

        <h1 className="text-3xl font-bold mt-3 mb-1">Join Game</h1>
        <p className="text-sampaguita/60 mb-6 text-sm">
          Enter the room code your host shared, then pick a nickname.
        </p>

        {lookup.status === "ready" && (
          <Card className="p-4 mb-4 border-bagoong/40 bg-bagoong/10">
            <p className="text-sm text-sampaguita/90">
              Room found —{" "}
              <span className="font-semibold">
                {categoryDisplayLabel(lookup.info.category!, lookup.info.categories)}
              </span>{" "}
              ·{" "}
              <span className="font-semibold">
                {DIFFICULTY_LABELS[lookup.info.difficulty!]}
              </span>{" "}
              · {lookup.info.questionCount} questions
            </p>
          </Card>
        )}
        {lookup.status === "error" && (
          <Card className="p-4 mb-4 border-sunset/40 bg-sunset/10">
            <p className="text-sm text-sampaguita/90" role="alert">
              {lookup.message}
            </p>
          </Card>
        )}

        <form onSubmit={handleSubmit}>
          <Card className="p-6 flex flex-col gap-6">
            <TextField
              label="Room code"
              placeholder="ABCD12"
              value={roomCode}
              onChange={(e) => setRoomCode(e.target.value.toUpperCase())}
              maxLength={6}
              autoCapitalize="characters"
              className="text-center tracking-[0.3em]"
              autoFocus={!roomCodeFromUrl}
            />

            <TextField
              label="Your nickname"
              placeholder="e.g. Maria"
              maxLength={20}
              value={nickname}
              onChange={(e) => setNickname(e.target.value)}
              autoFocus={!!roomCodeFromUrl}
            />

            {joinError && (
              <p role="alert" className="text-sm text-sunset -mt-2">
                {joinError}
              </p>
            )}

            <Button type="submit" size="lg" variant="secondary" disabled={submitting}>
              {submitting ? "Joining…" : "Join Room"}
            </Button>
          </Card>
        </form>
      </div>
    </div>
  );
}
