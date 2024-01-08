extends Revolver

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://revolver_2.tscn"
	damage = 1.54
	dmg_per_lvl = 1.54
	max_cd = 0.7
	rarity = 2
	super()
