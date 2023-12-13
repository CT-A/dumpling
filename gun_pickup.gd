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
		"path" : gun_path,
		"rar" : default_rarity,
		"xp" : gun.xp,
		"lvl" : gun.lvl
	}
	return save

# Load in a new gun from the specified path
func _update_gun(new_path,xp,lvl):
	gun_path = new_path
	gun = load(gun_path).instantiate()
	$Area2D/Sprite2D.texture = gun.get_node("Area2D/Sprite2D").texture
	gun.xp = xp
	gun.lvl = lvl
	loaded = true

func interact():
	# Player is already determined in Interactable
	player.pickup_gun(gun)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
