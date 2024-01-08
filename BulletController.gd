extends Node2D

@onready var player = get_node("../Player")

# Here's our bullet
var bullet = preload("res://bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the player's shoot_bullet signal to a function in this scene
	player.player_shoot.connect(fireBullet)

# Connect to the specified enemy's shoot signal
func add_enemy(e):
	e.shoot.connect(fireEnemyBullet)

# Return a dictionary of saved info
func get_save():
	var save = {
		"bullets" : get_bullet_saves(),
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
		var pen = b["pen"]
		var friendly = b["friendly"]
		var infoArray = [pos,vel,rot,dmg,size,pen,friendly,0]
		fireBullet(infoArray)

# Shoot an enemy bullet
func fireEnemyBullet(p,v,r=0,d=1,s=1,pen=0):
	var posvel = [p,v,r,d,s,pen,false,0]
	fireBullet(posvel)

# This is seperate from the gun script so the bullet travels in world space.
# When updating posvel, remember to update gun script (player script should be fine w/out changes)
# bullet save (here and in bullet.gd) and bullet loading (here)
# and fireEnemyBullet (here and enemy script if necessary)
func fireBullet(posvel):
	var pos = posvel[0]
	var vel = posvel[1]
	var rot = posvel[2]
	var dmg = posvel[3]
	var size = posvel[4]
	var pen = posvel[5]
	var friendly = posvel[6]
	var type = posvel[7]
	if type == 0:
		var newBullet = bullet.instantiate()
		newBullet.position = pos
		newBullet.linear_velocity = vel
		newBullet.rotation = rot
		newBullet.find_child("Bullet").scale = newBullet.scale*size
		newBullet.damage = dmg
		newBullet.penetration = pen
		newBullet.set_friendly(friendly)
		add_child(newBullet)
	if type == 1:
		pass # TODO: Shoot a lazer here

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
