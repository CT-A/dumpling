extends Control

var open = false
var dead = false
@export var menu = Panel.new()
@export var died_screen = Panel.new()
@export var return_to_main_button = Button.new()
@export var resume_button = Button.new()
@export var player = Node2D.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	remove_child(menu)
	remove_child(died_screen)
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(self._close_menu)
	return_to_main_button.pressed.connect(self._return_to_main)
	player.die.connect(self._display_died_screen)

# Show the "you died" screen
func _display_died_screen():
	if !dead:
		dead = true
		add_child(died_screen)
		player.process_mode = Node.PROCESS_MODE_DISABLED
# Take us back to the main menu
func _return_to_main():
	get_tree().change_scene_to_file("res://main_menu.tscn")

# Open the pause menu and pause the game
func _open_menu():
	if !open:
		open = true
		add_child(menu)
		get_tree().paused = true
		Engine.time_scale = 0
	
# Close the menu and resume the game
func _close_menu():
	if open:
		open = false
		remove_child(menu)
		Engine.time_scale = 0.1
		await get_tree().create_timer(0.02).timeout
		Engine.time_scale = 1
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if !open:
			_open_menu()
		else:
			_close_menu()

