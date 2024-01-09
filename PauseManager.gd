extends Control

const SAVE_PATH = "user://save.json"

var open = false
var dead = false
@export var menu = Panel.new()
@export var died_screen = Panel.new()
@export var return_to_main_button = Button.new()
@export var died_return_to_main_button = Button.new()
@export var resume_button = Button.new()
@export var save_button = Button.new()
@export var player = Node2D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	menu = $PauseScreen
	died_screen = $Died_Screen
	died_screen.visible = false
	return_to_main_button = $PauseScreen/Buttons/BackToMain
	died_return_to_main_button = $Died_Screen/Return_To_Menu
	resume_button = $PauseScreen/Buttons/Unpause
	save_button = $PauseScreen/Buttons/Save
	player = get_tree().root.get_node("GameManager/MainScene/Player")
	remove_child(menu)
	remove_child(died_screen)
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(self._close_menu)
	return_to_main_button.pressed.connect(self._return_to_main)
	died_return_to_main_button.pressed.connect(self._return_to_main)
	save_button.pressed.connect(self._save_game)
	player.die.connect(self._display_died_screen)

# Show the "you died" screen
func _display_died_screen():
	if !dead:
		dead = true
		died_screen.visible = true
		add_child(died_screen)
		player.process_mode = Node.PROCESS_MODE_DISABLED

func unpause_tree():
	get_tree().paused = false

# Take us back to the main menu
func _return_to_main():
	await(_save_game())
	Engine.time_scale = 1
	await(unpause_tree())
	get_tree().change_scene_to_file("res://main_menu.tscn")

# Save each saveable node's data referenced by the node's name to a file. 
# This means only nodes that are intentionally named will be saveable, and any
#  nodes created at runtime will be handled by their respective handlers if they
#  need to be persistant. 
func _save_game():
	# Open the save file
	var game_save = FileAccess.open("user://save.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("saveable")
	for n in save_nodes:
		# Construct a dict of node name and its data
		# This is in the loop because each node is separated by line,
		#  and each has it's own dictionary
		var save_dict = {}
		# Make sure the node can actually be saved
		if !n.has_method("get_save"):
			print("node ",n," is not saveable!")
		else:
			save_dict[n.name] = n.get_save()
			var save_json_string = JSON.stringify(save_dict)
			game_save.store_line(save_json_string)
	save_button.text = "SAVED!"

# Open the pause menu and pause the game
func _open_menu():
	save_button.text = "SAVE"
	if !open:
		open = true
		add_child(menu)
		get_tree().paused = true
		Engine.time_scale = 0
		resume_button.grab_focus()
	
# Close the menu and resume the game
func _close_menu():
	save_button.text = "SAVE"
	if open:
		open = false
		remove_child(menu)
		Engine.time_scale = 0.1
		await get_tree().create_timer(0.02).timeout
		Engine.time_scale = 1
	unpause_tree()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if !open:
			_open_menu()
		else:
			_close_menu()

