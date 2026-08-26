# Audio

Both files here are **placeholders**, generated procedurally so the audio
path is testable on a real device. Replace them with authored sound; the
code reads whatever is at these paths and nothing else needs to change.

| File | Played when | What it should become |
| --- | --- | --- |
| `run_loop.wav` | A task run is underway and not paused | A quiet, loopable bed. It plays under a two-minute chore, so it must be uneventful - no melody that resolves, no build. Spec §4.2's adaptive stems land here later. |
| `companion_tap.wav` | The companion is tapped | The companion's own voice. One short sound, well under half a second. |

Keep `run_loop` seamless: the player loops it, so any gap or click at the
join is audible every few seconds.
