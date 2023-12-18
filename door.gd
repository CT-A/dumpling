extends Interactable

@onready var lm = get_tree().root.get_node("GameManager/MainScene/LevelManager")
@export var level_path = ""
var locked = false

# Called when the node enters the scene tree for the first time.
func _ready():
	super()

# Return a dict of important info
func get_save():
	var save = {
		"pos_x" : position.x,
		"pos_y" : position.y,
		"path" : "res://door.tscn",
		"level_path" : level_path,
	}
	return save

# Initialize stuff from a save
func load_save(s):
	position = Vector2(s["pos_x"],s["pos_y"])
	level_path = s["level_path"]

# Lock the door and change the sprite to locked
func lock():
	locked = true
	sprite.frame = 1

# Unlock the door and change the sprite to unlocked
func unlock():
	locked = false
	sprite.frame = 0

# When the player interacts, ask to go to the next level
func interact():
	if !locked:
		lm.next_level(level_path)
	else:
		flash_red()
