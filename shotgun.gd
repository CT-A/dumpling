extends Gun

class_name Shotgun
# Called when the node enters the scene tree for the first time.
func _ready():
	auto = false
	recoil = 25
	recoil_scaling = 10
	offset = Vector2(5,-4)
	bullet_size = 1
	spread = 0.2
	super()

# Called to request to shoot, works if off cd, shoot 4 bullets
func try_shoot():
	if cooldown == 0:
		# Send a signal to shoot and pass a bullet (player picks this up and sends it to the bulletcontroller)
		gun_shoot.emit(shoot())
		gun_shoot.emit(shoot())
		gun_shoot.emit(shoot())
		gun_shoot.emit(shoot())
