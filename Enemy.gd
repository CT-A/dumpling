extends RigidBody2D

class_name Enemy

signal die()
signal hit_wall()

var ENEMY_TYPE_PATH = "res://ground_enemy.tscn"
var SPEED = 50.0
var CHASE_MARGIN = 50
var TICKET_DROP_CHANCE = 10

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
var shoot_cd = 0
var can_jump = true
var loaded = false
var min_xp_drop = 5
var max_xp_drop = 15

func _ready():
	if !loaded:
		HP = Max_HP
	animationTree.active = true
	self.body_entered.connect(_on_collide)
	self.hit_wall.connect(_turn_around)

# Return a dict of important info
func get_save():
	var save = {
		"pos_x" : position.x,
		"pos_y" : position.y,
		"behavior" : behavior,
		"health" : HP,
		"hitstop" : hitstop,
		"dir" : direction,
		"shoot_cd" : shoot_cd,
		"path" : ENEMY_TYPE_PATH
	}
	return save

# Initialize vars to those from a save
func load_save(s):
	position.x = s["pos_x"]
	position.y = s["pos_y"]
	behavior = s["behavior"]
	HP = s["health"]
	hitstop = s["hitstop"]
	direction = s["dir"]
	shoot_cd = s["shoot_cd"]

func _on_collide(object_hit):
	# If we hit a wall
	if object_hit.collision_layer == 18:
		hit_wall.emit()
	# If we hit the player
	if object_hit.collision_layer == 1:
		player.hurt(1, false)
		var knockback_amt = (player.global_position - global_position)*30
		knock_after_delay(-1*knockback_amt,0)
		player.update_knockback(knockback_amt)

# Figure out what to drop and drop it
func _drop_stuff():
	var rng = get_tree().root.get_node("GameManager").random
	var xp_to_drop = rng.randi_range(min_xp_drop,max_xp_drop)
	var drop_ticket = rng.randi_range(0,10) <= TICKET_DROP_CHANCE
	var dm = get_tree().root.get_node("GameManager/MainScene/DropManager")
	dm.drop_xp(xp_to_drop,global_position)
	if drop_ticket:
		var drop_pos = global_position
		drop_pos.y -= 5
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

# Enemy stops trying to path for a delay
func lose_control(delay, grav = false):
	hitstop = true
	animationTree["parameters/conditions/hurt"] = true
	animationTree["parameters/conditions/stop_hurt"] = false
	if !grav:
		set_deferred("gravity_scale",0.0)
	await(get_tree().create_timer(delay).timeout)
	if !grav:
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
func choose_direction(_state):
	pass

# Return true if you should should chase (default implementation is if can see player and in range)
func _should_chase():
	var should = false
	if abs(player.position.x - position.x) < CHASE_MARGIN && _can_see_player():
		should = true
	return should

# Return true if you can see the player (no objects on collision layer 2 in the way)
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
