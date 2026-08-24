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
		["WallPivotCheckbox", CheckBox],
		["FloorCoveringCheckbox", CheckBox],
		["KeyLightOffCheckbox", CheckBox],
		["PreviewRect", TextureRect],
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

	# Regression guard: the committed scene has been saved with a working
	# test model still parented under ModelRoot three separate times on this
	# branch (each time referencing a gitignored FBX under models/, which
	# breaks the tool entirely on a fresh clone/checkout with no such file
	# present). ModelRoot must always be empty at rest in version control.
	var model_root := instance.get_node_or_null("%ModelRoot")
	if model_root and model_root.get_child_count() > 0:
		failures += 1
		print("FAIL: committed scene has a model under ModelRoot (working state saved by accident)")
	else:
		print("PASS: ModelRoot is empty in the committed scene")

	if failures == 0:
		print("ALL PASS")
		quit(0)
	else:
		print("%d FAILURE(S)" % failures)
		quit(1)
