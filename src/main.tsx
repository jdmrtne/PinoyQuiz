import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'
import { calibrateServerClock } from './lib/serverClock'

// Fire-and-forget: estimates the client/server clock offset once up front
// so it's already available by the time the first question timer mounts,
// rather than waiting for GameRoom to trigger it. See serverClock.ts.
calibrateServerClock()

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
