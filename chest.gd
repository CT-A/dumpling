extends Interactable

@onready var dm = get_tree().root.get_node("GameManager/MainScene/DropManager")
@export var gun_list = {
}

# Called when the node enters the scene tree for the first time.
func _ready():
	super()

# When the player interacts
func interact():
	if player.tickets > 0:
		player.tickets -= 1
		open()
	else:
		player.failed_check.emit("tickets")
		flash_red()

# Open the chest
func open():
	sprite.frame = 1
	pick_and_spawn_gun()
	await get_tree().create_timer(1).timeout
	sprite.frame = 0

# Choose a random gun (display process) and request a pre-drop with the chosen gun
func pick_and_spawn_gun():
	var pos = global_position
	pos.y -= 5
	var randX_sign = randi_range(0,1)*2 - 1
	var randX = (randi_range(20,70))*randX_sign
	var vel = Vector2(randX,-200)
	var path_rar = pick_gun()
	var drop_save = {
		"pos_x" : 0,
		"pos_y" : 0,
		"path" : "res://gun_pickup.tscn",
		"gun_path" : path_rar[0],
		"rar" : path_rar[1],
		"xp" : 0,
		"lvl" : 1
	}
	dm._spawn(pos,vel,drop_save)

# Pick a random gun from the gun_list
func pick_gun():
	var chosen_index = randi_range(0,gun_list.size() - 1)
	var path = gun_list.keys()[chosen_index]
	var rar = gun_list.values()[chosen_index]
	return [path,rar]

