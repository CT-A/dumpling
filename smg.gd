extends Gun

class_name Smg
# Called when the node enters the scene tree for the first time.
func _ready():
	auto = true
	recoil = 1
	recoil_scaling = 1
	offset = Vector2(5,-4)
	bullet_size = 0.6
	spread = 0.08
	super()
