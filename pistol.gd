extends Gun

class_name Pistol
# Called when the node enters the scene tree for the first time.
func _ready():
	auto = true
	recoil = 0
	recoil_scaling = 0
	offset = Vector2(5,-4)
	bullet_size = 1
	penetration = 0
	super()
