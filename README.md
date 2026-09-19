# WabaQuest

Automatically accepts and turns in quests, and keeps a running count of
both so you can see how much it's done for you.

Targets **WoW Forever** (beta, official release 2026-11-04).

## Features

- **Auto-accept** — accepts single-quest offers and every quest offered on
  a multi-quest NPC greeting screen.
- **Auto-turn-in** — completes any quest that's ready to turn in, on both
  the single-quest and multi-quest screens.
- **Reward picking left to you** — when a completed quest offers a choice
  of more than one reward, WabaQuest stops and leaves the pick to you; it
  only auto-selects when there's nothing to actually choose between.
- **Session stats** — tracks how many quests have been accepted and
  completed, persisted across sessions.
- Both auto-accept and auto-turn-in can be toggled independently, in the
  settings panel or via the slash command.

## Installation

1. Download the latest release.
2. Extract it so the addon's files sit directly under
   `Interface/AddOns/WabaQuest/` (the folder name must be exactly
   `WabaQuest` — it must match the `.toc` file inside it).
3. Restart the game or reload your UI (`/reload`).

## Usage

- `/wabaquest` — show current stats and on/off status for both features.
- `/wabaquest accept on` / `/wabaquest accept off` — toggle auto-accept.
- `/wabaquest turnin on` / `/wabaquest turnin off` — toggle auto-turn-in.
- `/wabaquest options` — open the settings panel.

## License

All rights reserved. See [LICENSE](LICENSE).
