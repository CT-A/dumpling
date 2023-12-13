extends RigidBody2D

signal die()
signal hit_wall()

const SPEED = 50.0
const JUMP_VELOCITY = -250.0
const JUMP_DELAY = 1.0
const CHASE_MARGIN = 50
const TICKET_DROP_CHANCE = 1

@onready var animationTree = $AnimationTree
@onready var player = get_tree().root.get_node("GameManager/MainScene/Player")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var knockback = Vector2(0,0)
var hitstop = false
var direction = 0
var behavior = "patrolling_right"
var Max_HP = 5
var HP = 0
var can_jump = true

func _ready():
	HP = Max_HP
	animationTree.active = true
	self.body_entered.connect(_on_collide)
	self.hit_wall.connect(_turn_around)

func _on_collide(object_hit):
	# If we hit a wall
	if object_hit.collision_layer == 18:
		hit_wall.emit()
	# If we hit the player
	if object_hit.collision_layer == 1:
		player.hurt(1, false)

func _drop_stuff():
	var rng = RandomNumberGenerator.new()
	rng.seed = get_tree().root.get_node("GameManager").rand_seed + name.hash()
	var xp_to_drop = rng.randi_range(5,15)
	var drop_ticket = rng.randi_range(0,10) <= TICKET_DROP_CHANCE
	var dm = get_tree().root.get_node("GameManager/MainScene/DropManager")
	dm.drop_xp(xp_to_drop,global_position)
	if drop_ticket:
		var drop_pos = global_position
		dm.drop_ticket(drop_pos)

# Drop anything necessary then queue_free
func _die():
	_drop_stuff()
	queue_free()

# Reduce hp by damage and display a flash. Then die if necessary
func _hurt(dmg):
	HP -= dmg
	$Sprite2D.material.set_shader_parameter("flash_mod", 1.0)
	await get_tree().create_timer(0.05).timeout
	$Sprite2D.material.set_shader_parameter("flash_mod", 0.0)
	if behavior != "chasing":
		behavior = "start_chasing"
	if HP <= 0:
		_die()

# Jump
func _jump(vel = JUMP_VELOCITY, delay = JUMP_DELAY):
	if (can_jump):
		linear_velocity.y = vel
		can_jump = false
		await get_tree().create_timer(delay).timeout
		can_jump = true

# Enemy stops trying to path for a delay
func lose_control(delay):
	hitstop = true
	animationTree["parameters/conditions/hurt"] = true
	animationTree["parameters/conditions/stop_hurt"] = false
	set_deferred("gravity_scale",0.0)
	await(get_tree().create_timer(delay).timeout)
	set_deferred("gravity_scale",1.0)
	animationTree["parameters/conditions/hurt"] = false
	animationTree["parameters/conditions/stop_hurt"] = true
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

func behave_for_delay(delay, old_behavior = "start_chasing"):
	await get_tree().create_timer(delay).timeout
	behavior = old_behavior

# Function to choose which direciton to go. Positive 1 is right, negative is left
# Depends on behavior state (patrolling vs chasing vs running etc.)
func choose_direction(state):
	var target = player.position
	var target_dir = target.x - position.x
	
	# Change the target_dir depending on current behavior
	match state:
		"idle":
			target_dir = 0
		"start_chasing":
			_jump(-100,0.3)
			behavior = "idle"
			behave_for_delay(0.3, "chasing")
		"patrolling_left":
			target_dir = -1
			if (_should_chase()):
				behavior = "start_chasing"
		"patrolling_right":
			target_dir = 1
			if (_should_chase()):
				behavior = "start_chasing"
		"chasing":
			if (sign(target_dir) != sign(direction)) && direction !=0:
				target_dir = direction
				behavior = "walking"
				behave_for_delay(0.4, "start_chasing")
				
			# If we are at the player, don't do anything. Maybe this is when we attack? 
			elif abs(direction) < 0.5 && abs(target_dir) < 0.5:
				behavior = "at_target"
		"walking": 
			# Just keep walking
			target_dir = direction
		"at_target":
			# If the player is not right here, start chasing. otherwise, jump 
			if abs(target_dir) > 10:
				behavior = "start_chasing"
			else:
				_jump(-250.0,2)
				target_dir = 0
		_:
			print("unknown behavior state!")
	# We don't care about the distance for the return value, so we clamp
	var dir = clamp(target_dir, -1,1)
	return dir

func _should_chase():
	
	var should = false
	if abs(player.position.x - position.x) < CHASE_MARGIN && _can_see_player():
		should = true
	return should
	
func _can_see_player():
	# Do a raycast towards the player. Return true if nothing hit, return false if a wall is hit.
	var dir = (player.global_position - global_position)
	var target_angle = dir.normalized().angle()
	# Create a RayCastParameters object
	var raystart = global_position
	raystart.y += 3.5
	var ray_params = PhysicsRayQueryParameters2D.create(raystart, raystart + Vector2(cos(target_angle), sin(target_angle)) * (dir.length()+10))

	# Perform raycast to check for obstacles
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(ray_params)
	var collides = result
	return !collides

# Does what it says on the tin
func _turn_around():
	if behavior == "patrolling_left":
		behavior = "patrolling_right"
	elif behavior == "patrolling_right":
		behavior = "patrolling_left"

func _physics_process(_delta):
	if !hitstop:
		if abs(knockback.x) < 0.1:
			# Get the movement direction
			direction = choose_direction(behavior)
			animationTree["parameters/alive/blend_position"] = direction
			if direction:
				linear_velocity.x = direction * SPEED
			else:
				linear_velocity.x = move_toward(linear_velocity.x, 0, SPEED)
	handle_knockback()
