extends Revolver

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://revolver_0.tscn"
	damage = 1
	dmg_per_lvl = 1
	max_cd = 1.0
	rarity = 0
	super()
