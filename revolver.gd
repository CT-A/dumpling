extends Gun

# Called when the node enters the scene tree for the first time.
func _ready():
	auto = false
	damage = 2
	max_cd = .5
	recoil = 50
	recoil_scaling = 50
	offset = Vector2(5,-4)
	bullet_size = 1.5
	rarity = 1
	super()
