extends Interactable

var display_color = Color.WHITE
var flash_timer = 0
var flashing = false
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if flashing:
		flash_timer -= delta
		display_color = display_color.lerp(color,1-flash_timer)
		sprite.material.set_shader_parameter("color", c_to_v4(display_color))
