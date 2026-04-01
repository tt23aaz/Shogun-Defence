extends CharacterBody2D

var target = null
var Speed = 1000
var path_name = ""
var bullet_damage = 5


func _physics_process(_delta: float) -> void:
	var path_spawner_node = get_tree().get_root().get_node("Main/PathSpawner")
	target = null
	
	for i in range(path_spawner_node.get_child_count()):
		if path_spawner_node.get_child(i).name == path_name:
			target = path_spawner_node.get_child(i).get_child(0).get_child(0).global_position
			break
			
	if target == null:
		queue_free()
		return

	velocity = global_position.direction_to(target) * Speed
	look_at(target)
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if "Enemy" in body.name:
		body.Health -= bullet_damage
		queue_free()
