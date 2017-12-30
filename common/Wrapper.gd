extends Node


# Pre-requisite: there are only two children, and they're both CollisionShape2D. The main shape is the first child
# and its 'double' (for wrapping purposes) is the second.
static func wrap_horizontal(node, last_pos, width, extents, left, right):
	var pos = node.position
	var margin = width / 8

	if pos.x < width / 2 - margin and last_pos.x >= width / 2 - margin:
		# The mob has crossed into the left of the screen, so place their double on the right.
		var c = node.get_child(1)
		c.position = Vector2(width, 0)
	elif pos.x > width / 2 + margin and last_pos.x <= width / 2 + margin:
		# The mob has crossed into the right of the screen, so place their double on the left.
		var c = node.get_child(1)
		c.position = Vector2(-width, 0)

	if pos.x + extents.x < left:
		# The mob has fully gone off the screen to the left, so wrap them back to the right and place their double on the left.
		node.position = pos + Vector2(width, 0)
		var c = node.get_child(1)
		c.position = Vector2(-width, 0)
	elif pos.x - extents.x >= right:
		# The mob has fully gone off the screen to the right, so wrap them back to the left and place their double on the right.
		node.position = pos + Vector2(-width, 0)
		var c = node.get_child(1)
		c.position = Vector2(width, 0)
