extends RigidBody2D

var drop_save = {}
var dm = self.get_parent()
var path = "res://predrop.tscn"

func _ready():
	self.body_entered.connect(_on_collide)
	
func _on_collide(body):
	if body.collision_layer == 2:
		drop_save["pos_x"] = global_position.x
		drop_save["pos_y"] = global_position.y
		dm._drop(drop_save)
		queue_free()

# Set modulate color based on rarity of drop_save
func set_color_by_save_rarity():
	var r = int(drop_save["rar"])
	match r:
		0:
			get_node("CollisionShape2D/Sprite2D").modulate = Color.WHITE
		1:
			get_node("CollisionShape2D/Sprite2D").modulate = Color.LIME_GREEN
		2:
			get_node("CollisionShape2D/Sprite2D").modulate = Color.ROYAL_BLUE
		3:
			get_node("CollisionShape2D/Sprite2D").modulate = Color.PURPLE
		4:
			get_node("CollisionShape2D/Sprite2D").modulate = Color.GOLD
		5:
			get_node("CollisionShape2D/Sprite2D").modulate = Color.DARK_RED
		_:
			get_node("CollisionShape2D/Sprite2D").modulate = Color.DEEP_PINK

# Return a dict of important info
func get_save():
	var save = {
		"path" : path,
		"pos_x" : position.x,
		"pos_y" : position.y,
		"vel_x" : linear_velocity.x,
		"vel_y" : linear_velocity.y,
		"drop" : drop_save
	}
	return save
