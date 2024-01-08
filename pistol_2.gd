extends Pistol

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://pistol_2.tscn"
	damage = 0.8
	dmg_per_lvl = 0.8
	max_cd = .36
	rarity = 2
	super()
