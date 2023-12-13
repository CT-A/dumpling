extends Control
@onready var start = $CenterBar/Start_Button
@onready var cont = $CenterBar/Continue_Button

var rand_seed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	start.process_mode = Node.PROCESS_MODE_ALWAYS
	start.pressed.connect(self._start_game)
	cont.pressed.connect(self._continue_game)

func get_save():
	var s = {
		"seed" : rand_seed
	}
	return s

func load_save(s):
	rand_seed = s["seed"]

# Start the game
func _start_game():
	rand_seed = RandomNumberGenerator.new().randi_range(-100000,100000)
	hide_menu()
	add_child(load(("res://main_scene.tscn")).instantiate())

# Load the game then start it
func _continue_game():
	await(_start_game())
	if !FileAccess.file_exists("user://save.save"):
		print("No save found!")
		return
	var game_save = FileAccess.open("user://save.save",FileAccess.READ)
	while game_save.get_position() < game_save.get_length():
		var json_string = game_save.get_line()
		var json = JSON.new()
		# Check if it parses ok
		var parsed = json.parse(json_string)
		if not parsed == OK:
			print("json parse error: ", json.get_error_message()," in ", json_string, " at line ", json.get_error_line())
			continue
		# Get the data from the json
		var node_data = json.get_data()
		
		# Time to load each object. We already have them created in the main scene,
		#  so we just need to find them and call load_save passing the save associated with them.
		# Saved nodes will all be saveable, so we can start from there.
		var saveable_nodes = get_tree().get_nodes_in_group("saveable")
		# The node data should be a dict with only one entry
		if node_data.size() > 1:
			print(node_data, " data is weird shape: ", node_data.size(), )
		var node_name = node_data.keys()[0]
		var node_save = node_data.values()[0]
		#print("LOADING ",node_name," : ", node_save)
		var node = find_node_by_name(saveable_nodes, node_name)
		if node:
			if !node.has_method("load_save"):
				print("node ",node," is not loadable!")
			else:
				node.load_save(node_save)
		else:
			print("node not found: ", node)
		
# Go through list and find node with name
func find_node_by_name(list,n):
	var found = null
	for node in list:
		if node.name == n:
			found = node
	return found
func hide_menu():
	$CenterBar.hide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
