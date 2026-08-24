# simulation/

Pure game logic: entropy engine, task selection, combo/adjacency resolution,
adaptive-duration learning. Functions here take state in and return state
out — no Flutter widgets, no rendering, no audio, no imports from
`presentation/`. This is what stays headlessly testable (spec §5.3).
