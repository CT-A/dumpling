extends Interactable
@export var gun_path = "res://gun.tscn"
var gun = load(gun_path).instantiate()
var loaded = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if !loaded:
		gun = load(gun_path).instantiate()
	$Area2D/Sprite2D.texture = gun.get_node("Area2D/Sprite2D").texture
	
	super()

# Return a dict of important info
func get_save():
	var save = {
		"pos_x" : position.x,
		"pos_y" : position.y,
		"path" : "res://gun_pickup.tscn",
		"gun_path" : gun_path,
		"rar" : default_rarity,
		"xp" : gun.xp,
		"lvl" : gun.lvl
	}
	return save

# This normally won't be called, since gun pickups are loaded by the dm.
#  It is relevent because a fixed drop (part of a level) will load it through
#   the level manager instead of the drop manager
func load_save(s):
	position = Vector2(s["pos_x"],s["pos_y"])
	default_rarity = int(s["rar"])
	_update_gun(s)

# Load in a new gun from the specified save
func _update_gun(save):
	var xp = save["xp"]
	var lvl = save["lvl"]
	gun_path = save["gun_path"]
	default_rarity = int(save["rar"])
	set_rarity(default_rarity)
	gun = load(gun_path).instantiate()
	$Area2D/Sprite2D.texture = gun.get_node("Area2D/Sprite2D").texture
	gun.lvl = 1
	while gun.lvl < lvl:
		gun.level_up()
	gun.xp = xp
	loaded = true

func interact():
	# Player is already determined in Interactable
	player.pickup_gun(gun)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
