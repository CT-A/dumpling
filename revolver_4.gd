extends Revolver

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://revolver_4.tscn"
	damage = 3
	dmg_per_lvl = 3
	max_cd = 0.66
	rarity = 4
	super()
