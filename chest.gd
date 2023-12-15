extends Interactable

var display_color = Color.WHITE
var flash_timer = 0
var flashing = false
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

# flash the shader red
func flash_red():
	flashing = true
	display_color = Color.RED
	display_color.a = color.a
	flash_timer = 1
	await get_tree().create_timer(1).timeout
	display_color = color
	flashing = false

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
	var randX = randi_range(-50,50)
	var vel = Vector2(randX,-200)
	var path_rar = pick_gun()
	var drop_save = {
		"pos_x" : 0,
		"pos_y" : 0,
		"path" : path_rar[0],
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if flashing:
		flash_timer -= delta
		display_color = display_color.lerp(color,1-flash_timer)
		sprite.material.set_shader_parameter("color", c_to_v4(display_color))
