extends Pistol

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://pistol_4.tscn"
	damage = 1.5
	dmg_per_lvl = 1.5
	max_cd = .33
	rarity = 4
	super()
