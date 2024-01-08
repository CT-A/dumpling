extends Smg

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://smg_0.tscn"
	damage = .33
	dmg_per_lvl = 0.33
	max_cd = .33
	rarity = 0
	super()
