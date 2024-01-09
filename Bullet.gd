extends Node2D

const margin = 100
const knock_per_dmg = 1000
const knock_delay = 0.03
var linear_velocity = Vector2(0,0)
# Penetration is decremented each collision (with a damageable enemy)
# Bullets with pen > 0 before decrementing will continue flying
var penetration = 0
var damage = 1
var friendly = true
var color = Color.WHITE
var exclude_array = []

@onready var animTree = $AnimationTree
# Called when the node enters the scene tree for the first time.
func _ready():
	self.body_entered.connect(_on_bullet_hit)

# Set friendly and update color
func set_friendly(f):
	friendly = f
	change_color(Color.WHITE if f else Color.RED)

# Change to the specified color
func change_color(c):
	get_node("CollisionShape2D/Bullet").modulate = c

# Return Dictionary of info necessary to load
func get_save():
	var save = {
		"pos_x" : position.x,
		"pos_y" : position.y,
		"vel_x" : linear_velocity.x,
		"vel_y" : linear_velocity.y,
		"rot" : rotation,
		"dmg" : damage,
		"size" : $CollisionShape2D/Bullet.scale.x,
		"pen" : penetration,
		"friendly" : friendly
		}
	return save
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	## Check if off-screen. If so, delete.
	## Get the viewport's dimensions
	#var screen_rect = get_viewport_rect()
	## Check if the bullet is off-screen
	#if position.x < screen_rect.position.x or position.x > screen_rect.position.x + screen_rect.size.x + margin or position.y < screen_rect.position.y or position.y > screen_rect.position.y + screen_rect.size.y + margin:
	#	# The bullet is off-screen
	#	queue_free()

# Make sure we know the true velocity before hitting something
func _physics_process(delta):
	var target_position = position + linear_velocity*delta
	var collision_object = custom_ray_cast(position,target_position)
	
	if collision_object and collision_object.collider != self:
		# If we stopped (on_bullet_hit == false) adjust the target position.
		if !_on_bullet_hit(collision_object.collider):
			target_position = position.lerp(collision_object.position,.9)
	position = target_position

# Custom raycast function to check for collisions
func custom_ray_cast(start,end):
	var space_state = get_world_2d().direct_space_state
	var collision_mask = 0b00000000000000000000000000010110
	var ray_params = PhysicsRayQueryParameters2D.create(start,end,collision_mask,exclude_array)
	var result = space_state.intersect_ray(ray_params)
	return result

# call this at end of animation
func animationEnded():
	queue_free()

# Custom physics process
func _integrate_forces(state):
	#position += pre_collision_vel*state.step
	print(state.get_contact_count())

# detect collisions
func _on_bullet_hit(_objectHit):
	# Keep flying if you still have penetrative power
	var continue_flying = (penetration > 0)
	# If penetration is less than 0, we are in the process of stopping
	#  and thus should do nothing
	if !(penetration < 0):
		# If fired by the player, knock back hit enemies and damage them
		# Otherwise knockback and damage the player
		var hit_layer = 0
		if friendly:
			# Fired by player, hit enemies on layer 8
			hit_layer = 8
		else:
			# Not fired by layer, hit player instead
			hit_layer = 1
		# If it hit an enemy (4) or bullet (3) trigger onhits if applicable?
		# collision layer is in powers of 2 apparently
		if _objectHit.collision_layer == hit_layer:
			# Knock back the hit thing
			if _objectHit.has_method("knock_after_delay"):
				var amt = knock_per_dmg*(max(damage - 1,0))
				var dir_to_target = Vector2(linear_velocity.x,linear_velocity.y -100)
				var knockback_dir = dir_to_target.normalized()*amt
				_objectHit.knock_after_delay(knockback_dir,damage*knock_delay)
			else:
				pass#print("Object with bitmask ",hit_layer, " missing knock_after_delay()")
			if _objectHit.has_method("_hurt"):
				# Keep going if the enemy was already dead, or if we have more penetrative power
				continue_flying = _objectHit._hurt(damage) || continue_flying
				penetration = penetration-1
			else:
				print("Object on layer 4 missing _hurt()!")
		else:
			continue_flying = false
	if !continue_flying:
		linear_velocity = Vector2(0,0)
		animTree["parameters/conditions/bullet_hit"] = true
	return continue_flying
