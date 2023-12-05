extends Node2D

@onready var player = get_node("../Player")

# Here's our bullet
var bullet = preload("res://bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the player's shoot_bullet signal to a function in this scene
	player.player_shoot.connect(fireBullet)

# Return a dictionary of saved info
func get_save():
	var save = {
		"bullets" : get_bullet_saves()
	}
	return save

# Return an array of dictionarys of bullet info
func get_bullet_saves():
	var bullet_saves = []
	var bullets = get_children()
	for b in bullets:
		if b:
			bullet_saves.append(b.get_save())
	return bullet_saves

func load_save(sv):
	var bullets = sv["bullets"]
	for b in bullets:
		var pos = Vector2(b["pos_x"],b["pos_y"])
		var vel = Vector2(b["vel_x"],b["vel_y"])
		var rot = b["rot"]
		var dmg = b["dmg"]
		var size = b["size"]
		var infoArray = [pos,vel,rot,dmg,size]
		fireBullet(infoArray)


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
