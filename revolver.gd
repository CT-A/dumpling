extends Gun

class_name Revolver
# Called when the node enters the scene tree for the first time.
func _ready():
	auto = false
	recoil = 50
	recoil_scaling = 50
	offset = Vector2(5,-4)
	bullet_size = 1.5
	penetration = 0
	super()
