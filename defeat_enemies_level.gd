extends Level

var enemies = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	setup_enemies.call_deferred()
	super()

# Count the enemies and connect to their tree exit
func setup_enemies():
	for e in get_tree().get_nodes_in_group("reload_on_save"):
		e.tree_exited.connect(decrement_enemies)
		enemies += 1

# Reduce enemy count, then if there are none left, call level_complete
func decrement_enemies():
	enemies -= 1
	if enemies == 0:
		level_complete()
