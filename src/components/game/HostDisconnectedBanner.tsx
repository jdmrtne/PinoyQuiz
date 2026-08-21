import { Card } from "../ui/Card";
import { Button } from "../ui/Button";

/**
 * Phase 8: shown to every non-host player once the host's own `connected`
 * flag has gone false (via the heartbeat/staleness sweep — see
 * useHeartbeat.ts). Lets any of them call claim_host, which
 * deterministically reassigns hosting to the earliest-joined still-
 * connected player — not necessarily whoever clicks this button, so it's
 * worded as "let someone take over" rather than "become host" to avoid
 * implying the clicker is guaranteed to end up hosting.
 */
export function HostDisconnectedBanner({
  onClaim,
  claiming,
}: {
  onClaim: () => void;
  claiming: boolean;
}) {
  return (
    <Card className="p-4 mb-4 border-sunset/40 bg-sunset/10 flex items-center justify-between gap-3 flex-wrap">
      <p className="text-sm text-sampaguita/90">
        The host seems to have disconnected.
      </p>
      <Button size="md" variant="secondary" onClick={onClaim} disabled={claiming}>
        {claiming ? "Taking over…" : "Take over as host"}
      </Button>
    </Card>
  );
}
