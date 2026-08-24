extends SceneTree

const RendererControllerScript = preload("res://scripts/renderer_controller.gd")

func _init() -> void:
	var model_root := Node3D.new()
	root.add_child(model_root)
	# Godot's custom-SceneTree headless test harness does not mark newly
	# added nodes as "inside tree" until the engine processes a frame, so
	# global_transform (used inside compute_model_aabb) reads as identity
	# until we yield once. Nodes added after this point (e.g. mesh_instance
	# below, as a child of the already-in-tree model_root) enter the tree
	# synchronously and need no further await.
	await process_frame
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
