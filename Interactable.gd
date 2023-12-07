extends Node2D

# Class for things the player can interact with.
# Interactables have an outline that indicates their rarity
# If multiple interactables are in range of interaction, 
# 	the player can select between them using the cursor's position
class_name Interactable

@onready var default_rarity = int(0)
@onready var player = get_tree().root.get_node("GameManager/MainScene/Player")
@onready var sprite = get_node("Area2D/Sprite2D")
var color = Color.WHITE
# Called when the node enters the scene tree for the first time.
func _ready():
	# Set the color to reflect the rarity, then cycle selection to redraw
	set_rarity(default_rarity)
	select()
	deselect()
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

# Set color based on rarity (MAKE SURE YOU PASS AN INT)
#  If a gun is pink, that's an unknown rarity (error)
func set_rarity(r):
	match r:
		0:
			color = Color.WHITE
		1:
			color = Color.LIME_GREEN
		2:
			color = Color.ROYAL_BLUE
		3:
			color = Color.PURPLE
		4:
			color = Color.GOLDENROD
		5:
			color = Color.DARK_RED
		_:
			color = Color.DEEP_PINK

# If intered by the player, let it know
func _on_body_entered(body):
	if body is CharacterBody2D:
		player.entered_interactable(self)
		
# If exited by the player, let it know
func _on_body_exited(body):
	if body is CharacterBody2D:
		player.exited_interactable(self)

# Convert color to vec4
func c_to_v4(c):
	return Vector4(c.r,c.g,c.b,c.a)

func select():
	sprite.z_index = 1
	color.a = 1
	sprite.material.set_shader_parameter("color", c_to_v4(color))
func deselect():
	sprite.z_index = 0
	color.a = 0.5
	sprite.material.set_shader_parameter("color", c_to_v4(color))

func interact():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
