extends Enemy

const JUMP_VELOCITY = -250.0
const JUMP_DELAY = 1.0

func _ready():
	ENEMY_TYPE_PATH = "res://ground_enemy.tscn"
	TICKET_DROP_CHANCE = 2
	SPEED = 100
	super()

# Jump
func _jump(vel = JUMP_VELOCITY, delay = JUMP_DELAY):
	if (can_jump):
		linear_velocity.y = vel
		can_jump = false
		await get_tree().create_timer(delay).timeout
		can_jump = true

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

func _physics_process(delta):
	super(delta)
