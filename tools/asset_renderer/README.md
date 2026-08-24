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

| Export name | Output path | Status |
|---|---|---|
| `fridge_000` | `content/art/rendered/props/fridge/fridge_000.png` | rendered |
| `stove_000` | `content/art/rendered/props/stove/stove_000.png` | rendered |
| `mug_000` | `content/art/rendered/props/mug/mug_000.png` | deferred — no matching FBX in the Quaternius pack |
| `sink_000` | `content/art/rendered/props/sink/sink_000.png` | rendered |
| `cabinet_000` | `content/art/rendered/props/cabinet/cabinet_000.png` | rendered |
| `cabinet_045` | `content/art/rendered/props/cabinet/cabinet_045.png` | rendered |
| `island_000` | `content/art/rendered/props/island/island_000.png` | deferred — no matching FBX in the Quaternius pack |
| `stool_000` | `content/art/rendered/props/stool/stool_000.png` | rendered |
| `shelf_000` | `content/art/rendered/props/shelf/shelf_000.png` | rendered |
| `rug_000` | `content/art/rendered/props/rug/rug_000.png` | rendered (floor covering) |
| `plant_01_000` | `content/art/rendered/props/plant_01/plant_01_000.png` | rendered |
| `plant_02_000` | `content/art/rendered/props/plant_02/plant_02_000.png` | rendered |
| `jar_000` | `content/art/rendered/props/jar/jar_000.png` | deferred — no matching FBX in the Quaternius pack |
| `kettle_000` | `content/art/rendered/props/kettle/kettle_000.png` | deferred — no matching FBX in the Quaternius pack |
| `picture_000` | `content/art/rendered/props/picture/picture_000.png` (wall mount — see below) | deferred — no matching FBX in the Quaternius pack |
| `dish_stack_small_000` | `content/art/rendered/props/dish_stack_small/dish_stack_small_000.png` | deferred — no matching FBX in the Quaternius pack |
| `dish_stack_large_000` | `content/art/rendered/props/dish_stack_large/dish_stack_large_000.png` | deferred — no matching FBX in the Quaternius pack |
| `pan_000` | `content/art/rendered/props/pan/pan_000.png` | deferred — no matching FBX in the Quaternius pack |
| `crumbs_000` | `content/art/rendered/props/crumbs/crumbs_000.png` | deferred — no matching FBX in the Quaternius pack |
| `garbage_bag_000` | `content/art/rendered/props/garbage_bag/garbage_bag_000.png` | rendered (Trashcan_Cylindric.fbx substitute) |
| `wall_000` | `content/art/rendered/props/wall/wall_000.png` | deferred — no matching FBX in the Quaternius pack |
| `floor_000` | `content/art/rendered/props/floor/floor_000.png` | deferred — no matching FBX in the Quaternius pack |
| `window_000` | `content/art/rendered/props/window/window_000.png` (wall mount — see below) | rendered |
| `curtain_000` | `content/art/rendered/props/curtain/curtain_000.png` (wall mount — see below) | rendered |

Note: the spec's own checklist (design doc §4) groups `plant_01`/`plant_02`
and the two `dish_stack` sizes under folder names that already include
the descriptor (`dish_stack/dish_stack_small_000.png`); the table above
instead follows `_folder_for()`'s literal stripping rule (Task 4), which
produces `dish_stack_small/` and `plant_01/` as separate folders. Either
is a valid interface for Spec B as long as it's applied consistently —
prefer the table above since it's what the shipped tool actually
produces; update this table (not the code) if the folder grouping should
instead match the spec's illustrative paths exactly.

10 rows above (`mug`, `island`, `jar`, `kettle`, `picture`,
`dish_stack_small`, `dish_stack_large`, `pan`, `crumbs`, `wall`, `floor`)
have no matching model anywhere in `content/art/Ultimate House Interior
Pack - June 2020/FBX/` — they need a substitute or hand-authored source
asset before they can be rendered through this tool. This is a content
backlog gap, not a tool defect: re-run the workflow above for each once a
source model exists.

## Wall-mounted assets

`picture`, `window`, and `curtain` pivot from vertical-center, not
floor-contact. Check the **Wall mount** checkbox next to the export name
field before placing (or immediately after placing) the model under
`ModelRoot` — it re-aligns the pivot and re-aims the camera at the
model's own center instead of the default floor-contact pivot and fixed
floor-height aim point. Uncheck it before placing the next (non-wall)
asset.

## Optional: shadow-disabled variant

Per spec §5, a handful of assets may need a second pass with the key
light off, alongside the normal `<name>.png`. This is a rare, manual
escape hatch, not part of the mechanical per-asset loop: check the **Key
light off (shadow pass)** checkbox, export again (the typed name is up to
you — e.g. `fridge_shadow`), then manually move the resulting file next
to the color pass and rename it to `<name>_shadow.png` if you want it to
match the color pass's folder. Uncheck the checkbox afterward — it stays
on for every subsequent export otherwise.
