extends Node2D

@onready var player = get_node("../Player")
var gun_pickup = preload("res://gun_pickup.tscn")
var ticket = preload("res://ticket.tscn")
var xp = preload("res://xp.tscn")
var pre_drop = preload("res://predrop.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	player.dropped_gun.connect(_player_drop)

# Returns a dictionary with one entry, the list of drops' saves
func get_save():
	var save = {
		"drops" : get_drops_saves(),
		"pre_drops" : get_predrops_saves()
	}
	return save

# Create drops for each saved drop
func load_save(save):
	for d in save["drops"]:
		drop_gun_pickup_from_save(d)
	for p in save["pre_drops"]:
		var pos = Vector2(p["pos_x"],p["pos_y"])
		var vel = Vector2(p["vel_x"],p["vel_y"])
		var d_save = p["drop"]
		_spawn(pos,vel,d_save)

# Helper function to request a drop from a save
func drop_gun_pickup_from_save(s):
		var pos = Vector2(s["pos_x"],s["pos_y"])
		var path = s["path"]
		var rarity = s["rar"]
		var _xp = s["xp"]
		var lvl = s["lvl"]
		_drop([pos,path,rarity,_xp, lvl])

# Returns an array of saves for the drops
func get_drops_saves():
	var drops = []
	# Get all children (drops) and get a save from each
	for d in get_children():
		if d is Interactable:
			drops.append(d.get_save())
	return drops

# Returns an array of saves for the predrops
func get_predrops_saves():
	var predrops = []
	# Get all children (drops) and get a save from each
	for d in get_children():
		if !(d is Interactable):
			predrops.append(d.get_save())
	return predrops

# Function to drop xp from a location
func drop_xp(count, pos):
	#print("recieved request to drop",count, " xp at ", pos)
	for n in range(0, count):
		_drop([pos,"xp",-1])

# Function to drop ticket from a location
func drop_ticket(pos):
	_drop([pos,"ticket",4])

# Drop the player's gun as a pre-drop (passed [pos, path, rarity, xp])
func _player_drop(drop):
	var save = {
		"pos_x" : drop[0].x,
		"pos_y" : drop[0].y,
		"path" : drop[1],
		"rar" : drop[2],
		"xp" : drop[3],
		"lvl" : drop[4]
	}
	_spawn(drop[0],Vector2(0,-150),save)

# Create a predrop that will spawn a specified drop when it lands
func _spawn(pos,vel,drop_save):
	var p = pre_drop.instantiate()
	p.position = pos
	p.linear_velocity = vel
	p.drop_save = drop_save
	p.set_color_by_save_rarity()
	p.dm = self
	add_child(p)

# Create a drop with the specified info, and add it as a child
# Takes an array: [pos, path, rarity, xp, level]
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
			call_deferred("add_child",g)
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
