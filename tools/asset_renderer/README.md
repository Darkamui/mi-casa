# Asset Renderer

A Godot 4 dev-time tool. Turns one Quaternius FBX model into one
transparent-background PNG sprite at a time, with camera angle,
lighting, scale, and pivot locked identically across every asset. Not
shipped with the Flutter app — see
`docs/superpowers/specs/2026-08-24-godot-asset-renderer-design.md`.

## Workflow

1. Open this folder (`tools/asset_renderer/`) as a project in Godot 4
   (`C:\Godot\Godot_v4.7.1-stable_win64.exe`).
2. Import the target FBX from
   `content/art/Ultimate House Interior Pack - June 2020/FBX/` — drag it
   into the FileSystem dock (Godot copies/imports it under `models/`).
3. Drag the imported model into the viewport as a child of `ModelRoot`
   (under `RenderViewport` in the Scene dock).
4. Press Play (or open the scene and run it) and confirm the model looks
   correctly framed — centered, resting on the ground plane, not
   clipped. This is a sanity check; framing is automatic.
5. Type the export name into the **Export Name** field — e.g. `fridge_000`
   for a default-orientation asset, `cabinet_045` for a second
   orientation of the same model. Match the checklist below exactly.
6. Click **Export PNG**. The file is written to
   `content/art/rendered/props/<folder>/<name>.png`, where `<folder>` is
   the name with any trailing 3-digit orientation suffix stripped (e.g.
   `fridge_000` → `fridge/fridge_000.png`).
7. Remove the model from `ModelRoot` (delete the node in the Scene
   dock), and repeat from step 2 for the next asset. For a second
   orientation of the same model, re-instance it, rotate it, and export
   again under the `_045`/`_090` suffix.

## Kitchen asset checklist

| Export name | Output path |
|---|---|
| `fridge_000` | `content/art/rendered/props/fridge/fridge_000.png` |
| `stove_000` | `content/art/rendered/props/stove/stove_000.png` |
| `mug_000` | `content/art/rendered/props/mug/mug_000.png` |
| `sink_000` | `content/art/rendered/props/sink/sink_000.png` |
| `cabinet_000` | `content/art/rendered/props/cabinet/cabinet_000.png` |
| `cabinet_045` | `content/art/rendered/props/cabinet/cabinet_045.png` |
| `island_000` | `content/art/rendered/props/island/island_000.png` |
| `stool_000` | `content/art/rendered/props/stool/stool_000.png` |
| `shelf_000` | `content/art/rendered/props/shelf/shelf_000.png` |
| `rug_000` | `content/art/rendered/props/rug/rug_000.png` |
| `plant_01_000` | `content/art/rendered/props/plant_01/plant_01_000.png` |
| `plant_02_000` | `content/art/rendered/props/plant_02/plant_02_000.png` |
| `jar_000` | `content/art/rendered/props/jar/jar_000.png` |
| `kettle_000` | `content/art/rendered/props/kettle/kettle_000.png` |
| `picture_000` | `content/art/rendered/props/picture/picture_000.png` (wall pivot — see below) |
| `dish_stack_small_000` | `content/art/rendered/props/dish_stack_small/dish_stack_small_000.png` |
| `dish_stack_large_000` | `content/art/rendered/props/dish_stack_large/dish_stack_large_000.png` |
| `pan_000` | `content/art/rendered/props/pan/pan_000.png` |
| `crumbs_000` | `content/art/rendered/props/crumbs/crumbs_000.png` |
| `garbage_bag_000` | `content/art/rendered/props/garbage_bag/garbage_bag_000.png` |
| `wall_000` | `content/art/rendered/props/wall/wall_000.png` |
| `floor_000` | `content/art/rendered/props/floor/floor_000.png` |
| `window_000` | `content/art/rendered/props/window/window_000.png` (wall pivot — see below) |
| `curtain_000` | `content/art/rendered/props/curtain/curtain_000.png` (wall pivot — see below) |

Note: the spec's own checklist (design doc §4) groups `plant_01`/`plant_02`
and the two `dish_stack` sizes under folder names that already include
the descriptor (`dish_stack/dish_stack_small_000.png`); the table above
instead follows `_folder_for()`'s literal stripping rule (Task 4), which
produces `dish_stack_small/` and `plant_01/` as separate folders. Either
is a valid interface for Spec B as long as it's applied consistently —
prefer the table above since it's what the shipped tool actually
produces; update this table (not the code) if the folder grouping should
instead match the spec's illustrative paths exactly.

## Wall-mounted assets

`picture`, `window`, and `curtain` pivot from vertical-center, not
floor-contact — call `align_current_model("wall")` from the Godot editor's
remote debugger / script console before exporting those three, instead of
relying on the default floor pivot that runs automatically on placement.

## Optional: shadow-disabled variant

Per spec §5, a handful of assets may need a second pass with the key
light off, alongside the normal `<name>.png`. This is a rare, manual
escape hatch, not part of the mechanical per-asset loop: toggle
`%DirectionalLight3D.visible = false` from the editor's remote script
console, export again (the typed name is up to you — e.g. `fridge_shadow`),
then manually move the resulting file next to the color pass and rename it
to `<name>_shadow.png` if you want it to match the color pass's folder.
