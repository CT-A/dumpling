extends CharacterBody2D

@onready var animationTree = $AnimationTree

signal player_shoot(bullet)

func _ready():
	animationTree.active = true

const SPEED = 110.0
const JUMP_VELOCITY = -250.0
const force = 2000
const MAX_HP = 3

var HP = 3
var movespeed = SPEED
var coyoteFrame = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func frameFreeze(timeScale, duration):
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration*timeScale).timeout
	Engine.time_scale = 1.0

func hurt(_damage):
	HP -= _damage
	animationTree["parameters/conditions/hurt"] = true
	frameFreeze(0.1,0.4)
	animationTree["parameters/conditions/hurt"] = false
	
func requestBullet(posvel):
	var pos = posvel[0]
	var vel = posvel[1]
	var rot = posvel[2]
	player_shoot.emit(pos, vel, rot)

func _physics_process(delta):
	# Test damage button
	if Input.is_action_just_pressed("ui_cancel"):
		hurt(1)
	
	# Shoot if shooting
	if Input.is_action_just_pressed("cc_shoot"):
		requestBullet($Pistol.shoot())
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or (coyoteFrame>0)):
		velocity.y = JUMP_VELOCITY
	
	# Check if walking
	if Input.is_action_pressed("cc_shift") and is_on_floor():
		movespeed = SPEED/2
	else:
		movespeed = SPEED
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		animationTree["parameters/conditions/idle"] = false
		animationTree["parameters/conditions/isMoving"] = true
		velocity.x = direction * movespeed
		var scaled_dir = (direction * movespeed)/SPEED
		animationTree["parameters/Walk/blend_position"] = scaled_dir
		animationTree["parameters/Idle/blend_position"].x = scaled_dir
	else:
		animationTree["parameters/conditions/idle"] = true
		animationTree["parameters/conditions/isMoving"] = false
		animationTree["parameters/Idle/blend_position"].y = velocity.y
		velocity.x = move_toward(velocity.x, 0, SPEED)
	var was_on_floor = is_on_floor()
	if move_and_slide():
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			if col.get_collider() is RigidBody2D:
				col.get_collider().apply_force(col.get_normal() * -force)
	if was_on_floor != is_on_floor():
		coyoteFrame = 3
	else:
		coyoteFrame = max(0,coyoteFrame-1)
