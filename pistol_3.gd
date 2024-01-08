extends Pistol

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://pistol_3.tscn"
	damage = 1
	dmg_per_lvl = 1
	max_cd = .33
	rarity = 3
	super()
