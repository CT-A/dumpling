extends Smg

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://smg_1.tscn"
	damage = .45
	dmg_per_lvl = 0.45
	max_cd = .3
	rarity = 1
	super()
