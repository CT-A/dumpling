extends RigidBody2D

const margin = 100
const knock_per_dmg = 1000
const knock_delay = 0.03
var pre_collision_vel = Vector2(0,0)
var damage = 1
@onready var animTree = $AnimationTree
# Called when the node enters the scene tree for the first time.
func _ready():
	self.body_entered.connect(_on_bullet_hit)

func get_save():
	var save = {
		"pos_x" : position.x,
		"pos_y" : position.y,
		"vel_x" : linear_velocity.x,
		"vel_y" : linear_velocity.y,
		"rot" : rotation,
		"dmg" : damage,
		"size" : $CollisionShape2D/Bullet.scale.x
		}
	return save
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Check if off-screen. If so, delete.
	# Get the viewport's dimensions
	var screen_rect = get_viewport_rect()
	# Check if the bullet is off-screen
	if position.x < screen_rect.position.x or position.x > screen_rect.position.x + screen_rect.size.x + margin or position.y < screen_rect.position.y or position.y > screen_rect.position.y + screen_rect.size.y + margin:
		# The bullet is off-screen
		queue_free()

# Make sure we know the true velocity before hitting something
func _physics_process(_delta):
	pre_collision_vel = linear_velocity

# call this at end of animation
func animationEnded():
	queue_free()

# detect collisions
func _on_bullet_hit(_objectHit):
	# If it hit an enemy (4) or enemy bullet (5) trigger onhits if applicable?
	# collision layer is in powers of 2 apparently
	if _objectHit.collision_layer == 8:
		# Knock back the hit thing
		if _objectHit.has_method("knock_after_delay"):
			var amt = knock_per_dmg*(max(damage - 1,0))
			var dir_to_target = Vector2(pre_collision_vel.x,pre_collision_vel.y -100)
			var knockback_dir = dir_to_target.normalized()*amt
			_objectHit.knock_after_delay(knockback_dir,damage*knock_delay)
		else:
			print("Object on layer 4 missing knock_after_delay()!")
		if _objectHit.has_method("_hurt"):
			_objectHit._hurt(damage)
		else: 
			print("Object on layer 4 missing _hurt()!")
	self.set_deferred("freeze", true)

	animTree["parameters/conditions/bullet_hit"] = true
