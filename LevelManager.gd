extends Node2D

var current_level = "res://level_0.tscn"
@onready var dm = get_tree().root.get_node("GameManager/MainScene/DropManager")

# Called when the node enters the scene tree for the first time.
func _ready():
	# load lvl 0 (will get overwritten when loading a save)
	next_level(current_level)

# Load in a level from the given path and set it to the current level. 
#  Move the player to the start position 
func next_level(level_path):
	# Get a clean slate
	unload_level()
	# Clear the drops from the drop manager
	dm.clear_drops()
	var new_lvl = load(level_path).instantiate()
	add_child(new_lvl)
	current_level = level_path
	var player = get_tree().root.get_node("GameManager/MainScene/Player")
	player.position = new_lvl.get_node("Start").position

# Returns an array of saves for the enemies (and other level entities)
func get_entity_saves():
	# level children that exist in the packed scene but can change on load
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
		var entity = load(e["path"]).instantiate()
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
	# Set all levels to unloaded to prevent extra door spawns
	for n in get_children():
		if !n.is_in_group("reload_on_save"):
			n.loaded = false
	# Clean up reloadables
	for n in get_tree().get_nodes_in_group("reload_on_save"):
		n.free()
	# Re-enable door spawning
	for n in get_children():
		if !n.is_in_group("reload_on_save"):
			n.loaded = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
