# Godot Asset Renderer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Godot 4 utility project (`tools/asset_renderer/`) that a
human drives interactively to turn one Quaternius FBX model at a time into
a consistently-scaled, correctly-pivoted, transparent-background PNG
sprite, written into `content/art/rendered/props/`.

**Architecture:** A single-scene Godot project. `RendererController`
(attached to the scene root) owns a `SubViewport` containing the render
rig (`Camera3D`, `DirectionalLight3D`, `WorldEnvironment`, `ModelRoot`)
and a small on-screen UI (name field + export button). Pure math (AABB
transforms/merges, pivot-offset math, orthographic-camera framing math)
lives in a dependency-free `renderer_math.gd` so it can be verified with
headless GDScript tests — no GPU, no editor, no conventional test runner.
Scene-graph logic (walking `ModelRoot`'s children, computing a model's
combined AABB) is also headlessly testable since it only reads node
transforms, never rendered pixels. Actual PNG export requires a live
render and is verified manually, in the editor, per the spec's own §8.

**Tech Stack:** Godot 4.7.1 (`C:\Godot\Godot_v4.7.1-stable_win64.exe` for
interactive editor use; `C:\Godot\Godot_v4.7.1-stable_win64_console.exe`
for headless CLI runs — the non-console GUI binary does not forward
`print()` output to the terminal, see CLAUDE.md addition in Task 1).
GDScript only. No Flutter/Dart/Flame code (that's Spec B, a separate plan).

**Spec:** `docs/superpowers/specs/2026-08-24-godot-asset-renderer-design.md`

## Global Constraints

- Camera: fixed orthographic projection, one locked elevated 3/4 angle —
  tuned visually during Task 6, then never changed per-asset (spec §5).
- Lighting: one warm-key `DirectionalLight3D` (upper-left/front-left) +
  soft ambient fill via `WorldEnvironment`; no per-model tweaking (spec §5).
- Background: fully transparent — `SubViewport.transparent_bg = true`,
  no baked checkerboard (spec §5).
- Scale: preserved automatically via AABB-driven auto-fit, never
  hand-tuned per model (spec §5).
- Pivot: bottom-center (floor contact) by default; wall-mounted assets
  (picture, window, curtain) use vertical-center instead (spec §5).
- Padding: export canvas is larger than the tightest bounding box by a
  fixed margin so nothing clips (spec §5).
- Single-model-at-a-time, in-editor, human-driven. No CLI export path,
  no batch queue (spec §6, §10).
- Scope is kitchen-only, ~23 assets (spec §4). No other rooms, no
  material/color variants, no Flutter/Dart/Flame code (spec §3, §10).
- Output convention: `content/art/rendered/props/<name>/<name>_<orientation>.png`
  (spec §4), consumed as a fixed interface by Spec B (spec §9).

---

## Task 1: Project scaffold

**Files:**
- Create: `tools/asset_renderer/project.godot`
- Create: `tools/asset_renderer/models/.gitkeep`
- Create: `tools/asset_renderer/scenes/empty.tscn`
- Modify: `.gitignore`
- Modify: `CLAUDE.md`

**Interfaces:**
- Produces: a Godot 4 project directory that opens in the editor and
  runs headlessly via `--quit`, exit code `0`. Later tasks add
  `scripts/`, `test/`, and replace `scenes/empty.tscn` as the main scene.

- [ ] **Step 1: Create the project directory structure and files**

`tools/asset_renderer/project.godot`:

```ini
; Engine configuration file.
config_version=5

[application]

config/name="AssetRenderer"
run/main_scene="res://scenes/empty.tscn"
config/features=PackedStringArray("4.7")

[rendering]

textures/canvas_textures/default_texture_filter=0
```

`tools/asset_renderer/scenes/empty.tscn`:

```
[gd_scene load_steps=1 format=3]

[node name="Empty" type="Node"]
```

`tools/asset_renderer/models/.gitkeep`: empty file.

- [ ] **Step 2: Ignore FBX copies and Godot's local cache**

Add to `.gitignore` (after the existing "Dev-time-only 3D asset source
packs" block):

```
# Godot asset renderer (tools/asset_renderer/) — dev-time tool, not shipped
tools/asset_renderer/.godot/
tools/asset_renderer/models/*
!tools/asset_renderer/models/.gitkeep
```

- [ ] **Step 3: Document the Godot environment in CLAUDE.md**

Add a bullet to CLAUDE.md's existing "## Environment notes" section
(after the `rive_native`/KGP bullet):

```markdown
- Godot 4.7.1 lives at `C:\Godot\`. Two Windows binaries exist:
  `Godot_v4.7.1-stable_win64.exe` (GUI subsystem — use for interactive
  editor sessions) and `Godot_v4.7.1-stable_win64_console.exe` (console
  subsystem — **required** for `--headless` runs where `print()` output
  must reach the terminal; the GUI binary silently swallows it). Used by
  `tools/asset_renderer/` (see
  `docs/superpowers/plans/2026-08-24-godot-asset-renderer.md`).
```

- [ ] **Step 4: Verify the project loads and quits cleanly, headless**

Run:

```bash
"C:\Godot\Godot_v4.7.1-stable_win64_console.exe" --headless --path tools/asset_renderer --quit
```

Expected: exit code `0`, no `SCRIPT ERROR` or `Failed to load` lines in
the output.

- [ ] **Step 5: Commit**

```bash
git add tools/asset_renderer/project.godot tools/asset_renderer/models/.gitkeep tools/asset_renderer/scenes/empty.tscn .gitignore CLAUDE.md
git commit -m "chore: scaffold Godot asset renderer project"
```

---

## Task 2: Pure AABB/pivot/framing math (`renderer_math.gd`)

**Files:**
- Create: `tools/asset_renderer/scripts/renderer_math.gd`
- Test: `tools/asset_renderer/test/test_renderer_math.gd`

**Interfaces:**
- Produces (all static, no Node dependency, called via
  `const RendererMath = preload("res://scripts/renderer_math.gd")` —
  static methods on a preloaded, non-`class_name` GDScript resource are
  callable directly as `RendererMath.method(...)`):
  - `RendererMath.transform_aabb(aabb: AABB, transform: Transform3D) -> AABB`
  - `RendererMath.merge_aabbs(aabbs: Array[AABB]) -> AABB`
  - `RendererMath.compute_pivot_offset(aabb: AABB, anchor_mode: String) -> Vector3`
    (`anchor_mode` is `"floor"` or `"wall"`)
  - `RendererMath.compute_orthogonal_camera_size(aabb: AABB, camera_basis: Basis, viewport_aspect: float, padding_factor: float) -> float`

- [ ] **Step 1: Write the stub implementation**

`tools/asset_renderer/scripts/renderer_math.gd`:

```gdscript
extends RefCounted

static func transform_aabb(aabb: AABB, transform: Transform3D) -> AABB:
	return AABB()

static func merge_aabbs(aabbs: Array[AABB]) -> AABB:
	return AABB()

static func compute_pivot_offset(aabb: AABB, anchor_mode: String) -> Vector3:
	return Vector3.ZERO

static func compute_orthogonal_camera_size(aabb: AABB, camera_basis: Basis, viewport_aspect: float, padding_factor: float) -> float:
	return 0.0
```

- [ ] **Step 2: Write the failing test**

`tools/asset_renderer/test/test_renderer_math.gd`:

```gdscript
extends SceneTree

const RendererMath = preload("res://scripts/renderer_math.gd")

var failures := 0

func _init() -> void:
	_test_transform_aabb_translation()
	_test_merge_aabbs()
	_test_compute_pivot_offset_floor()
	_test_compute_pivot_offset_wall()
	_test_compute_orthogonal_camera_size_square_aspect()
	_test_compute_orthogonal_camera_size_wide_aspect()

	if failures == 0:
		print("ALL PASS")
		quit(0)
	else:
		print("%d FAILURE(S)" % failures)
		quit(1)

func _test_transform_aabb_translation() -> void:
	var input := AABB(Vector3(-1, -1, -1), Vector3(2, 2, 2))
	var transform := Transform3D(Basis.IDENTITY, Vector3(5, 0, 0))
	var result := RendererMath.transform_aabb(input, transform)
	_expect_aabb("transform_aabb translation", result, AABB(Vector3(4, -1, -1), Vector3(2, 2, 2)))

func _test_merge_aabbs() -> void:
	var a := AABB(Vector3(0, 0, 0), Vector3(1, 1, 1))
	var b := AABB(Vector3(2, 2, 2), Vector3(1, 1, 1))
	var result := RendererMath.merge_aabbs([a, b])
	_expect_aabb("merge_aabbs", result, AABB(Vector3(0, 0, 0), Vector3(3, 3, 3)))

func _test_compute_pivot_offset_floor() -> void:
	var aabb := AABB(Vector3(1, 2, 3), Vector3(4, 5, 6))
	var result := RendererMath.compute_pivot_offset(aabb, "floor")
	_expect_vector3("compute_pivot_offset floor", result, Vector3(-3, -2, -6))

func _test_compute_pivot_offset_wall() -> void:
	var aabb := AABB(Vector3(1, 2, 3), Vector3(4, 5, 6))
	var result := RendererMath.compute_pivot_offset(aabb, "wall")
	_expect_vector3("compute_pivot_offset wall", result, Vector3(-3, -4.5, -6))

func _test_compute_orthogonal_camera_size_square_aspect() -> void:
	var aabb := AABB(Vector3(-1, 0, -1), Vector3(2, 2, 2))
	var result := RendererMath.compute_orthogonal_camera_size(aabb, Basis.IDENTITY, 1.0, 1.2)
	_expect_float("compute_orthogonal_camera_size square aspect", result, 2.4)

func _test_compute_orthogonal_camera_size_wide_aspect() -> void:
	var aabb := AABB(Vector3(-1, 0, -1), Vector3(2, 2, 2))
	var result := RendererMath.compute_orthogonal_camera_size(aabb, Basis.IDENTITY, 2.0, 1.0)
	_expect_float("compute_orthogonal_camera_size wide aspect", result, 2.0)

func _expect_aabb(label: String, actual: AABB, expected: AABB) -> void:
	if actual.position.is_equal_approx(expected.position) and actual.size.is_equal_approx(expected.size):
		print("PASS: %s" % label)
	else:
		failures += 1
		print("FAIL: %s -- expected position=%s size=%s, got position=%s size=%s" % [
			label, expected.position, expected.size, actual.position, actual.size
		])

func _expect_vector3(label: String, actual: Vector3, expected: Vector3) -> void:
	if actual.is_equal_approx(expected):
		print("PASS: %s" % label)
	else:
		failures += 1
		print("FAIL: %s -- expected %s, got %s" % [label, expected, actual])

func _expect_float(label: String, actual: float, expected: float) -> void:
	if is_equal_approx(actual, expected):
		print("PASS: %s" % label)
	else:
		failures += 1
		print("FAIL: %s -- expected %s, got %s" % [label, expected, actual])
```

- [ ] **Step 3: Run the test to verify it fails**

Run:

```bash
"C:\Godot\Godot_v4.7.1-stable_win64_console.exe" --headless --path tools/asset_renderer --script res://test/test_renderer_math.gd
```

Expected: `6 FAILURE(S)`, exit code `1` — all six stub functions return
zeroed-out values that don't match any of the six expectations.

- [ ] **Step 4: Write the real implementation**

Replace `tools/asset_renderer/scripts/renderer_math.gd`:

```gdscript
extends RefCounted

static func transform_aabb(aabb: AABB, transform: Transform3D) -> AABB:
	var corners: Array[Vector3] = []
	for i in range(8):
		corners.append(aabb.position + Vector3(
			aabb.size.x * float(i & 1),
			aabb.size.y * float((i >> 1) & 1),
			aabb.size.z * float((i >> 2) & 1)
		))
	var result := AABB(transform * corners[0], Vector3.ZERO)
	for i in range(1, 8):
		result = result.expand(transform * corners[i])
	return result

static func merge_aabbs(aabbs: Array[AABB]) -> AABB:
	if aabbs.is_empty():
		return AABB()
	var result: AABB = aabbs[0]
	for i in range(1, aabbs.size()):
		result = result.merge(aabbs[i])
	return result

static func compute_pivot_offset(aabb: AABB, anchor_mode: String) -> Vector3:
	var center_x := aabb.position.x + aabb.size.x / 2.0
	var center_z := aabb.position.z + aabb.size.z / 2.0
	var y := aabb.position.y
	if anchor_mode == "wall":
		y = aabb.position.y + aabb.size.y / 2.0
	return Vector3(-center_x, -y, -center_z)

static func compute_orthogonal_camera_size(aabb: AABB, camera_basis: Basis, viewport_aspect: float, padding_factor: float) -> float:
	var right := camera_basis.x.normalized()
	var up := camera_basis.y.normalized()
	var min_h := INF
	var max_h := -INF
	var min_v := INF
	var max_v := -INF
	for i in range(8):
		var corner := aabb.position + Vector3(
			aabb.size.x * float(i & 1),
			aabb.size.y * float((i >> 1) & 1),
			aabb.size.z * float((i >> 2) & 1)
		)
		var h := corner.dot(right)
		var v := corner.dot(up)
		min_h = min(min_h, h)
		max_h = max(max_h, h)
		min_v = min(min_v, v)
		max_v = max(max_v, v)
	var extent_v := max_v - min_v
	var extent_h := (max_h - min_h) / viewport_aspect
	return max(extent_v, extent_h) * padding_factor
```

- [ ] **Step 5: Run the test to verify it passes**

Run the same command as Step 3.

Expected: six `PASS:` lines, then `ALL PASS`, exit code `0`.

- [ ] **Step 6: Commit**

```bash
git add tools/asset_renderer/scripts/renderer_math.gd tools/asset_renderer/test/test_renderer_math.gd
git commit -m "feat: add pure AABB/pivot/framing math for asset renderer"
```

---

## Task 3: Render scene (`asset_renderer.tscn`)

**Files:**
- Create: `tools/asset_renderer/scenes/asset_renderer.tscn`
- Modify: `tools/asset_renderer/project.godot` (main scene)
- Delete: `tools/asset_renderer/scenes/empty.tscn`
- Test: `tools/asset_renderer/test/test_scene_structure.gd`

**Interfaces:**
- Consumes: nothing from earlier tasks (the scene has no script attached
  yet — Task 4 attaches `renderer_controller.gd` and relies on the
  unique names below).
- Produces: a scene with unique-named nodes accessible via `%Name`
  anywhere inside it — `%RenderViewport` (`SubViewport`),
  `%WorldEnvironment` (`WorldEnvironment`), `%DirectionalLight3D`
  (`DirectionalLight3D`), `%Camera3D` (`Camera3D`), `%ModelRoot`
  (`Node3D`), `%ExportNameField` (`LineEdit`), `%ExportButton`
  (`Button`). All non-trivial configuration (camera projection, light
  color, environment, viewport transparency) is deliberately left to
  GDScript in Task 4, not hand-typed as `.tscn` resource blocks — the
  node tree here only declares structure.

- [ ] **Step 1: Write the failing structure test**

`tools/asset_renderer/test/test_scene_structure.gd`:

```gdscript
extends SceneTree

func _init() -> void:
	var packed_scene: PackedScene = load("res://scenes/asset_renderer.tscn")
	var instance := packed_scene.instantiate()
	root.add_child(instance)

	var checks := [
		["RenderViewport", SubViewport],
		["WorldEnvironment", WorldEnvironment],
		["DirectionalLight3D", DirectionalLight3D],
		["Camera3D", Camera3D],
		["ModelRoot", Node3D],
		["ExportNameField", LineEdit],
		["ExportButton", Button],
	]

	var failures := 0
	for check in checks:
		var node_name: String = check[0]
		var expected_type = check[1]
		var node := instance.get_node_or_null("%" + node_name)
		if node == null:
			failures += 1
			print("FAIL: %s not found via unique name" % node_name)
		elif not is_instance_of(node, expected_type):
			failures += 1
			print("FAIL: %s has wrong type" % node_name)
		else:
			print("PASS: %s" % node_name)

	if failures == 0:
		print("ALL PASS")
		quit(0)
	else:
		print("%d FAILURE(S)" % failures)
		quit(1)
```

Run:

```bash
"C:\Godot\Godot_v4.7.1-stable_win64_console.exe" --headless --path tools/asset_renderer --script res://test/test_scene_structure.gd
```

Expected: `Failed loading resource: res://scenes/asset_renderer.tscn` (or
similar load failure) and a non-zero exit code — the file doesn't exist yet.

- [ ] **Step 2: Write the scene**

`tools/asset_renderer/scenes/asset_renderer.tscn`:

```
[gd_scene load_steps=1 format=3]

[node name="AssetRenderer" type="Node3D"]

[node name="RenderViewport" type="SubViewport" parent="."]
unique_name_in_owner = true
size = Vector2i(1024, 1024)

[node name="WorldEnvironment" type="WorldEnvironment" parent="RenderViewport"]
unique_name_in_owner = true

[node name="DirectionalLight3D" type="DirectionalLight3D" parent="RenderViewport"]
unique_name_in_owner = true

[node name="Camera3D" type="Camera3D" parent="RenderViewport"]
unique_name_in_owner = true
current = true

[node name="ModelRoot" type="Node3D" parent="RenderViewport"]
unique_name_in_owner = true

[node name="UI" type="CanvasLayer" parent="."]

[node name="ExportPanel" type="PanelContainer" parent="UI"]
offset_left = 16.0
offset_top = 16.0
offset_right = 340.0
offset_bottom = 56.0

[node name="ExportRow" type="HBoxContainer" parent="UI/ExportPanel"]

[node name="ExportNameField" type="LineEdit" parent="UI/ExportPanel/ExportRow"]
unique_name_in_owner = true
custom_minimum_size = Vector2(220, 0)
placeholder_text = "export name, e.g. fridge_000"

[node name="ExportButton" type="Button" parent="UI/ExportPanel/ExportRow"]
unique_name_in_owner = true
text = "Export PNG"
```

- [ ] **Step 3: Point the project at the new scene and remove the placeholder**

In `tools/asset_renderer/project.godot`, change:

```ini
run/main_scene="res://scenes/empty.tscn"
```

to:

```ini
run/main_scene="res://scenes/asset_renderer.tscn"
```

Delete `tools/asset_renderer/scenes/empty.tscn`.

- [ ] **Step 4: Run the test to verify it passes**

Run the same command as Step 1.

Expected: seven `PASS:` lines, then `ALL PASS`, exit code `0`.

- [ ] **Step 5: Commit**

```bash
git add tools/asset_renderer/scenes/asset_renderer.tscn tools/asset_renderer/project.godot tools/asset_renderer/test/test_scene_structure.gd
git rm tools/asset_renderer/scenes/empty.tscn
git commit -m "feat: add asset renderer scene tree"
```

---

## Task 4: `RendererController` (framing, pivot, export)

**Files:**
- Create: `tools/asset_renderer/scripts/renderer_controller.gd`
- Test: `tools/asset_renderer/test/test_model_aabb.gd`

**Interfaces:**
- Consumes: `RendererMath.transform_aabb`, `RendererMath.merge_aabbs`,
  `RendererMath.compute_pivot_offset`,
  `RendererMath.compute_orthogonal_camera_size` (Task 2); the unique
  node names from `asset_renderer.tscn` (Task 3).
- Produces (static, reachable via
  `const RendererControllerScript = preload("res://scripts/renderer_controller.gd")`
  without instancing, per Godot's "static methods... can be used from
  non-tool scripts without creating an instance"):
  - `RendererControllerScript.collect_visual_instances(node: Node) -> Array[VisualInstance3D]`
  - `RendererControllerScript.compute_model_aabb(model_root_node: Node3D) -> AABB`
  - Instance methods (not headlessly testable — see Step 3 note):
    `align_current_model(pivot_mode: String = "floor") -> void`
    (auto-invoked on every `model_root.child_entered_tree`),
    `export_png(typed_name: String) -> String`.

- [ ] **Step 1: Write the stub for the testable slice**

`tools/asset_renderer/scripts/renderer_controller.gd`:

```gdscript
extends Node3D

const RendererMath = preload("res://scripts/renderer_math.gd")

static func collect_visual_instances(node: Node) -> Array[VisualInstance3D]:
	return []

static func compute_model_aabb(model_root_node: Node3D) -> AABB:
	return AABB()
```

- [ ] **Step 2: Write the failing test**

`tools/asset_renderer/test/test_model_aabb.gd`:

```gdscript
extends SceneTree

const RendererControllerScript = preload("res://scripts/renderer_controller.gd")

func _init() -> void:
	var model_root := Node3D.new()
	root.add_child(model_root)
	model_root.position = Vector3(10, 0, 10)

	var box := BoxMesh.new()
	box.size = Vector3(2, 2, 2)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = box
	mesh_instance.position = Vector3(1, 1, 0)
	model_root.add_child(mesh_instance)

	var failures := 0

	var instances := RendererControllerScript.collect_visual_instances(model_root)
	if instances.size() == 1 and instances[0] == mesh_instance:
		print("PASS: collect_visual_instances finds the mesh instance")
	else:
		failures += 1
		print("FAIL: collect_visual_instances -- expected [mesh_instance], got %s" % [instances])

	var aabb := RendererControllerScript.compute_model_aabb(model_root)
	var expected := AABB(Vector3(0, 0, -1), Vector3(2, 2, 2))
	if aabb.position.is_equal_approx(expected.position) and aabb.size.is_equal_approx(expected.size):
		print("PASS: compute_model_aabb")
	else:
		failures += 1
		print("FAIL: compute_model_aabb -- expected position=%s size=%s, got position=%s size=%s" % [
			expected.position, expected.size, aabb.position, aabb.size
		])

	if failures == 0:
		print("ALL PASS")
		quit(0)
	else:
		print("%d FAILURE(S)" % failures)
		quit(1)
```

The expected AABB comes from: `mesh_instance`'s local AABB is
`position=(-1,-1,-1) size=(2,2,2)` (a 2×2×2 box centered on its own
origin), translated by the instance's own position `(1,1,0)` relative to
`model_root` (whose own position of `(10,0,10)` is a world-space offset
that must NOT leak into the model-relative AABB) → `(-1+1, -1+1, -1+0)`
= `(0,0,-1)`, size unchanged.

Run:

```bash
"C:\Godot\Godot_v4.7.1-stable_win64_console.exe" --headless --path tools/asset_renderer --script res://test/test_model_aabb.gd
```

Expected: `2 FAILURE(S)`, exit code `1` — the stub returns an empty
array and an empty AABB, matching neither expectation.

- [ ] **Step 3: Write the real implementation**

Replace `tools/asset_renderer/scripts/renderer_controller.gd`:

```gdscript
extends Node3D

const RendererMath = preload("res://scripts/renderer_math.gd")

const CAMERA_PITCH_DEG := -35.0
const CAMERA_YAW_DEG := -35.0
const CAMERA_DISTANCE := 10.0
const CAMERA_NEAR := 0.05
const CAMERA_FAR := 100.0
const CAMERA_PADDING_FACTOR := 1.15

@onready var render_viewport: SubViewport = %RenderViewport
@onready var world_environment: WorldEnvironment = %WorldEnvironment
@onready var key_light: DirectionalLight3D = %DirectionalLight3D
@onready var camera: Camera3D = %Camera3D
@onready var model_root: Node3D = %ModelRoot
@onready var export_name_field: LineEdit = %ExportNameField
@onready var export_button: Button = %ExportButton

func _ready() -> void:
	_configure_environment()
	_configure_viewport()
	_configure_light()
	_configure_camera()
	export_button.pressed.connect(_on_export_button_pressed)
	model_root.child_entered_tree.connect(_on_model_root_child_entered)

func _on_model_root_child_entered(_node: Node) -> void:
	# Auto-fit runs the moment a model is placed (spec §6, step 1) so the
	# human's "confirm framing looks correct" workflow step has something
	# to look at before they ever touch the export field.
	align_current_model()

func _configure_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0, 0, 0, 0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.55, 0.62)
	env.ambient_light_energy = 0.5
	env.ambient_light_sky_contribution = 0.0
	# Shared material treatment (spec §5): controlled saturation, no
	# photorealism push — applied once here, never per-model.
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.85
	env.adjustment_brightness = 1.0
	env.adjustment_contrast = 1.0
	world_environment.environment = env

func _configure_viewport() -> void:
	render_viewport.transparent_bg = true
	render_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

func _configure_light() -> void:
	key_light.light_color = Color(1.0, 0.93, 0.82)
	key_light.light_energy = 1.1
	key_light.light_specular = 0.3
	key_light.shadow_enabled = true
	key_light.rotation_degrees = Vector3(-55.0, -35.0, 0.0)

func _configure_camera() -> void:
	camera.rotation_degrees = Vector3(CAMERA_PITCH_DEG, CAMERA_YAW_DEG, 0.0)
	camera.position = camera.transform.basis.z.normalized() * CAMERA_DISTANCE
	camera.set_orthogonal(2.0, CAMERA_NEAR, CAMERA_FAR)

static func collect_visual_instances(node: Node) -> Array[VisualInstance3D]:
	var result: Array[VisualInstance3D] = []
	for child in node.get_children():
		if child is VisualInstance3D:
			result.append(child)
		result.append_array(collect_visual_instances(child))
	return result

static func compute_model_aabb(model_root_node: Node3D) -> AABB:
	var instances := collect_visual_instances(model_root_node)
	if instances.is_empty():
		return AABB()
	var root_inverse := model_root_node.global_transform.affine_inverse()
	var relative_aabbs: Array[AABB] = []
	for instance in instances:
		var relative_transform := root_inverse * instance.global_transform
		relative_aabbs.append(RendererMath.transform_aabb(instance.get_aabb(), relative_transform))
	return RendererMath.merge_aabbs(relative_aabbs)

func align_current_model(pivot_mode: String = "floor") -> void:
	var aabb := compute_model_aabb(model_root)
	var offset := RendererMath.compute_pivot_offset(aabb, pivot_mode)
	model_root.position = offset
	var aligned_aabb := AABB(aabb.position + offset, aabb.size)
	var aspect := float(render_viewport.size.x) / float(render_viewport.size.y)
	camera.size = RendererMath.compute_orthogonal_camera_size(
		aligned_aabb, camera.global_transform.basis, aspect, CAMERA_PADDING_FACTOR
	)

func _folder_for(typed_name: String) -> String:
	var parts := typed_name.split("_")
	if parts.size() > 1 and parts[-1].is_valid_int() and parts[-1].length() == 3:
		return "_".join(parts.slice(0, parts.size() - 1))
	return typed_name

func export_png(typed_name: String) -> String:
	var image := render_viewport.get_texture().get_image()
	var folder := _folder_for(typed_name)
	var project_root := ProjectSettings.globalize_path("res://")
	var absolute_path := project_root.path_join("../../content/art/rendered/props/%s/%s.png" % [folder, typed_name])
	DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	var error := image.save_png(absolute_path)
	if error != OK:
		push_error("AssetRenderer: failed to save %s (error %d)" % [absolute_path, error])
	return absolute_path

func _on_export_button_pressed() -> void:
	var typed_name := export_name_field.text.strip_edges()
	if typed_name.is_empty():
		push_warning("AssetRenderer: type an export name before exporting.")
		return
	var saved_path := export_png(typed_name)
	print("AssetRenderer: exported %s" % saved_path)
```

Note on `align_current_model`/`export_png`/`_ready()`: these depend on a
live `SubViewport` render (actual GPU pixels). `align_current_model` runs
automatically the instant a model is added under `ModelRoot` (via
`child_entered_tree`), and by the time a human clicks Export the viewport
has already been rendering continuously (`UPDATE_ALWAYS`) for many
frames, so `export_png` needs no `await` to wait for a frame to become
available. `--headless` mode has no rendering device, so this
signal-driven/pixel-producing slice cannot be unit-tested; it's covered
by Task 6's manual validation instead.

- [ ] **Step 4: Run the test to verify it passes**

Run the same command as Step 2.

Expected: two `PASS:` lines, then `ALL PASS`, exit code `0`.

- [ ] **Step 5: Attach the script to the scene root**

Open `tools/asset_renderer/scenes/asset_renderer.tscn` in the Godot
editor (`C:\Godot\Godot_v4.7.1-stable_win64.exe`), select the
`AssetRenderer` root node, attach `res://scripts/renderer_controller.gd`
as its script via the Inspector, and save.

Re-run Task 3's structure test to confirm the scene still loads cleanly:

```bash
"C:\Godot\Godot_v4.7.1-stable_win64_console.exe" --headless --path tools/asset_renderer --script res://test/test_scene_structure.gd
```

Expected: `ALL PASS`, exit code `0`.

- [ ] **Step 6: Commit**

```bash
git add tools/asset_renderer/scripts/renderer_controller.gd tools/asset_renderer/test/test_model_aabb.gd tools/asset_renderer/scenes/asset_renderer.tscn
git commit -m "feat: add RendererController auto-fit, pivot, and export logic"
```

---

## Task 5: README (human workflow)

**Files:**
- Create: `tools/asset_renderer/README.md`

**Interfaces:**
- Consumes: the UI element names from Task 3/4 (`Export Name` field,
  `Export PNG` button) and the checklist in Task 7.
- Produces: nothing consumed by other tasks — this is documentation only.

- [ ] **Step 1: Write the README**

`tools/asset_renderer/README.md`:

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add tools/asset_renderer/README.md
git commit -m "docs: add asset renderer human workflow README"
```

---

## Task 6: Validation (spec §8 acceptance gate)

**Files:** none created or modified — this task renders real assets and
visually inspects them.

**Interfaces:**
- Consumes: the finished tool (Tasks 1–5) and
  `content/art/Ultimate House Interior Pack - June 2020/FBX/`.
- Produces: `content/art/rendered/props/fridge/fridge_000.png`,
  `content/art/rendered/props/stove/stove_000.png`,
  `content/art/rendered/props/mug/mug_000.png` — gates Task 7.

- [ ] **Step 1: Render three reference assets**

Following the README workflow, render `fridge_000`, `stove_000`, and
`mug_000`. During this pass, tune `CAMERA_PITCH_DEG`, `CAMERA_YAW_DEG`,
and `key_light.rotation_degrees` in `renderer_controller.gd` (Task 4) if
the default angle doesn't read as a clear elevated 3/4 view — this is the
one point where the "locked" camera/light constants are allowed to
change, per spec §5 ("exact degrees tuned visually during implementation,
then hard-locked").

- [ ] **Step 2: Check pass/fail criteria**

Open all three PNGs together in an image viewer and confirm every item:

- [ ] Relative scale reads correctly — the fridge is visibly larger than
      the stove, which is visibly larger than the mug (no per-asset scale
      hand-tuning happened; this must fall out of the AABB auto-fit alone).
- [ ] Each asset's floor-contact point sits at the same canvas anchor —
      overlay the three images at matching canvas size and confirm their
      bottoms align.
- [ ] Lighting direction and warmth match across all three (same
      upper-left/front-left key light, same warm color).
- [ ] Background is cleanly transparent — no checkerboard, no opaque
      fill, checked by placing each PNG over a colored background in the
      image viewer.

- [ ] **Step 3: Record the outcome**

If all four checks pass, commit the three PNGs and proceed to Task 7. If
any check fails, fix the offending constant in `renderer_controller.gd`
(camera angle, light rotation/color, or the `_configure_viewport`/
`_configure_environment` transparency setup), re-render the three
reference assets, and re-check before proceeding — do not start Task 7 on
a failing baseline.

```bash
git add content/art/rendered/props/fridge/fridge_000.png content/art/rendered/props/stove/stove_000.png content/art/rendered/props/mug/mug_000.png
git commit -m "chore: render and validate reference asset trio (fridge, stove, mug)"
```

---

## Task 7: Render the remaining kitchen asset checklist

**Files:** none created or modified — this task renders the remaining
real assets using the validated tool from Task 6.

**Interfaces:**
- Consumes: the finished, validated tool (Tasks 1–6).
- Produces: the full `content/art/rendered/props/` tree, consumed by
  Spec B (Flame kitchen runtime) as a fixed interface (spec §9).

- [ ] **Step 1: Render every remaining item on the kitchen checklist**

Following the README workflow, render each of the following (fridge,
stove, and mug are already done in Task 6):

| Export name | Output path |
|---|---|
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
| `picture_000` | `content/art/rendered/props/picture/picture_000.png` (wall pivot — see README) |
| `dish_stack_small_000` | `content/art/rendered/props/dish_stack_small/dish_stack_small_000.png` |
| `dish_stack_large_000` | `content/art/rendered/props/dish_stack_large/dish_stack_large_000.png` |
| `pan_000` | `content/art/rendered/props/pan/pan_000.png` |
| `crumbs_000` | `content/art/rendered/props/crumbs/crumbs_000.png` |
| `garbage_bag_000` | `content/art/rendered/props/garbage_bag/garbage_bag_000.png` |
| `wall_000` | `content/art/rendered/props/wall/wall_000.png` |
| `floor_000` | `content/art/rendered/props/floor/floor_000.png` |
| `window_000` | `content/art/rendered/props/window/window_000.png` (wall pivot — see README) |
| `curtain_000` | `content/art/rendered/props/curtain/curtain_000.png` (wall pivot — see README) |

Note: the spec's own checklist (design doc §4) groups `plant_01`/`plant_02`
and the two `dish_stack` sizes under folder names that already include
the descriptor (`dish_stack/dish_stack_small_000.png`); the table above
instead follows `_folder_for()`'s literal stripping rule (Task 4), which
produces `dish_stack_small/` and `plant_01/` as separate folders. Either
is a valid interface for Spec B as long as it's applied consistently —
prefer the table above since it's what the shipped tool actually
produces; update this table (not the code) if the folder grouping should
instead match the spec's illustrative paths exactly.

- [ ] **Step 2: Spot-check against Task 6's criteria**

Skim the full rendered set for the same four checks as Task 6 Step 2
(scale, pivot, lighting, transparency). Re-render any asset that stands
out as inconsistent.

- [ ] **Step 3: Commit**

```bash
git add content/art/rendered/props/
git commit -m "chore: render full kitchen asset checklist"
```
