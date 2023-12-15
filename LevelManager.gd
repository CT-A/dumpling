extends Node2D

var current_level = "res://level_1.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	# load lvl 1 (will get overwritten when loading a save)
	next_level(current_level)

# Load in a level from the given path and set it to the current level. 
#  Move the player to the start position 
func next_level(level_path):
	unload_level()
	var new_lvl = load(level_path).instantiate()
	add_child(new_lvl)
	var player = get_tree().root.get_node("GameManager/MainScene/Player")
	player.position = new_lvl.get_node("Start").position

# Returns an array of saves for the enemies (and other level entities)
func get_entity_saves():
	# (actually not just enemies)
	var entities = []
	# Get all reloadable nodes (enemies and doors and stuff)
	for e in get_tree().get_nodes_in_group("reload_on_save"):
		entities.append(e.get_save())
	return entities

# Return a dictionary of important info
func get_save():
	var save = {
		"level" = current_level,
		"entities" = get_entity_saves()
	}
	return save

# Create instanced entity for each saved entity
func load_save(save):
	# First delete the default level
	unload_level()
	# Load in the current level
	current_level = save["level"]
	var instanced_level = load(current_level).instantiate()
	add_child(instanced_level)
	# Get rid of the default level entities
	clean_level()
	# Load in the saved entities
	for e in save["entities"]:
		var entity = load(e["path"]).instance()
		entity.load_save(e)
		add_child(entity)
		entity.add_to_group("reload_on_save")

# Delete the current level (change this if you want level manager to have multiple children)
func unload_level():
	for n in get_children():
		remove_child(n)
		n.queue_free()

# Get rid of all nodes that will be reloaded
func clean_level():
	for n in get_tree().get_nodes_in_group("reload_on_save"):
		n.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
