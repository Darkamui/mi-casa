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
@onready var preview_rect: TextureRect = %PreviewRect

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
