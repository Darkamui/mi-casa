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
