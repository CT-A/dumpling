extends Node2D

@onready var player = get_node("../Player")
var gun_pickup = preload("res://gun_pickup.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	player.dropped_gun.connect(_drop)

func _drop(dInfo):
	var g = gun_pickup.instantiate()
	g.position = dInfo[0]
	g._update_gun(dInfo[1])
	g.default_rarity = dInfo[2]
	g.set_rarity(dInfo[2])
	add_child(g)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
