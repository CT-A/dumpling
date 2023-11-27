extends Node2D

var color = Color.WHITE
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _draw():
	var rect = Rect2(position.x,position.y-1,1,2)
	draw_rect(rect,color)
