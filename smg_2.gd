extends Smg

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://smg_2.tscn"
	damage = .55
	dmg_per_lvl = 0.55
	max_cd = .25
	rarity = 2
	super()
