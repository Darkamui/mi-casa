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
