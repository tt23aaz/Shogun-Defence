extends StaticBody2D

var Bullet = preload("res://Towers/shuriken.tscn")
var bullet_damage = 5
var path_name
var curr_targets = []
var current


var reload = 0

@warning_ignore("shadowed_global_identifier")
var range = 400

var range_cost = 10
var attack_speed_cost = 15
var power_cost = 20

var start_shooting = false

@onready var timer = $Upgrade/ProgressBar/Timer
@onready var progress_bar = $Upgrade/ProgressBar
@onready var tower_sprite = $NinjaSprite
@onready var aim_left = $AimLeft
@onready var aim_right = $AimRight


func _ready():
	timer.wait_time = reload
	timer.stop()
	progress_bar.max_value = reload
	progress_bar.value = 0


func _process(_delta: float):
	progress_bar.global_position = self.position + Vector2(-72.0, -128.0)
	if is_instance_valid(current):
		if current.global_position.x < global_position.x:
			tower_sprite.flip_h = true
		else:
			tower_sprite.flip_h = false
		if timer.is_stopped():
			timer.start()
		progress_bar.value = reload - timer.time_left
	else:
		progress_bar.value = 0
		timer.stop()
		update_current_target()
	update_powers()


func clear_bullets():
	for bullet in get_node("BulletContainer").get_children():
		bullet.queue_free()


func Shoot() -> void:
	if current == null:
		return
	var temp_bullet = Bullet.instantiate()
	temp_bullet.path_name = path_name
	temp_bullet.bullet_damage = bullet_damage
	get_node("BulletContainer").add_child(temp_bullet)
	if current.global_position.x < global_position.x:
		temp_bullet.global_position = aim_left.global_position
	else:
		temp_bullet.global_position = aim_right.global_position


func _on_tower_body_entered(body: Node2D) -> void:
	if "Enemy" in body.name:
		update_current_target()


func _on_tower_body_exited(_body: Node2D) -> void:
	update_current_target()


func update_current_target() -> void:
	var temp_array = []
	curr_targets = get_node("Tower").get_overlapping_bodies()

	for i in curr_targets:
		if "Enemy" in i.name:
			temp_array.append(i)

	var curr_target = null

	for i in temp_array:
		if curr_target == null:
			curr_target = i.get_node("../")
		else:
			if i.get_parent().get_progress() > curr_target.get_progress():
				curr_target = i.get_node("../")

	current = curr_target

	if current != null:
		path_name = current.get_parent().name
		if timer.is_stopped():
			timer.start()
	else:
		timer.stop()
		progress_bar.value = 0


func _on_timer_timeout() -> void:
	if is_instance_valid(current):
		Shoot()
		timer.start()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var tower_path = get_tree().get_root().get_node("Main/Towers")
		for i in tower_path.get_child_count():
			if tower_path.get_child(i).name != self.name:
				tower_path.get_child(i).get_node("Upgrade/Upgrade").hide()
		var panel = get_node("Upgrade/Upgrade")
		panel.visible = !panel.visible
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


func _on_range_pressed() -> void:
	if Game.Gold >= range_cost:
		Game.Gold -= range_cost
		range += 30
		range_cost += 5


func _on_attack_speed_pressed() -> void:
	if Game.Gold >= attack_speed_cost:
		Game.Gold -= attack_speed_cost
		if reload <= 2:
			reload += 0.1
		timer.wait_time = 3 - reload
		attack_speed_cost += 5


func _on_power_pressed() -> void:
	if Game.Gold >= power_cost:
		Game.Gold -= power_cost
		bullet_damage += 1
		power_cost += 5

func update_powers() -> void:
	get_node("Upgrade/Upgrade/HBoxContainer/Power/Label").text = str(bullet_damage)
	get_node("Upgrade/Upgrade/HBoxContainer/AttackSpeed/Label").text = str(3 - reload)
	get_node("Upgrade/Upgrade/HBoxContainer/Range/Label").text = str(range)

	get_node("Upgrade/Upgrade/HBoxContainer/Power/Label3").text = "Cost: " + str(power_cost)
	get_node("Upgrade/Upgrade/HBoxContainer/AttackSpeed/Label3").text = "Cost: " + str(attack_speed_cost)
	get_node("Upgrade/Upgrade/HBoxContainer/Range/Label2").text = "Cost: " + str(range_cost)

	get_node("Tower/CollisionShape2D2").shape.radius = range

func _on_range_mouse_entered() -> void:
	get_node("Tower/CollisionShape2D2").show()


func _on_range_mouse_exited() -> void:
	get_node("Tower/CollisionShape2D2").hide()
