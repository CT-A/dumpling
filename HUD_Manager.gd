extends Panel
@onready var hp_bar = get_node("HP_Box/HP_Bar")
@onready var current_gun = get_node("Gun_Box/Current_Gun")
@onready var secondary_gun = get_node("Gun_Box/Secondary_Gun")
@onready var player = get_tree().root.get_node("GameManager/MainScene/Player")
@onready var lvl_text = get_node("Gun_Box/LVL")
@onready var tickets_text = get_node("Gun_Box/Ticket_Icon/Tickets")
@onready var xp = get_node("Gun_Box/XP")
var default_texture
var xp_style = StyleBoxFlat.new()
var default_xp_style = StyleBoxFlat.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect to flash hud when player fails a check
	player.failed_check.connect(_flash_hud)
	# Set the xp bar style to the color from the editor
	default_xp_style = xp.get_theme_stylebox("fill")
	default_xp_style.bg_color = Color.LIME_GREEN
	xp_style = default_xp_style
	# Set the default texture to whatever it is in the editor
	default_texture = current_gun.texture
	# If the player has a gun, lvl is the gun's level. Otherwise, no text at all
	if(player.active_gun != null):
		lvl_text.text = "GUN LVL."+player.active_gun.lvl
	else:
		lvl_text.text = ""
	tickets_text.text = "X"+str(player.tickets)

# Flash the HUD module relevent to the failed check (passed by player signal)
func _flash_hud(module):
	match module:
		"tickets" : flash_tickets()

# Flash the tickets number red to indicate no tickets
func flash_tickets():
	tickets_text.label_settings.font_color = Color.RED
	await get_tree().create_timer(0.1).timeout
	tickets_text.label_settings.font_color = Color.WHITE
	await get_tree().create_timer(0.2).timeout
	tickets_text.label_settings.font_color = Color.RED
	await get_tree().create_timer(0.1).timeout
	tickets_text.label_settings.font_color = Color.WHITE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	# Show number of tickets
	tickets_text.text = "X"+str(player.tickets)
	# Update HP bar to reflect HP
	hp_bar.value = player.HP * 100/player.MAX_HP
	# Update XP bar to reflect XP
	# Set Gun Lvl Text to reflect the level of the active gun
	if(player.active_gun != null):
		# Set XP level to match gun xp
		xp.value = (player.active_gun.xp)*100/player.active_gun.get_xp_to_advance()
		# Gun XP bar style is set to the xp_style
		xp.add_theme_stylebox_override("fill",xp_style)
		lvl_text.text = "GUN LVL."+str(player.active_gun.lvl)
		# Change xp bar if max level to indicate no further xp will be collected
		if (player.active_gun.lvl == player.active_gun.MAX_LVL):
			lvl_text.text = "GUN LVL.MAX"
			xp_style.bg_color = Color.GOLDENROD
		else:
			# Gun isn't max lvl, so make sure the style reflects that
			xp_style.bg_color = Color.LIME_GREEN
	else:
		# No gun, no text
		lvl_text.text = ""
		# Update XP bar to reflect no gun
		xp.value = 0
	# Set the textures of the primary and secondary guns in UI. No gun, use default texture and make it invisible
	if (player.active_gun == null):
		current_gun.texture = default_texture
	else:
		current_gun.texture = player.get_gun_texture()
	if (player.get_secondary() == null):
		secondary_gun.texture = default_texture
	else:
		if (player.get_secondary() == player.active_gun):
			secondary_gun.texture = default_texture
		else:
			secondary_gun.texture = player.get_secondary_texture()
