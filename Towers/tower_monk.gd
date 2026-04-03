extends StaticBody2D

# Preloads the monkball scene
var Bullet = preload("res://Towers/monkball.tscn")

# The damage of each monkball hit will deal
var bullet_damage = 15

# Stores the name of the path the current target is following
var path_name

# Lists the current objects that are in the towers detection area
var curr_targets = []

# the enemy/pathfollow node currently being targeted
var current

# Reload progress bar to control attack speed
var reload = 0

# The towers range 
var tower_range = 400

# The upgrade costs of the range
var range_cost = 10

# The upgrade cost of attack speed
var attack_speed_cost = 15

# The upgrade cost of power
var power_cost = 20

# Caching node references for convenience 
@onready var timer = $Upgrade/ProgressBar/Timer
@onready var progress_bar = $Upgrade/ProgressBar
@onready var tower_sprite = $MonkSprite
@onready var aim_left = $AimLeft
@onready var aim_right = $AimRight


# The timer for the progress bar when tower is created
func _ready():
	timer.wait_time = reload
	timer.stop()
	progress_bar.max_value = reload
	progress_bar.value = 0


func _process(_delta: float):
	# Keeps the reload bar above the tower
	progress_bar.global_position = self.position + Vector2(-72.0, -128.0)
	
	# If there is a valid targent the sprite will flip
	if is_instance_valid(current):
		if current.global_position.x < global_position.x:
			tower_sprite.flip_h = true
		else:
			tower_sprite.flip_h = false
			
		# If the timer is stopped it starts again
		if timer.is_stopped():
			timer.start()
		# Shows the reload progress on the bar
		progress_bar.value = reload - timer.time_left
	else:
		progress_bar.value = 0
		timer.stop()
		
		# Tries to find a new target
		update_current_target()
	# Updates the labels and collision range every frame
	update_powers()

# Removes all the monkballs in the bullet container
func clear_bullets():
	for bullet in get_node("BulletContainer").get_children():
		bullet.queue_free()



func Shoot() -> void:
	# Doesnt shoot if there is no current target
	if current == null:
		return
	
	# Create a new bullet instance
	var temp_bullet = Bullet.instantiate()
	# Pass target path and damage data to the monkball
	temp_bullet.path_name = path_name
	temp_bullet.bullet_damage = bullet_damage
	
	# Adds the monkball in the bullet container
	get_node("BulletContainer").add_child(temp_bullet)
	
	# The monkball is aimed and will shoot out of the left or right position 
	if current.global_position.x < global_position.x:
		temp_bullet.global_position = aim_left.global_position
	else:
		temp_bullet.global_position = aim_right.global_position

# If an enemy enters the toewers range
func _on_tower_body_entered(body: Node2D) -> void:
	if "Enemy" in body.name:
		update_current_target()

# If an enemy leaves the towers range updates the next target if there is
func _on_tower_body_exited(_body: Node2D) -> void:
	update_current_target()

# Temp array to store valid enemy bodies
func update_current_target() -> void:
	var temp_array = []
	# Get all bodies currently overlapping the tower's detection area
	curr_targets = get_node("Tower").get_overlapping_bodies()

# Filter overlapping bodies so only enemies are considered
	for i in curr_targets:
		if "Enemy" in i.name:
			temp_array.append(i)

	# This will hold the enemy/pathfollow node that has progressed the furthest
	var curr_target = null

# Select the enemy that is furthest along the path
	for i in temp_array:
		if curr_target == null:
			curr_target = i.get_node("../")
		else:
			if i.get_parent().get_progress() > curr_target.get_progress():
				curr_target = i.get_node("../")
	# Stores the current target
	current = curr_target

	if current != null:
		# Save the path name of the current target for bullet tracking
		path_name = current.get_parent().name
		# Starts reload time
		if timer.is_stopped():
			timer.start()
	else:
		# Stops firing if no target is found
		timer.stop()
		progress_bar.value = 0

# When the timer finishes it fires at the target if it still exists then restarts timer for next shot
func _on_timer_timeout() -> void:
	if is_instance_valid(current):
		Shoot()
		timer.start()
		

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Open or close the upgrade panel when the tower is left-clicked
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var tower_path = get_tree().get_root().get_node("Main/Towers")
		# Hide the upgrade panels of all other towers
		for i in tower_path.get_child_count():
			if tower_path.get_child(i).name != self.name:
				tower_path.get_child(i).get_node("Upgrade/Upgrade").hide()
				
		# Toggle this towers upgrade panel
		var panel = get_node("Upgrade/Upgrade")
		panel.visible = !panel.visible
		
	# If the panel is now visible position it on screen
		if panel.visible:
			await get_tree().process_frame
			var viewport_size = get_viewport_rect().size
			var panel_size = panel.size
			var margin = 8.0
			var offset_y = 80.0
			var panel_x = global_position.x - panel_size.x / 2.0
			var panel_y = global_position.y + offset_y
			panel_x = clamp(panel_x, margin, viewport_size.x - panel_size.x - margin)
			panel_y = clamp(panel_y, margin, viewport_size.y - panel_size.y - margin)
			panel.global_position = Vector2(panel_x, panel_y)


# Upgrade tower range if enough gold
func _on_range_pressed() -> void:
	if Game.Gold >= range_cost:
		Game.Gold -= range_cost
		tower_range += 30
		range_cost += 5

# Upgrade tower attack speed if enough gold
func _on_attack_speed_pressed() -> void:
	if Game.Gold >= attack_speed_cost:
		Game.Gold -= attack_speed_cost
		if reload <= 2:
			reload += 0.1
		timer.wait_time = 3 - reload
		attack_speed_cost += 5

# Upgrade tower power if enough gold
func _on_power_pressed() -> void:
	if Game.Gold >= power_cost:
		Game.Gold -= power_cost
		bullet_damage += 1
		power_cost += 5


func update_powers() -> void:
	# Update the displayed upgrade values in the towers UI
	get_node("Upgrade/Upgrade/HBoxContainer/Power/Label").text = str(bullet_damage)
	get_node("Upgrade/Upgrade/HBoxContainer/AttackSpeed/Label").text = str(3 - reload)
	get_node("Upgrade/Upgrade/HBoxContainer/Range/Label").text = str(tower_range)

	# Update the displayed upgrade costs
	get_node("Upgrade/Upgrade/HBoxContainer/Power/Label2").text = "Cost: " + str(power_cost)
	get_node("Upgrade/Upgrade/HBoxContainer/AttackSpeed/Label3").text = "Cost: " + str(attack_speed_cost)
	get_node("Upgrade/Upgrade/HBoxContainer/Range/Label3").text = "Cost: " + str(range_cost)

	# Apply the towers current range to the collision shape radius
	get_node("Tower/CollisionShape2D2").shape.radius = tower_range

# Show the towers range indicator when hovering over the range upgrade
func _on_range_mouse_entered() -> void:
	get_node("Tower/CollisionShape2D2").show()

# Hide the towers range indicator when the mouse leaves the range upgrade
func _on_range_mouse_exited() -> void:
	get_node("Tower/CollisionShape2D2").hide()
