extends Control

const BEZIER_LINE_DIVISIONS = 24
const step = 1.0 / BEZIER_LINE_DIVISIONS

func _draw()->void:
	var keys:Array = owner.connections.keys()
	for k in keys:
		var list:Array = owner.connections[k]
		for data in list:
			var output:Button = data.unitOut.outputs[data.output]
			var input:Button = data.unitIn.inputs[data.input]
			draw_line_bezier_cubic(
				output.rect_global_position + output.rect_size * 0.5 - rect_global_position,
				input.rect_global_position + input.rect_size * 0.5 - rect_global_position,
				output.modulate,
				input.modulate
			)
	if owner.draggedUnit != null:
		var output:Button = owner.draggedUnit.outputs.front()
		var pos_mouse = owner.pos_mouse
		if output != null:
			draw_line_bezier_cubic(
				output.rect_global_position + output.rect_size * 0.5 - rect_global_position,
				owner.draggedUnit.rect_global_position + pos_mouse,
				output.modulate,
				Color.white
			)
		


func draw_line_bezier_cubic(startPos:Vector2, endPos:Vector2, colorFrom:Color, colorTo:Color)->void:
	var previous:Vector2 = startPos
# warning-ignore:unassigned_variable
	var current:Vector2
	for i in BEZIER_LINE_DIVISIONS:
		current.y = EaseCubicInOut(i, startPos.y, endPos.y - startPos.y, BEZIER_LINE_DIVISIONS)
		current.x = previous.x + (endPos.x - startPos.x) / BEZIER_LINE_DIVISIONS
		draw_line(previous, current, colorFrom.linear_interpolate(colorTo, step * i), 2, true)
		previous = current

static func EaseCubicInOut(t:float, b:float, c:float, d:float)->float:
	t /= d/2.0
	if t < 1.0:
		return (c/2.0 *t *t *t + b)
	t -= 2.0
	return (c/2.0 *(t *t *t + 2.0) + b)


