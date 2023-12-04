extends Node2D

var active = true
var color = Color.WHITE
var length = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _draw():
	if(active):
		var rect = Rect2(0,-1,length,2)
		draw_rect(rect,color)

func _process(_delta):
	queue_redraw()
