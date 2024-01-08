extends Revolver

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://revolver_3.tscn"
	damage = 2
	dmg_per_lvl = 2
	max_cd = 0.66
	rarity = 3
	super()
