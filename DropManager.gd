extends Node2D

@onready var player = get_node("../Player")
var pre_drop = preload("res://predrop.tscn")

# Clear all drops
func clear_drops():
	for n in get_children():
		remove_child(n)
		n.queue_free()

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
		_drop(d)
	for p in save["pre_drops"]:
		if p.path != "res://xp.tscn":
			var pos = Vector2(p["pos_x"],p["pos_y"])
			var vel = Vector2(p["vel_x"],p["vel_y"])
			var d_save = p["drop"]
			_spawn(pos,vel,d_save)
		else:
			_drop(p)

# Returns an array of saves for the drops
func get_drops_saves():
	var drops = []
	# Get all children (drops) and get a save from each
	for d in get_children():
		if d is Interactable:
			drops.append(d.get_save())
	return drops

# Returns an array of saves for the predrops (and xp)
func get_predrops_saves():
	var predrops = []
	# Get all children (drops) and get a save from each
	for d in get_children():
		if !(d is Interactable):
			predrops.append(d.get_save())
	return predrops

# Function to drop xp from a location
func drop_xp(count, pos):
	var save = {
		"pos_x" : pos.x,
		"pos_y" : pos.y,
		"path" : "res://xp.tscn",
		"rar" : int(4),
		"xp" : -1,
		"lvl" : -1
	}
	for n in range(0, count):
		_drop(save)

# Function to drop ticket from a location
func drop_ticket(pos):
	var save = {
		"pos_x" : pos.x,
		"pos_y" : pos.y,
		"path" : "res://ticket.tscn",
		"rar" : int(4),
		"xp" : -1,
		"lvl" : -1
	}
	_spawn(pos,Vector2(0,-150),save)

# Drop the player's gun as a pre-drop (passed [pos, path, rarity, xp])
func _player_drop(drop):
	var save = {
		"pos_x" : drop[0].x,
		"pos_y" : drop[0].y,
		"path" : "res://gun_pickup.tscn",
		"gun_path" : drop[1],
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

# Create a drop from the given save and add it as a child
# Needs a save that has pos_x,pos_y, path, rar
# If it is a gun_drop, needs xp, lvl\
func _drop(save):
	var d = load(save.path).instantiate()
	d.position = Vector2(save.pos_x,save.pos_y)
	if save.path == "res://gun_pickup.tscn":
		d.load_save(save)
	if save.path == "res://xp.tscn":
		d.position.x += randi_range(-6,6)
		d.position.y -= randi_range(0,12)
		d.queue_impulse(Vector2(save.pos_x,save.pos_y))
	else:
		d.default_rarity = int(save.rar)
	add_child.call_deferred(d)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
