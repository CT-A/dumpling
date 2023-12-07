extends RigidBody2D

signal die()

const SPEED = 50.0
const JUMP_VELOCITY = -250.0

@onready var animationTree = $AnimationTree
@onready var player = get_tree().root.get_node("GameManager/MainScene/Player")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var knockback = Vector2(0,0)
var hitstop = false

func _ready():
	animationTree.active = true

# Jump
func _jump():
	linear_velocity.y = JUMP_VELOCITY

# Enemy stops trying to path for a delay
func lose_control(delay):
	hitstop = true
	set_deferred("gravity_scale",0.0)
	await(get_tree().create_timer(delay).timeout)
	set_deferred("gravity_scale",1.0)
	hitstop = false

# Get knocked back after a delay
func knock_after_delay(amt,delay):
	var small_amt = amt.normalized() * 10
	linear_velocity = small_amt
	await lose_control(delay)
	knockback += amt

# Apply and scale down the knockback
func handle_knockback():
	sleeping = false
	apply_central_force(knockback)
	knockback.x = lerp(knockback.x,0.0,0.3)
	knockback.y = lerp(knockback.y,0.0,0.3)
	pass

# Function to choose which direciton to go. Positive 1 is right, negative is left
# Depends on behavior state (patrolling vs chasing vs running etc.)
func choose_direction(state):
	var target = position
	match state:
		"patrolling":
			target = player.position # Change this
		"chasing":
			target = player.position
		"idle":
			target = position
	var target_dir = target.x - position.x
	var dir = clamp(target_dir, -1,1)
	return dir

func _physics_process(delta):
	if !hitstop:
		# Add the gravity.
		#if not is_on_floor():
		#	linear_velocity.y += gravity * delta
		if abs(knockback.x) < 0.1:
			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			var direction = choose_direction("chasing")
			animationTree["parameters/alive/blend_position"] = direction
			if direction:
				linear_velocity.x = direction * SPEED
			else:
				linear_velocity.x = move_toward(linear_velocity.x, 0, SPEED)
	handle_knockback()
