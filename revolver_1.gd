extends Revolver

# Called when the node enters the scene tree for the first time.
func _ready():
	_path = "res://revolver_1.tscn"
	damage = 1.2
	dmg_per_lvl = 1.2
	max_cd = .8
	rarity = 1
	super()
