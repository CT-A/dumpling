extends CharacterBody2D

@onready var animationTree = $AnimationTree
@onready var active_gun = null#$Pistol
var controller = false
var guns = []
var max_guns = 2
var tickets = 0

signal player_shoot(bullet)
signal dropped_gun(pos)
signal die()
signal failed_check(check)

func _ready():
	animationTree.active = true

func _input(event):
	if (active_gun != null):
		if(event is InputEventKey):
			active_gun.controller = false
			controller = false
		elif(event is InputEventJoypadButton):
			active_gun.controller = true
			controller = true
		elif(event is InputEventMouseButton):
			active_gun.controller = false
			controller = false
		elif(event is InputEventJoypadMotion):
			active_gun.controller = true
			controller = true
		else:
			active_gun.controller = false
			controller = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

const SPEED = 110.0
const JUMP_VELOCITY = -250.0
const force = 2000
const MAX_HP = 10

# Keep track of current recoil
var recoil = Vector2(0,0)
# Keep track of current knockback (similar to recoil but not gaited by jump height)
var knockback = Vector2(0,0)

var HP = 10
var movespeed = SPEED
var coyoteFrame = 0

var overlapping_interactables = []
var selected_interactable = null

# Return an array of guns' saves
func get_guns_saves():
	var guns_saves = []
	for g in guns:
		if g:
			if g != active_gun:
				guns_saves.append(g.get_save())
	return guns_saves

# Make the relevent information into a savable format and return it
func get_save():
	var save = {
		"pos_x" : position.x,
		"pos_y" : position.y,
		"rec_x" : recoil.x,
		"rec_y" : recoil.y,
		"knock_x" : knockback.x,
		"knock_y" : knockback.y,
		"hp" : HP,
		"gun_list" : get_guns_saves(),
		"gun" : active_gun.get_save() if active_gun else null,
		"coyote_frame" : coyoteFrame,
		"tickets" : tickets
	}
	return save
	
# Take a save and load it
func load_save(save):
	position.x = save.pos_x
	position.y = save.pos_y
	recoil.x = save.rec_x
	recoil.y = save.rec_y
	knockback.x = save.knock_x
	knockback.y = save.knock_y
	HP = save.hp
	coyoteFrame = save.coyote_frame
	tickets = save.tickets
	load_guns(save.gun_list)
	var new_active_gun = load(save.gun.path).instantiate() if save.gun else null
	if new_active_gun:
		await pickup_gun(new_active_gun,save.gun)

# Fill the gun list with new guns matching the saved guns
func load_guns(gl):
	guns = []
	for g in gl:
		if g:
			var new_gun = load(g.path).instantiate()
			await pickup_gun(new_gun,g)

# Return texture of active gun
func get_gun_texture():
	return active_gun.get_node("Area2D/Sprite2D").texture
# Return texture of secondary gun
func get_secondary_texture():
	return get_secondary().get_node("Area2D/Sprite2D").texture

# When we enter an interactable, add it to the list of overlapping interactables
func entered_interactable(interactable):
	overlapping_interactables.append(interactable)
# When we exit an interactable, remove it from the list of overlapping interactables
func exited_interactable(interactable):
	interactable.deselect()
	overlapping_interactables.erase(interactable)
	if selected_interactable == interactable:
		select_interactable()

# Determine selected interactable and select it
func select_interactable():
	if !overlapping_interactables.is_empty():
		# Get the cursor position
		var cursor_position = get_global_mouse_position()
		# Determine closest interactable to cursor position
		var closest = null
		if overlapping_interactables.find(selected_interactable) > -1:
			closest = selected_interactable
		# If we don't have a selection yet, just pick the first one.
		if closest == null:
			closest = overlapping_interactables[0]
		else:
		# Make sure we start with everything deselected
			selected_interactable.deselect()
		# Find the closest to the cursor
		for i in overlapping_interactables:
			if (i.global_position - cursor_position).length() < (closest.global_position - cursor_position).length():
				closest = i
		# Select the chosen one
		selected_interactable = closest
		selected_interactable.select()
	else:
		selected_interactable = null

# Returns a list of guns that share a type and rarity with the given gunsave
func fusible_guns(s):
	var to_fuse = []
	if guns.size() > 1 and s.rar < 4:
		var rartype = s.path
		to_fuse = []
		for g in guns:
			print(g._path)
			if (g._path == rartype):
				to_fuse.append(g)
	return to_fuse
	

# Removes the given guns from 'guns' and adds a new gun as the active gun
#  The new gun is one rarity tier higher and has the lvl and xp of the highest used to fuse
func fuse_guns(to_fuse):
	var xp = 0
	var level = 0
	for g in to_fuse:
		if g.xp > xp:
			xp = g.xp
		if g.lvl > level:
			level = g.lvl
	var rar = to_fuse[0].rarity
	var new_path = get_higher_rarity_path(to_fuse[0]._path,rar)
	var save = {
		"path" : new_path,
		"cd" : 0,
		"exp" : xp,
		"level" : level,
		"rar" : rar + 1
	}
	to_fuse.erase(active_gun)
	for e in to_fuse:
		guns.erase(e)
	active_gun.load_save(save)
	await drop(active_gun)
	

# Takes a path to a gun and it's rarity and returns the path to a gun of the same type that is one rarity higher
func get_higher_rarity_path(p,cur_rar):
	var new_rar = cur_rar + 1
	var ret = p.replace(str(cur_rar),str(new_rar))
	return ret

# Pick up gun (and load its save)
func pickup_gun(g,s):
	var fusible = fusible_guns(s)
	print(fusible)
	if fusible.size() == 2:
		fuse_guns(fusible)
	else:
		add_child(g)
		g.load_save(s)
		guns.append(g)
		if guns.size() > max_guns:
			drop(active_gun)
		swapGun(g)

# Drop gun
func drop(g):
	if g == active_gun && guns.size() == 1:
		active_gun = null
		var cs = get_children()
		for c in cs:
			if c is Gun:
				c.queue_free()
	guns.erase(g)
	var dropPos = position + g.offset
	dropPos.y = dropPos.y - 5
	var dropInfo = [dropPos,g._path,g.rarity,g.xp,g.lvl]
	dropped_gun.emit(dropInfo)

# Utility function to do hitstop by slowing time temporarily
func frameFreeze(timeScale, duration):
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration*timeScale).timeout
	Engine.time_scale = 1.0

# Alias for hurt()
func _hurt(dmg,freeze = true):
	hurt(dmg,freeze)

# When hurt, take damage and do hitstop (also display hurt animation)
func hurt(damage, freeze = true):
	HP -= damage
	animationTree["parameters/conditions/hurt"] = true
	if freeze:
		await frameFreeze(0.1,0.4)
	animationTree["parameters/conditions/hurt"] = false
	return false

# Recoil back by the specified amount
func update_recoil(a):
	recoil += a

# Get knocked back by an amount
func update_knockback(a):
	knockback += a

func requestBullet(posvel):
	player_shoot.emit(posvel)

func collectXP(amt):
	if active_gun != null:
		if active_gun.lvl < active_gun.MAX_LVL:
				active_gun.xp += amt
				return true
		else:
			return false
	else:
		return false

func get_secondary():
	if (active_gun != null):
		var ret
		if guns.size() > 0:
			ret = guns[(guns.find(active_gun) + 1) % guns.size()]
		else:
			ret = active_gun
		return ret
	else:
		return null

func swapGun(newGun):
	if newGun == active_gun:
		pass
	else:
		var was_shooting = false
		if active_gun != null:
			was_shooting = active_gun.shooting
			active_gun.shooting = false
			# Tell Gun to get rid of reload bar and hide itself
			active_gun.hide_self()
			active_gun.gun_shoot.disconnect(requestBullet)
			active_gun.gun_recoil.disconnect(update_recoil)
		active_gun = newGun
		active_gun.shooting = was_shooting
		# Bring back the gun and reload bar
		active_gun.unhide_self()
		active_gun.gun_recoil.connect(update_recoil)
		active_gun.gun_shoot.connect(requestBullet)

func _physics_process(delta):
	# Track active interactables
	if !overlapping_interactables.is_empty():
		select_interactable()
	# Interact with something
	if Input.is_action_just_pressed("cc_interact"):
		if selected_interactable:
			if is_instance_valid(selected_interactable):
				selected_interactable.interact()

	# Tell gun to shoot if shooting
	if Input.is_action_just_pressed("cc_shoot"):
		if active_gun != null:
			active_gun.try_shoot()
			active_gun.shooting = true
	if Input.is_action_just_released("cc_shoot"):
		if active_gun != null:
			active_gun.shooting = false
	# Swap guns
	if Input.is_action_just_pressed("cc_swap"):
		if !guns.is_empty():
			swapGun(get_secondary())
	# Drop gun
	if Input.is_action_just_pressed("cc_drop"):
		if !guns.is_empty():
			var gun_to_drop = active_gun
			await swapGun(get_secondary())
			drop(gun_to_drop)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump. (if on the floor, or just left and falling
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("cc_jump")) and (is_on_floor() or (coyoteFrame>0  and (velocity.y >= 0))):
		velocity.y = JUMP_VELOCITY
	
	# Check if walking
	if Input.is_action_pressed("cc_shift") and is_on_floor():
		movespeed = SPEED/2
	else:
		movespeed = SPEED
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		animationTree["parameters/conditions/idle"] = false
		animationTree["parameters/conditions/isMoving"] = true
		velocity.x = direction * movespeed
		var scaled_dir = (direction * movespeed)/SPEED
		animationTree["parameters/Walk/blend_position"] = scaled_dir
		animationTree["parameters/Idle/blend_position"].x = scaled_dir
	else:
		animationTree["parameters/conditions/idle"] = true
		animationTree["parameters/conditions/isMoving"] = false
		animationTree["parameters/Idle/blend_position"].y = velocity.y/JUMP_VELOCITY*-1
		velocity.x = move_toward(velocity.x, 0, SPEED)
	var was_on_floor = is_on_floor()
	recoil.x = lerp(recoil.x,0.0,0.3)
	recoil.y = lerp(recoil.y,0.0,0.3)
	recoil.y = clamp(recoil.y,1*JUMP_VELOCITY,0)
	velocity.y = clamp(velocity.y + recoil.y,1*JUMP_VELOCITY,-10*JUMP_VELOCITY)
	velocity.x = recoil.x + velocity.x
	knockback.x = lerp(knockback.x,0.0,0.3)
	knockback.y = lerp(knockback.y,0.0,0.3)
	velocity.y = velocity.y + knockback.y
	velocity.x = knockback.x + velocity.x
	if move_and_slide():
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			if col.get_collider() is RigidBody2D:
				col.get_collider().apply_force(col.get_normal() * -force)
	if is_on_floor():
		velocity.y = 0
	if (was_on_floor != is_on_floor()):
		coyoteFrame = .05
	else:
		coyoteFrame = max(0,coyoteFrame-delta)
	if HP <= 0:
		die.emit()
