extends Interactable

var grounded = false

# Called when the node enters the scene tree for the first time.
func _ready():
	super()

# Give the player a ticket when interacted with
func interact():
	# Player is already determined in Interactable
	player.tickets += 1
	queue_free()

# Return a dict of important info
func get_save():
	var save = {
		"pos_x" : position.x,
		"pos_y" : position.y,
		"path" : "res://ticket.tscn",
		"rar" : int(0),
		"xp" : -1,
		"lvl" : -1
	}
	return save

# If you hit the ground you're grounded
func _on_body_entered(body):
	if body.collision_layer == 2:
		grounded = true
	super(body)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !grounded:
		global_position.y += 20*delta
