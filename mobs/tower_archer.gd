extends StaticBody2D


var Bullet = preload("res://mobs/arrow.tscn")
var bulletDamage = 5
var pathName
var currTargets = []
var curr

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
		pathName = currTarget.get_parent().name
		
		var tempBullet = Bullet.instantiate()
		tempBullet.pathName = pathName
		tempBullet.bulletDamage = bulletDamage
		get_node("BulletContainer").add_child(tempBullet)
		tempBullet.global_position = $Aim.global_position
		


func _on_tower_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
