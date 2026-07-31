# CouchMode project guidance

## BetterDisplay integration

- The development reference environment uses BetterDisplay 4.0.4 (Build 45613) Pro on Apple Silicon.
- BetterDisplay is an external user-installed dependency. Do not bundle it or any license information with CouchMode.
- Do not assume that public users have a BetterDisplay Pro license. Detect BetterDisplay availability and relevant capabilities at runtime.
- The intended baseline should work with BetterDisplay Free where possible: selecting the display, changing resolution and refresh rate, and making the TV the main display.
- Treat automatic HDR switching as an optional enhancement that requires BetterDisplay Pro. If it is unavailable, continue without HDR and present a clear, non-blocking explanation.
- Keep BetterDisplay-specific commands behind a small display-configuration protocol or adapter so the rest of the application does not depend on its CLI details.
- `displayplacer` is a possible free, MIT-licensed alternative for a later release. Do not add a second display backend to the MVP unless the project requirements change.
- Query supported modes and command results instead of assuming that 4K, 120 Hz, HDR, or a particular identifier is available on every Mac, cable, adapter, or TV.

## Pull requests

- Never guess the issue number; derive it from the task or GitHub context.
- At the end of every implementation task, tell the user exactly what they need to do and/or verify before a pull request is created.
- Focus that handoff on practical checks the agent cannot complete alone, such as physical hardware behavior, visual or interaction quality, permissions, external applications, real accounts, cables, displays, audio devices, and other environment-specific behavior.
- Provide concrete verification steps, the expected observable results, and any failure signs the user should report back.
- Clearly distinguish checks that are required before the pull request from optional follow-up validation.
- If no user-only verification remains, say explicitly that no manual check is required before the pull request.
- When a required manual check remains, wait for the user to confirm its result before creating the pull request.

GitHub issues remain the source of truth for product scope and acceptance criteria. This file records durable implementation constraints for coding agents.
