extends RigidBody2D

const margin = 100
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


# call this at end of animation
func animationEnded():
	queue_free()

# detect collisions
func _on_bullet_hit(_objectHit):
	# If it hit an enemy (4) or enemy bullet (5) trigger onhits if applicable?
	# print(_objectHit.collision_layer)
	self.set_deferred("freeze", true)

	animTree["parameters/conditions/bullet_hit"] = true
