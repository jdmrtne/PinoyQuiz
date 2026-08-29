import { BrowserRouter, Routes, Route } from "react-router-dom";
import Home from "./pages/Home";
import CreateGame from "./pages/CreateGame";
import JoinGame from "./pages/JoinGame";
import GameRoom from "./pages/GameRoom";
import Results from "./pages/Results";
import { ThemeProvider } from "./hooks/useTheme";
import { ThemeToggle } from "./components/ui/ThemeToggle";

export default function App() {
  return (
    <ThemeProvider>
      <BrowserRouter>
        {/* No shared header/nav shell exists (each page owns its own
            layout), so the toggle is rendered once here, fixed to the
            viewport, so it's reachable from every screen. Respects the
            same safe-area insets as body's own padding. */}
        <div
          className="fixed z-50 top-3 right-3"
          style={{
            top: "calc(env(safe-area-inset-top, 0px) + 0.75rem)",
            right: "calc(env(safe-area-inset-right, 0px) + 0.75rem)",
          }}
        >
          <ThemeToggle />
        </div>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/create" element={<CreateGame />} />
          <Route path="/join" element={<JoinGame />} />
          {/* Invite links land here with the room code pre-filled (Phase 3) */}
          <Route path="/join/:roomCode" element={<JoinGame />} />
          <Route path="/game/:roomCode" element={<GameRoom />} />
          <Route path="/results/:roomCode" element={<Results />} />
          <Route path="*" element={<Home />} />
        </Routes>
      </BrowserRouter>
    </ThemeProvider>
  );
}
