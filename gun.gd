extends Sprite2D

const BULLET_SPEED = 700
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called to get a bullet at the barrel of this gun
func shoot():
	# Set the bullet's position, velocity, and other properties
	var vel = (get_global_mouse_position() - global_position).normalized()*BULLET_SPEED
	var rot = self.rotation
	var posvel = [$BulletSpawnLoc.global_position, vel, rot]
	return (posvel)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Get the cursor position
	var cursor_position = get_global_mouse_position()

	# Calculate the direction from the gun to the cursor
	var direction = (cursor_position - global_position).normalized()

	# Rotate the gun to point in the direction of the cursor
	rotation = direction.angle()
	# Flip the gun sprite if needed
	if direction.x < 0:
		# When direction.x is negative, the cursor is on the left side
		scale.y = -1
	else:
		scale.y = 1
