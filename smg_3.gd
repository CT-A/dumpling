extends Smg

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://smg_3.tscn"
	damage = .6
	dmg_per_lvl = 0.6
	max_cd = .2
	rarity = 3
	super()
