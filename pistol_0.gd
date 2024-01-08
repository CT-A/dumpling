extends Pistol

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://pistol_0.tscn"
	damage = 0.5
	dmg_per_lvl = 0.5
	max_cd = .5
	rarity = 0
	super()
