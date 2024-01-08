extends Pistol

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://pistol_1.tscn"
	damage = 0.6
	dmg_per_lvl = 0.6
	max_cd = .4
	rarity = 1
	super()
