extends Smg

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://smg_4.tscn"
	damage = .68
	dmg_per_lvl = 0.68
	max_cd = .15
	rarity = 4
	super()
