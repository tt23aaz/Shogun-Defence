extends StaticBody2D

var Bullet = preload("res://Towers/arrow.tscn")
var bulletDamage = 5
var pathName
var currTargets = []
var curr


var reload = 0

@warning_ignore("shadowed_global_identifier")
var range = 400

var startShooting = false

@onready var timer = $Upgrade/ProgressBar/Timer
@onready var progress_bar = $Upgrade/ProgressBar
@onready var towerSprite = $ArcherSprite
@onready var aimLeft = $AimLeft
@onready var aimRight = $AimRight


func _ready():
	timer.wait_time = reload
	timer.stop()
	progress_bar.max_value = reload
	progress_bar.value = 0


func _process(_delta: float):
	progress_bar.global_position = self.position + Vector2(-72.0, -128.0)
	if is_instance_valid(curr):
		if curr.global_position.x < global_position.x:
			towerSprite.flip_h = true
		else:
			towerSprite.flip_h = false
		if timer.is_stopped():
			timer.start()
		progress_bar.value = reload - timer.time_left
	else:
		progress_bar.value = 0
		timer.stop()
	update_powers()


func clear_bullets():
	for bullet in get_node("BulletContainer").get_children():
		bullet.queue_free()


func Shoot():
	if curr == null:
		return
	var tempBullet = Bullet.instantiate()
	tempBullet.pathName = pathName
	tempBullet.bulletDamage = bulletDamage
	get_node("BulletContainer").add_child(tempBullet)
	if curr.global_position.x < global_position.x:
		tempBullet.global_position = aimLeft.global_position
	else:
		tempBullet.global_position = aimRight.global_position


func _on_tower_body_entered(body: Node2D) -> void:
	if "EnemyArcher" in body.name:
		update_current_target()


func _on_tower_body_exited(_body: Node2D) -> void:
	update_current_target()


func update_current_target() -> void:
	var tempArray = []
	currTargets = get_node("Tower").get_overlapping_bodies()

	for i in currTargets:
		if "Enemy" in i.name:
			tempArray.append(i)

	var currTarget = null

	for i in tempArray:
		if currTarget == null:
			currTarget = i.get_node("../")
		else:
			if i.get_parent().get_progress() > currTarget.get_progress():
				currTarget = i.get_node("../")

	curr = currTarget

	if curr != null:
		pathName = curr.get_parent().name
		if timer.is_stopped():
			timer.start()
	else:
		timer.stop()
		progress_bar.value = 0


func _on_timer_timeout() -> void:
	if is_instance_valid(curr):
		Shoot()
		timer.start()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var towerPath = get_tree().get_root().get_node("Main/Towers")
		for i in towerPath.get_child_count():
			if towerPath.get_child(i).name != self.name:
				towerPath.get_child(i).get_node("Upgrade/Upgrade").hide()
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
	range += 30


func _on_attack_speed_pressed() -> void:
	if reload <= 2:
		reload += 0.1
	timer.wait_time = 3 - reload


func _on_power_pressed() -> void:
	bulletDamage += 1

func update_powers():
	get_node("Upgrade/Upgrade/HBoxContainer/Power/Label").text = str(bulletDamage)
	get_node("Upgrade/Upgrade/HBoxContainer/AttackSpeed/Label").text = str(3 - reload)
	get_node("Upgrade/Upgrade/HBoxContainer/Range/Label").text = str(range)
	
	get_node("Tower/CollisionShape2D2").shape.radius = range

func _on_range_mouse_entered() -> void:
	get_node("Tower/CollisionShape2D2").show()


func _on_range_mouse_exited() -> void:
	get_node("Tower/CollisionShape2D2").hide()
