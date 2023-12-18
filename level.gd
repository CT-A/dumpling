extends Node

# Class for level utility, like determining completion conditions
class_name Level

# The location to spawn the door when the completion condition is reached
@export var door_position_node = Node2D.new()
# The path to the level that follows this one
@export var following_level_path = ""
# Keep track of if we are fully loaded. If not, don't run level_complete.
var loaded = true
# Path to the door scene
var door_path = "res://door.tscn"
# Tracker for if the player should be allowed to advance
var doors_shown = true
# Reference to the player
@onready var player = get_tree().root.get_node("GameManager/MainScene/Player")

# Function for when the condition is fulfilled
func level_complete():
	if loaded:
		spawn_door(door_position_node.position,following_level_path)

# Spawn a door at the specified location, linking it to the specified level
func spawn_door(door_pos, level_path):
	var door = load(door_path).instantiate()
	var save = {
		"pos_x" : door_pos.x,
		"pos_y" : door_pos.y,
		"path" : "res://door.tscn",
		"level_path" : level_path,
	}
	door.load_save(save)
	add_child.call_deferred(door)

# Disable all doors
func disable_doors():
	if doors_shown:
		var doors = get_tree().get_nodes_in_group("doors")
		for d in doors:
			d.lock()
			doors_shown = false

# Enable all doors
func enable_doors():
	if !doors_shown:
		var doors = get_tree().get_nodes_in_group("doors")
		for d in doors:
			d.unlock()
			doors_shown = true

# Called every frame
func _process(_delta):
	if player.active_gun != null:
		enable_doors()
	else:
		disable_doors()
