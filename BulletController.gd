extends Node2D

@onready var player = get_node("../Player")

# Here's our bullet
var bullet = preload("res://bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the player's shoot_bullet signal to a function in this scene
	player.player_shoot.connect(fireBullet)


# This is seperate from the gun script so the bullet travels in world space.
func fireBullet(posvel):
	var pos = posvel[0]
	var vel = posvel[1]
	var rot = posvel[2]
	var dmg = posvel[3]
	var size = posvel[4]
	var newBullet = bullet.instantiate()
	newBullet.position = pos
	newBullet.linear_velocity = vel
	newBullet.rotation = rot
	newBullet.find_child("Bullet").scale = newBullet.scale*size
	newBullet.damage = dmg
	add_child(newBullet)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
