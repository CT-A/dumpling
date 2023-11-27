extends Interactable
@export var gun_path = "res://gun.tscn"
@onready var gun = load(gun_path).instantiate()
# Called when the node enters the scene tree for the first time.
func _ready():
	$Area2D/Sprite2D.texture = gun.get_node("Area2D/Sprite2D").texture
	
	super()

# Load in a new gun from the specified path
func _update_gun(new_path):
	gun_path = new_path
	gun = load(gun_path).instantiate()
	$Area2D/Sprite2D.texture = gun.get_node("Area2D/Sprite2D").texture

func interact():
	# Player is already determined in Interactable
	player.pickup_gun(gun)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
