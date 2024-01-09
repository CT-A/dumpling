extends Camera2D
@onready var player = get_tree().root.get_node("GameManager/MainScene/Player")
var room_type = "single"
var speed = 0.1
var level_bounds = Rect2()
var updated = false
var reset = 1
var player_track_radius = 100
var content_scale = Vector2()
# Called when the node enters the scene tree for the first time.
func _ready():
	content_scale = get_tree().root.content_scale_factor
	if !updated:
		level_bounds = get_viewport_rect()
	position = level_bounds.size/2

# Set the level bounds to the given rect
func update_bounds(new_bounds):
	level_bounds = new_bounds
	updated = true

# Immediately go to target
func reset_pos():
	reset = 10

# Takes a target position and adjusts it to keep the camera's edges in bounds
func keep_camera_in_bounds(tp):
	return tp.clamp(level_bounds.position + get_viewport_rect().size/content_scale,level_bounds.size - get_viewport_rect().size/content_scale)

# Return a position that trys to keep the camera within the player_track_radius
func follow_player():
	# If the player is too far from the camera, return lerp towards player at speed
	#  else return player pos
	if player.global_position.distance_to(position) > player_track_radius:
		return position + (player.global_position - position).normalized() * player_track_radius
	else:
		return player.global_position
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var target_position = keep_camera_in_bounds(follow_player())
	position = position.lerp(target_position, speed*reset)
	reset = 1
