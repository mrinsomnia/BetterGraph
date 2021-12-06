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

func _draw_connection_line(from:Vector2, to:Vector2, colorFrom:Color, colorTo:Color)->void:
	draw_line(from, to, colorFrom)


func draw_line_bezier_cubic(startPos:Vector2, endPos:Vector2, colorFrom:Color, colorTo:Color)->void:
	var previous:Vector2 = startPos
	var current:Vector2
	for i in BEZIER_LINE_DIVISIONS:
		current.y = EaseCubicInOut(i, startPos.y, endPos.y - startPos.y, BEZIER_LINE_DIVISIONS)
		current.x = previous.x + (endPos.x - startPos.x) / BEZIER_LINE_DIVISIONS
		draw_line(previous, current, colorFrom.linear_interpolate(colorTo, step * i))
		previous = current

static func EaseCubicInOut(t:float, b:float, c:float, d:float)->float:
	t /= d/2.0
	if t < 1.0:
		return (c/2.0 *t *t *t + b)
	t -= 2.0
	return (c/2.0 *(t *t *t + 2.0) + b)

"""
float EaseCubicInOut(float t, float b, float c, float d)
{
	if ((t/=d/2.0f) < 1.0f) return (c/2.0f*t*t*t + b);
	t -= 2.0f; return (c/2.0f*(t*t*t + 2.0f) + b);
}

// Draw line using cubic-bezier curves in-out
void DrawLineBezier(Vector2 startPos, Vector2 endPos, float thick, Color color)
{
#ifndef BEZIER_LINE_DIVISIONS
	#define BEZIER_LINE_DIVISIONS         24   // Bezier line divisions
#endif

	Vector2 previous = startPos;
	Vector2 current = { 0 };

	for (int i = 1; i <= BEZIER_LINE_DIVISIONS; i++)
	{
		// Cubic easing in-out
		// NOTE: Easing is calculated only for y position value
		current.y = EaseCubicInOut((float)i, startPos.y, endPos.y - startPos.y, (float)BEZIER_LINE_DIVISIONS);
		current.x = previous.x + (endPos.x - startPos.x)/ (float)BEZIER_LINE_DIVISIONS;

		DrawLineEx(previous, current, thick, color);

		previous = current;
	}
}

// Draw line using quadratic bezier curves with a control point
void DrawLineBezierQuad(Vector2 startPos, Vector2 endPos, Vector2 controlPos, float thick, Color color)
{
	const float step = 1.0f/BEZIER_LINE_DIVISIONS;

	Vector2 previous = startPos;
	Vector2 current = { 0 };
	float t = 0.0f;

	for (int i = 0; i <= BEZIER_LINE_DIVISIONS; i++)
	{
		t = step*i;
		float a = powf(1 - t, 2);
		float b = 2*(1 - t)*t;
		float c = powf(t, 2);

		// NOTE: The easing functions aren't suitable here because they don't take a control point
		current.y = a*startPos.y + b*controlPos.y + c*endPos.y;
		current.x = a*startPos.x + b*controlPos.x + c*endPos.x;

		DrawLineEx(previous, current, thick, color);

		previous = current;
	}
}

// Draw line using cubic bezier curves with 2 control points
void DrawLineBezierCubic(Vector2 startPos, Vector2 endPos, Vector2 startControlPos, Vector2 endControlPos, float thick, Color color)
{
	const float step = 1.0f/BEZIER_LINE_DIVISIONS;

	Vector2 previous = startPos;
	Vector2 current = { 0 };
	float t = 0.0f;

	for (int i = 0; i <= BEZIER_LINE_DIVISIONS; i++)
	{
		t = step*i;
		float a = powf(1 - t, 3);
		float b = 3*powf(1 - t, 2)*t;
		float c = 3*(1-t)*powf(t, 2);
		float d = powf(t, 3);

		current.y = a*startPos.y + b*startControlPos.y + c*endControlPos.y + d*endPos.y;
		current.x = a*startPos.x + b*startControlPos.x + c*endControlPos.x + d*endPos.x;

		DrawLineEx(previous, current, thick, color);

		previous = current;
	}
}

"""
