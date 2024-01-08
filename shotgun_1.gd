extends Shotgun

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://shotgun_1.tscn"
	damage = .4
	dmg_per_lvl = .4
	max_cd = 0.8
	rarity = 1
	super()

