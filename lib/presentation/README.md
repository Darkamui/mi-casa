# presentation/

Scenes, animation (Rive), audio (stems), and widgets. Reads simulation
state to decide what to render; never writes simulation state directly.
The world is a renderer of application state, never the canonical store
(spec §5.3).
