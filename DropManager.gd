extends Node2D

@onready var player = get_node("../Player")
var gun_pickup = preload("res://gun_pickup.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	player.dropped_gun.connect(_drop)

# Returns a dictionary with one entry, the list of drops' saves
func get_save():
	var save = {
		"drops" : get_drops_saves()
	}
	return save

# Create drops for each saved drop
func load_save(save):
	for d in save["drops"]:
		var pos = Vector2(d["pos_x"],d["pos_y"])
		var path = d["gunpath"]
		var rarity = d["rar"]
		_drop([pos,path,rarity])

# Returns an array of saves for the drops
func get_drops_saves():
	var drops = []
	# Get all children (drops) and get a save from each
	for d in get_children():
		drops.append(d.get_save())
	return drops

# Create a drop with the specified info, and add it as a child
# Takes an array: [pos, path, rarity]
func _drop(dInfo):
	var g = gun_pickup.instantiate()
	g.position = dInfo[0]
	await(g._update_gun(dInfo[1]))
	g.default_rarity = int(dInfo[2])
	# Probably should be called set_color_by_rarity or set_display_rarity
	g.set_rarity(int(dInfo[2]))
	add_child(g)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
