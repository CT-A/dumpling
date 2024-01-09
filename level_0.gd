extends Level

@export var gun_pickup = Node2D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_pickup.call_deferred()
	super()

# Most levels will probably need setup functions to properly load from saves.
func setup_pickup():
	if self.is_inside_tree():
		var pickups = get_tree().get_nodes_in_group("reload_on_save")
		gun_pickup = pickups[0]
		gun_pickup.tree_exited.connect(lvl_0_complete)

func lvl_0_complete():
	level_complete()
