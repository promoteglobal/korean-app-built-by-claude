# Suji (talking practice) — Korean conversation app

Single-file web app: talk with Suji (수지), a warm TOPIK-Level-1 AI Korean
teacher, by voice or text. She keeps the conversation going and corrects you.
(Level dropped 2 → 1 on 2026-08-07 at the user's request — the SYSTEM prompt
in `index.html` now pins short 해요체 sentences and beginner-only grammar.)

## Run / deploy
- Local: double-click `Start Suji (Korean App).bat` → http://localhost:8877
- Live: https://promoteglobal.github.io/korean-app-built-by-claude/ (GitHub Pages)
- Repo: https://github.com/promoteglobal/korean-app-built-by-claude
- All code is in `index.html`. This folder (`Desktop\Korean\Suji (talking
  practice)`) is the only working copy — old OneDrive/Custom Apps paths are dead.

## API key (post security-review state, Aug 2026)
- The user types their Anthropic key into the app; it lives in browser
  `localStorage` under `suji_ak`. Direct browser calls use the
  `anthropic-dangerous-direct-browser-access: true` header.
- Backup copy in `.claude\.env` (ANTHROPIC_API_KEY) — gitignored, verified
  never committed.
- Keys were ROTATED during the Aug-2026 security review (old Korean-app key
  deleted). Never hardcode a key in `index.html`.

## Conversation memory (added 2026-08-07)
The chat persists in `localStorage` under `suji_hist`, so Suji continues
across refreshes instead of replaying the same "what's your name?" opener.
- `boot()` restores + repaints, then `resumeChat()` sends `SEED_RESUME` so she
  welcomes the student back by name and asks a NEW question.
- `needsResume()` suppresses that call when the last user turn was itself a
  seed — refreshing repeatedly must not stack greetings or spend calls.
- `SEED_FIRST`/`SEED_RESUME` are internal prompts: they go in `history` (the
  model needs them) but `renderHistory()` skips them as chat bubbles.
- `trimHistory()` caps at `HIST_MAX` 40 messages, always keeping the first
  `HIST_HEAD` 6. Head-keeping is load-bearing twice: name/city are
  established there, AND the API requires `history[0]` to have role `user`.
- ↺ (`newChat`) calls `clearHistory()` — it must wipe localStorage too, or
  the "forgotten" conversation returns on the next refresh.
- Memory is per-origin: localhost and github.io keep separate conversations.

## Read before changing behavior
`.claude\memory\project_korean_app.md` — full feature list and decisions
(new Claude sessions do NOT auto-load it; read it manually). Highlights:
- Mic auto-starts 600ms after TTS ends; mic is stopped before TTS plays
  (feedback-loop prevention). No auto-send on silence (removed deliberately —
  learner needs thinking time).
- The 🎤 button ONLY starts/stops listening — it must never send. Sending is
  ➤ and Enter only. (`stopMicAndSend` was deleted; don't reintroduce it.)
- `recog.abort()` fires `onerror` with `error:"aborted"` in Chrome. `onerror`
  MUST ignore `aborted` and `no-speech`, or every language switch and
  delete-flush silently kills the mic (it used to call `stopMic()` for any
  error). Restarting lives in `onend`, gated on `listening`, delayed ~80ms
  because Chrome throws InvalidStateError if `start()` lands too soon.
- Language toggle (한/EN): `recog.lang` can ONLY be set between recognition
  sessions, never on a live one. So `toggleMicLang()` commits the box to
  `finalText`, sets `recog.lang`, and calls `abort()`; `onend` restarts it.
  Do not "simplify" this to a bare `recog.lang = ...` — the change would
  silently not apply until the next `startMic()`. Web Speech has no
  auto-detect and no `lang:"auto"`; real detection needs a cloud STT backend.
- BUT in practice ko-KR mode transcribes mixed Korean/English surprisingly
  well mid-sentence — Google's Korean model has real code-switching tolerance
  (Konglish is normal speech). Confirmed working 2026-08-07. This is an
  undocumented model property, not a feature: reliable for single English
  words and short phrases, shakier for long/uncommon English. Do NOT build a
  cloud-STT auto-detect backend on the assumption it's needed — the 한/EN
  toggle already covers the gap, and the user is happy with this.
- `startMic()` deliberately does NOT clear the box — it seeds `finalText` from
  the existing text so speech appends. That's what makes mixed
  English-then-Korean input possible in one message.
- STT invariant: `finalText` accumulates final speech chunks and `onresult`
  OVERWRITES the textarea with it. So anything that changes the box must also
  reset `finalText` — `onUserEdit()` (manual typing/deleting), `startMic()`,
  and `send()` all do. Miss one and deleted speech reappears on the next
  result. A manual deletion also calls `recog.abort()` to flush words already
  spoken but not yet finalised; `onend` restarts it since `listening` is true.
- Translation rule (critical): Korean simple present 먹어요 → "eats",
  NOT "is eating". Only ~고 있어요 → "-ing".
- Full-English answers (rule 5b): if the student replies in a whole English
  sentence, Suji must (1) teach it as Level-1 Korean under a `💬 한국어로`
  header, (2) react in Korean, (3) ask the next question in Korean — never
  reply in English only. The `💬` label is styled by `.teach-label` and
  stripped from TTS; the taught `→ Korean` line IS spoken deliberately.
- Deliberately NOT built: Netlify key-proxy backend (user is happy with
  localStorage for now).

## Git state (2026-08-07)
4 commits (fa7f611 → eda34aa), code clean. Untracked helper files not yet
committed: `.gitignore`, the launcher .bat, `instructions.docx`,
`claude-conversations/`. Committing `.gitignore` + the .bat would be
reasonable; never commit `.claude/` or any `.env`.

## History
The original build conversations (June 2026) were lost to Claude Code's
old 30-day transcript cleanup (retention is now 10 years). Surviving
history: the git log, the memory file above, and the Aug-2026 security
review chat (in the "clean my computer" project's store, session
847e5c07). See `claude-conversations\README.txt`.
