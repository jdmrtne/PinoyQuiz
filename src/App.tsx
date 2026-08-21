import { BrowserRouter, Routes, Route } from "react-router-dom";
import Home from "./pages/Home";
import CreateGame from "./pages/CreateGame";
import JoinGame from "./pages/JoinGame";
import GameRoom from "./pages/GameRoom";
import Results from "./pages/Results";

export default function App() {
  return (
    <BrowserRouter>
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
  );
}
