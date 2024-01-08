extends Interactable

@onready var dm = get_tree().root.get_node("GameManager/MainScene/DropManager")
@export var gun_list = {
}
var common = []
var uncommon = []
var rare = []
var epic = []
var legendary = []
var unique = []

# Called when the node enters the scene tree for the first time.
func _ready():
	sort_gun_list()
	super()

# Fill the arrays for each rarity by sorting the gun_list
func sort_gun_list():
	for g in gun_list:
		var r = int(gun_list[g])
		match r:
			0:
				common.append(g)
			1:
				uncommon.append(g)
			2:
				rare.append(g)
			3:
				epic.append(g)
			4:
				legendary.append(g)
			5:
				unique.append(g)

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
	var chosen_rarity = pick_rarity()
	var chosen_list = []
	match chosen_rarity:
		0:
			chosen_list = common
		1:
			chosen_list = uncommon
		2:
			chosen_list = rare
		3:
			chosen_list = epic
		4:
			chosen_list = legendary
		5:
			chosen_list = unique

	var chosen_index = randi_range(0,chosen_list.size() - 1)
	var path = chosen_list[chosen_index]
	var rar = chosen_rarity
	return [path,rar]

# Choose a rarity of gun to spawn
func pick_rarity():
	var rand = randi_range(0,99)
	# 1%
	# TODO: once uniques are implemented, change this top number to 5
	var rar = 4
	# 2%
	if rand < 99:
		rar = 4
	# 7%
	if rand < 97:
		rar = 3
	# 10%
	if rand < 90:
		rar = 2
	# 30%
	if rand < 80:
		rar = 1
	# 50%
	if rand < 50:
		rar = 0
	return rar
