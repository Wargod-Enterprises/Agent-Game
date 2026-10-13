# Agent Game

A real-time stealth and tactics game: scan, plan, execute. 2D pixel art with mixed perspectives: top-down hubs and streets, and side-view building infiltration. Built with **Godot 4.7**.

- [Design Doc](Design%20Doc.md): the living design document, including the project layout
- [Brainstorm Report 2026-10-07](Brainstorm%20Report%202026-10-07.md): how the idea was split out from the megametroidvania

## Play it
Open Godot, choose **Import**, pick `project.godot` in this folder, then press **F5**. You start on the hub street.

WASD or arrows move, W/S climb ladders (side view), E grabs or lets go of a ladder, hold Shift to sneak, Q scans, Tab opens upgrades (hub), R restarts.

## Run the tests
From this folder:

```
"C:\Program Files (x86)\Godot\Godot_v4.7.2-stable_win64_console.exe" --headless --path . res://tests/run_tests.tscn
```
