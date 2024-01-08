extends Shotgun

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://shotgun_4.tscn"
	damage = 1
	dmg_per_lvl = 1
	max_cd = 0.66
	rarity = 4
	super()

