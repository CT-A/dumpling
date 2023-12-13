extends RigidBody2D

@onready var player = get_tree().root.get_node("GameManager/MainScene/Player")
var spawn_timer = 2
var di = false
var drop_pos = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.body_entered.connect(_on_collide)
	if di:
		drop_impulse(drop_pos)

# set a reminder to drop_impulse with the given position when ready.
func queue_impulse(pos):
	di = true
	drop_pos = pos

# Apply an impulse away from the given position
func drop_impulse(pos):
	var i = global_position - pos
	apply_impulse(i.normalized()*100)

# Return a dict of important info
func get_save():
	var save = {
		"pos_x" : position.x,
		"pos_y" : position.y,
		"path" : "xp",
		"rar" : -1,
		"xp" : 1,
		"lvl" : 0,
	}
	return save

# When we hit the player, free ourself and give them 1 xp
func _on_collide(object_hit):
	# If we hit the player
	if object_hit.collision_layer == 1:
		if player.collectXP(1):
			queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dir = (player.global_position - global_position)
	spawn_timer -= delta
	spawn_timer = max(0, spawn_timer)
	self.apply_central_force(dir.normalized()*500*max(0,1-spawn_timer))
		
