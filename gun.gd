extends Node2D

class_name Gun

signal gun_shoot(bullet)
signal gun_recoil(amount)

var controller = true
var _path = "res://gun.tscn"

const cd_bar_path = "res://bar.tscn"
const MAX_LVL = 3
const MAX_XP = 10

var cd_bar = load(cd_bar_path).instantiate()
var offset = Vector2(5,-4)
var BULLET_SPEED = 500
var auto = true
var damage = 1
var recoil = 0
var recoil_scaling = 0
var flipped = false
var shooting = false
var max_cd = .3
var cooldown = 0
var xp = 0
var lvl = 1
var bullet_size = 1
var rarity = 0
var direction = Vector2(1,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	print("entered gun ready")
	# Move to correct offset
	position = offset
	
	# Make sure cd_bar is initialized correctly
	reset_cd_bar()
	
	# Set cooldown bar color to indicate if auto fire capable
	if !auto:
		cd_bar.color = Color.DARK_GRAY

	# initialize flipped to be accurate
	if abs(rotation) > PI/2:
		# When abs(rotation) is greater than pi/2, the gun is pointing left and the sprite should be flipped
		flipped = true
	else:
		flipped = false

# This is probably unneccessary unless I want to be able to do Gun.new(save)
func _init(save = null):
	if save:
		load_save(save)

func reset_cd_bar():
	cd_bar.queue_free()
	cd_bar = load(cd_bar_path).instantiate()
	add_child(cd_bar)

func get_save():
	var save = {
		"path" : _path,
		"dmg" : damage,
		"rec" : recoil,
		"cd" : cooldown,
		"exp" : xp,
		"level" : lvl,
		"bul_size" : bullet_size,
	}
	return save

func load_save(s):
	print(s)
	_path = s.get("path")
	damage = s.get("dmg")
	recoil = s.get("rec")
	cooldown = s.get("cd")
	xp = s.get("exp")
	lvl = s.get("level")
	bullet_size = s.get("bul_size")

# Tell Player to recoil by this amount
func request_recoil(amt):
	gun_recoil.emit(amt)

# Called to request to shoot, works if off cd
func try_shoot():
	if cooldown == 0:
		# Send a signal to shoot and pass a bullet (player picks this up and sends it to the bulletcontroller)
		gun_shoot.emit(shoot())

# Called to get a bullet at the barrel of this gun
func shoot():
	# Reset CD to max
	cooldown = max_cd
	# Set the bullet's position, velocity, and other properties
	var heading = Vector2(cos(rotation),sin(rotation)).normalized()
	request_recoil(-1*heading*recoil)
	var vel = (heading*BULLET_SPEED)
	var rot = self.rotation
	var dmg = damage
	var posvel = [$Area2D/BulletSpawnLoc.global_position, vel, rot, dmg, bullet_size]
	return (posvel)

func collides_with_obstacles(target_angle):
	# Create a RayCastParameters object
	var raystart = global_position
	raystart.y += 3.5
	var ray_params = PhysicsRayQueryParameters2D.create(raystart, raystart + Vector2(cos(target_angle), sin(target_angle)) * 20)
	ray_params.collision_mask = 0b00000000000000000000000000000010

	# Perform raycast to check for obstacles
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(ray_params)

	var collides = result and result.collider != self

	return collides

func approach_wall(angle):
	var target = snap(angle, PI)
	var new_angle = lerp_angle(rotation,target, .5)
	#if not collides_with_obstacles(new_angle):
	rotation = new_angle

func snap(val, step):
	return round(val/step)*step

func level_up():
	if (lvl<MAX_LVL):
		lvl = lvl + 1
		damage += 1
		bullet_size += 1
		recoil += recoil_scaling
		if (lvl<MAX_LVL):
			xp = 0
		else:
			xp = get_xp_to_advance()
	
func hide_self():
	cd_bar.active = false
	$Area2D/Sprite2D.self_modulate.a = 0

func unhide_self():
	cd_bar.active = true
	$Area2D/Sprite2D.self_modulate.a = 1

func get_xp_to_advance():
	return (MAX_XP*lvl)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	# XP and Level up stuff:
	# If xp exceeds xp required for level up, lvl goes up (unless it is max level already, which
	# probably shouldn't happen anyway, since xp won't be collected if max level.)
	if xp >= get_xp_to_advance():
		level_up()
	
	# Shooting stuff:
	# Decrement cd and display it
	var gun_offset = Vector2(18,-6*$Area2D/Sprite2D.scale.y).rotated(rotation)
	cd_bar.length = remap(cooldown,0,max_cd,0,-10)
	cd_bar.position = global_position+gun_offset
	cd_bar.rotation = rotation
	cooldown = max(0,cooldown-delta)
	
	# Try to shoot if you are auto and shooting
	if (auto and shooting):
		try_shoot()
	
	# Gun Direction:
	# If using controller, ignore mouse
	if (controller):
		if (Input.get_axis("cc_aim_left","cc_aim_right")!=0 or Input.get_axis("cc_aim_up","cc_aim_down")!=0):
			direction = Input.get_vector("cc_aim_left", "cc_aim_right", "cc_aim_up", "cc_aim_down")
			direction = direction.normalized()
	else:
		# Get the cursor position
		var cursor_position = get_global_mouse_position()
		# Calculate the direction from the gun to the cursor
		direction = (cursor_position - global_position).normalized()
	var target_angle = direction.angle()
	if not collides_with_obstacles(target_angle):
		# Rotate the gun to point in the direction of the cursor
		rotation = target_angle
	else:
		approach_wall(target_angle)
	# Flip the gun sprite if needed
	if abs(rotation) > PI/2:
		# When abs(rotation) is greater than pi/2, the gun is pointing left and the sprite should be flipped
		$Area2D/Sprite2D.scale.y = -1
		flipped = true
	else:
		# Gun is pointing right, so flip it back if needed.
		$Area2D/Sprite2D.scale.y = 1
		flipped = false
