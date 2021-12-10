extends Control

const BEZIER_LINE_DIVISIONS = 24
const step = 1.0 / BEZIER_LINE_DIVISIONS

func _draw()->void:
	for data in owner.connections:
		var output:Button = data.unitOut.outputs[data.output]
		var input:Button = data.unitIn.inputs[data.input]
		draw_line_bezier_cubic(
			output.rect_global_position + output.rect_size * 0.5 - rect_global_position,
			input.rect_global_position + input.rect_size * 0.5 - rect_global_position,
			output.modulate,
			input.modulate
		)


func draw_line_bezier_cubic(startPos:Vector2, endPos:Vector2, colorFrom:Color, colorTo:Color)->void:
	var previous:Vector2 = startPos
# warning-ignore:unassigned_variable
	var current:Vector2
	for i in BEZIER_LINE_DIVISIONS:
		current.y = EaseCubicInOut(i, startPos.y, endPos.y - startPos.y, BEZIER_LINE_DIVISIONS)
		current.x = previous.x + (endPos.x - startPos.x) / BEZIER_LINE_DIVISIONS
		draw_line(previous, current, colorFrom.linear_interpolate(colorTo, step * i), 1, true)
		previous = current

static func EaseCubicInOut(t:float, b:float, c:float, d:float)->float:
	t /= d/2.0
	if t < 1.0:
		return (c/2.0 *t *t *t + b)
	t -= 2.0
	return (c/2.0 *(t *t *t + 2.0) + b)

# warning-ignore:unused_argument
func _draw_connection_line(from:Vector2, to:Vector2, colorFrom:Color, colorTo:Color)->void:
	draw_line(from, to, colorFrom)

