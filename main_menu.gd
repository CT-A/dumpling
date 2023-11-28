extends Control
@export var start = Button.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	start.pressed.connect(self._start_game)

# Start the game
func _start_game():
	get_tree().change_scene_to_file("res://main_scene.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
