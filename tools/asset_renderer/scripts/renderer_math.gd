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
