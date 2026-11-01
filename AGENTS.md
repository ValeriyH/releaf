# Project Instructions

- At the start of each session, read [PROJECT.md](Project.md) for full project context before doing anything else.
- This is a Godot 4 GDScript project. Follow existing code style and patterns.
- The command pattern is used for all game actions — see [PROJECT.md](Project.md) for details.
- **Ask the user** if [PROJECT.md](Project.md) needs updating and what is planning update.
- Be concise: in replies and in docs/comments, state only what an agent can't infer on its own. No rationale or filler.
- **Agents never change git state** (commit, push, merge, branches) without an explicit request from the user. Leave changes uncommitted in the working tree.
- **A question is a question, not a task.** When the user asks whether something is possible, answer whether it is and what the limits are, and change nothing.
- **Ask before reverting or restoring anything** (files, moves, deleted code), and don't suggest undoing the user's changes as a default: an unexpected change is probably deliberate.

# References

- [tools/STYLE_ANALYSIS.md](tools/STYLE_ANALYSIS.md) — analysis of the game's art style (palette, outline, lighting, shapes). Read it before generating or modifying any asset (tiles, sprites, items).
