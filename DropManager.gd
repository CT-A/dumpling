extends Node2D

@onready var player = get_node("../Player")
var gun_pickup = preload("res://gun_pickup.tscn")
var ticket = preload("res://ticket.tscn")
var xp = preload("res://xp.tscn")

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
		var path = d["path"]
		var rarity = d["rar"]
		var xp = d["xp"]
		var lvl = d["lvl"]
		_drop([pos,path,rarity,xp])

# Returns an array of saves for the drops
func get_drops_saves():
	var drops = []
	# Get all children (drops) and get a save from each
	for d in get_children():
		drops.append(d.get_save())
	return drops

# Function to drop xp from a location
func drop_xp(count, pos):
	#print("recieved request to drop",count, " xp at ", pos)
	for n in range(0, count):
		_drop([pos,"xp",-1])

# Function to drop ticket from a location
func drop_ticket(pos):
	_drop([pos,"ticket",4])

# Create a drop with the specified info, and add it as a child
# Takes an array: [pos, path, rarity, xp]
func _drop(dInfo):
	# If it has a regular rarity, its a gun drop or ticket. Otherwise it is xp
	if dInfo[2] > -1:
		if dInfo[1] == "ticket":
			var d = ticket.instantiate()
			d.position = dInfo[0]
			d.default_rarity = int(dInfo[2])
			#d.set_rarity(int(dInfo[2]))
			add_child(d)
		else:
			# This is a gun pickup drop
			var g = gun_pickup.instantiate()
			g.position = dInfo[0]
			await(g._update_gun(dInfo[1],dInfo[3],dInfo[4]))
			g.default_rarity = int(dInfo[2])
			add_child(g)
	else:
		if dInfo[1] == "xp":
			var d = xp.instantiate()
			d.position = dInfo[0]
			d.position.x += randi_range(-6,6)
			d.position.y -= randi_range(0,12)
			d.queue_impulse(dInfo[0])
			add_child(d)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
