extends Node3D

const RendererMath = preload("res://scripts/renderer_math.gd")

const CAMERA_PITCH_DEG := -35.0
const CAMERA_YAW_DEG := -35.0
const CAMERA_DISTANCE := 10.0
const CAMERA_NEAR := 0.05
const CAMERA_FAR := 100.0
const CAMERA_PADDING_FACTOR := 1.15
# Fixed, not recomputed per model -- the README promises scale is "locked
# identically across every asset", so every export must share one zoom
# level or real-world size differences (fridge vs. stove vs. mug) vanish.
# Calibrated against Kitchen_Fridge.fbx, the tallest of the initial
# reference trio: compute_orthogonal_camera_size(fridge_aligned_aabb,
# camera_basis, aspect=1.0, CAMERA_PADDING_FACTOR) == 4.311. Re-tune (and
# re-render the reference trio) if a later asset (e.g. island, cabinet)
# doesn't fit with this padding -- same "tuned visually, then hard-locked"
# allowance as the other camera constants.
const CAMERA_ORTHO_SIZE := 4.311
# Fixed for the same reason as CAMERA_ORTHO_SIZE: floor-pivoted models
# always have their AABB bottom at local y=0, so aiming every model's
# camera at this one fixed world Y (instead of that model's own AABB
# center) makes every export's floor line land on the same canvas row --
# "each asset's floor-contact point sits at the same canvas anchor"
# (spec/Task 6 criterion). Calibrated as the fridge's own aligned AABB
# vertical center (size.y / 2 == 3.308443 / 2), so the calibration
# reference itself still renders centered with even top/bottom padding.
const CAMERA_TARGET_Y := 1.6542215

@onready var render_viewport: SubViewport = %RenderViewport
@onready var world_environment: WorldEnvironment = %WorldEnvironment
@onready var key_light: DirectionalLight3D = %DirectionalLight3D
@onready var camera: Camera3D = %Camera3D
@onready var model_root: Node3D = %ModelRoot
@onready var export_name_field: LineEdit = %ExportNameField
@onready var export_button: Button = %ExportButton
@onready var wall_pivot_checkbox: CheckBox = %WallPivotCheckbox
@onready var floor_covering_checkbox: CheckBox = %FloorCoveringCheckbox
@onready var key_light_off_checkbox: CheckBox = %KeyLightOffCheckbox
@onready var preview_rect: TextureRect = %PreviewRect

func _ready() -> void:
	_configure_environment()
	_configure_viewport()
	_configure_light()
	_configure_camera()
	export_button.pressed.connect(_on_export_button_pressed)
	model_root.child_entered_tree.connect(_on_model_root_child_entered)
	wall_pivot_checkbox.toggled.connect(_on_framing_option_toggled)
	floor_covering_checkbox.toggled.connect(_on_framing_option_toggled)
	key_light_off_checkbox.toggled.connect(_on_key_light_off_toggled)
	# A model dropped into ModelRoot in the editor's Local scene tree (the
	# natural workflow) and saved is already a child by the time _ready()
	# runs, so child_entered_tree never fires for it -- without this, the
	# camera stays at _configure_camera()'s unfit default ortho size.
	if model_root.get_child_count() > 0:
		align_current_model(_current_pivot_mode())

func _current_pivot_mode() -> String:
	return "wall" if wall_pivot_checkbox.button_pressed else "floor"

func _on_model_root_child_entered(_node: Node) -> void:
	# Auto-fit runs the moment a model is placed (spec §6, step 1) so the
	# human's "confirm framing looks correct" workflow step has something
	# to look at before they ever touch the export field.
	#
	# child_entered_tree fires from Node's own _propagate_enter_tree, before
	# it recurses into the new child's descendants -- so the model's nested
	# MeshInstance3D nodes are not yet is_inside_tree() at this point, and
	# compute_model_aabb (which reads global_transform, hard-guarded on
	# is_inside_tree()) would compute a wrong AABB. Deferring one frame lets
	# the whole subtree finish entering first.
	await get_tree().process_frame
	align_current_model(_current_pivot_mode())

func _on_framing_option_toggled(_pressed: bool) -> void:
	# Godot 4 has no live console for calling align_current_model() by hand
	# with an alternate pivot/scale mode while Play is running (no scripting
	# REPL/eval panel exists in the stock editor) -- these checkboxes are the
	# actual mechanism. Re-aligns immediately so toggling after a model is
	# already placed still takes effect.
	if model_root.get_child_count() > 0:
		align_current_model(_current_pivot_mode())

func _on_key_light_off_toggled(pressed: bool) -> void:
	# Same "no live console" reasoning as _on_framing_option_toggled above --
	# this checkbox is the actual mechanism for the README's shadow-disabled
	# variant pass, replacing the impossible "toggle %DirectionalLight3D.visible
	# from the remote script console" instruction.
	key_light.visible = not pressed

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
	# SubViewport has no on-screen presence of its own — without this, the
	# render happens off-screen and the running window shows only the UI
	# CanvasLayer over a blank background, with no way to eyeball framing.
	preview_rect.texture = render_viewport.get_texture()

func _configure_light() -> void:
	key_light.light_color = Color(1.0, 0.93, 0.82)
	key_light.light_energy = 1.1
	key_light.light_specular = 0.3
	key_light.shadow_enabled = true
	key_light.rotation_degrees = Vector3(-55.0, -35.0, 0.0)

func _configure_camera() -> void:
	camera.rotation_degrees = Vector3(CAMERA_PITCH_DEG, CAMERA_YAW_DEG, 0.0)
	camera.position = camera.transform.basis.z.normalized() * CAMERA_DISTANCE
	camera.set_orthogonal(CAMERA_ORTHO_SIZE, CAMERA_NEAR, CAMERA_FAR)

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
	# camera.size is intentionally NOT recomputed here -- it stays at the
	# fixed CAMERA_ORTHO_SIZE set in _configure_camera() so relative
	# real-world scale is preserved across different assets' exports.
	# The camera aim point is the fixed CAMERA_TARGET_Y, not this model's
	# own AABB center -- every floor-pivoted model's AABB bottom is at
	# local y=0, so a shared aim point (with x/z always 0, since the pivot
	# already centers every model horizontally) keeps every export's floor
	# line on the same canvas row, matching the fridge calibration render.
	# Wall pivot has no such shared anchor to preserve -- compute_pivot_offset's
	# "wall" mode already moves the model's own AABB *center* to world origin,
	# so aiming at the fixed floor-calibrated CAMERA_TARGET_Y would look ~1.65m
	# above a wall-mounted model and crop it low in frame. Aim at the origin
	# instead, i.e. exactly where wall pivot already put the model's center.
	if floor_covering_checkbox.button_pressed:
		# Floor coverings (rugs, carpets) are flat and wide, not tall and
		# narrow like the fridge the shared scale/aim was calibrated against.
		# A rug's own vertical extent sits almost entirely *below* the fixed
		# CAMERA_TARGET_Y (fridge-eye-height), so the fixed frustum crops its
		# near corner -- confirmed by measurement: the rug's lowest point
		# landed 0.28 world units past the fixed frustum's bottom edge (half
		# extent 2.1555). A rug isn't scale-comparable to furniture props
		# the way two furniture props are comparable to each other, so this
		# is an explicit, opt-in exception (not a silent default change):
		# fit the camera to this one model's own AABB instead of the shared
		# calibration, same escape-hatch pattern as the README's manual
		# shadow-variant pass.
		var world_aabb := RendererMath.transform_aabb(aabb, model_root.transform)
		var camera_basis := camera.transform.basis
		camera.size = RendererMath.compute_orthogonal_camera_size(world_aabb, camera_basis, 1.0, CAMERA_PADDING_FACTOR)
		var center := world_aabb.position + world_aabb.size * 0.5
		camera.position = center + camera_basis.z.normalized() * CAMERA_DISTANCE
		return
	camera.size = CAMERA_ORTHO_SIZE
	var target := Vector3.ZERO if pivot_mode == "wall" else Vector3(0.0, CAMERA_TARGET_Y, 0.0)
	camera.position = target + camera.transform.basis.z.normalized() * CAMERA_DISTANCE

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
