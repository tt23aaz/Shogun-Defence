extends StaticBody2D

var Bullet = preload("res://Towers/arrow.tscn")
var bulletDamage = 5
var pathName
var currTargets = []
var curr

@onready var towerSprite = $ArcherSprite
@onready var aim = $Aim

var aim_offset_x := 0.0


func _ready():
	aim_offset_x = abs(aim.position.x)


func clear_bullets():
	for bullet in get_node("BulletContainer").get_children():
		bullet.queue_free()


func _on_tower_body_entered(body: Node2D) -> void:
	if "EnemyArcher" in body.name:
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
			if curr.global_position.x < global_position.x:
				towerSprite.flip_h = true
				aim.position.x = -aim_offset_x
			else:
				towerSprite.flip_h = false
				aim.position.x = aim_offset_x
			
			pathName = currTarget.get_parent().name
			
			var tempBullet = Bullet.instantiate()
			tempBullet.pathName = pathName
			tempBullet.bulletDamage = bulletDamage
			get_node("BulletContainer").add_child(tempBullet)
			tempBullet.global_position = aim.global_position


func _on_tower_body_exited(body: Node2D):
	currTargets = get_node("Tower").get_overlapping_bodies()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_mask == 1:
		var towerPath = get_tree().get_root().get_node("Main/Towers")
		for i in towerPath.get_child_count():
			if towerPath.get_child(i).name != self.name:
				towerPath.get_child(i).get_node("Upgrade/Upgrade").hide()
		get_node("Upgrade/Upgrade").visible = !get_node("Upgrade/Upgrade").visible
		get_node("Upgrade/Upgrade").global_position = self.position + Vector2(-572,81)
