extends Enemy

signal shoot(pos,vel)

var shot_speed = 100
@onready var bc = get_tree().root.get_node("GameManager/MainScene/BulletController")
var target_height = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	shoot_cd = 0
	ENEMY_TYPE_PATH = "res://air_enemy.tscn"
	target_height = global_position.y
	TICKET_DROP_CHANCE = 100
	SPEED = 50
	CHASE_MARGIN = 200
	# Get your shoot signal added to the bullet controller
	bc.add_enemy(self)
	super()

#If the shoot_cd is 0, shoot.
func _try_shoot():
	if shoot_cd <= 0:
		var vel = (player.global_position - global_position).normalized()
		var offset = 7
		var shoot_pos = (global_position+Vector2(5,0)) + vel*offset
		vel *=  shot_speed
		shoot.emit(shoot_pos,vel)
		shoot_cd = get_shoot_delay(behavior)

# override to include gravity
# Get knocked back after a delay
func knock_after_delay(amt,delay):
	var small_amt = amt.normalized() * 10
	linear_velocity = small_amt
	await lose_control(delay,true)
	knockback += amt

# Return a delay based on the current state
# (firing while chasing has a longer delay than firing while at_target)
func get_shoot_delay(state):
	var ret = 0
	match state:
		"chasing":
			ret = 0.5
		"at_target":
			ret = 0.3
		_ :
			ret = 0
	return ret

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
			behavior = "idle"
			behave_for_delay(0.5, "chasing")
		"patrolling_left":
			target_dir = -1
			if (_should_chase()):
				behavior = "start_chasing"
		"patrolling_right":
			target_dir = 1
			if (_should_chase()):
				behavior = "start_chasing"
		"chasing":
			# If you overshot, go a little further then turn around
			if (sign(target_dir) != sign(direction)) && direction !=0:
				target_dir = direction
				behavior = "flying"
				behave_for_delay(0.4, "start_chasing")
			# If we haven't gone past the player yet, try and shoot at them.
			else:
				_try_shoot()
				# If we somehow stopped at the player, we're there.
				if abs(direction) < 1 && abs(target_dir) < 1:
					behavior = "at_target"
		"flying": 
			# Just keep flying
			target_dir = direction
		"at_target":
			# If the player is not right here, start chasing. otherwise, try to shoot
			if abs(target_dir) > 10:
				behavior = "start_chasing"
			else:
				_try_shoot()
				target_dir = 0
		_:
			print("unknown behavior state!")
	# We don't care about the distance for the return value, so we clamp
	var dir = clamp(target_dir, -1,1)
	return dir

func _physics_process(delta):
	# unless you're stunned:
	if !hitstop:
		# Keep yourself airborne!
		if global_position.y > target_height:
			# force = distance below target * value
			self.apply_central_force(Vector2(0,-680 + -100*(global_position.y-target_height)))
		shoot_cd = max(shoot_cd - delta,0)
	super(delta)
