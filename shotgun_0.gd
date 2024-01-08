extends Shotgun

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://shotgun_0.tscn"
	damage = .33
	dmg_per_lvl = .33
	max_cd = 1.0
	rarity = 0
	super()

