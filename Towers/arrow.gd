extends CharacterBody2D

# The arrow starts as null because it does not know whhere to go yet
var target = null

# The speed of the arrow
var Speed = 1000

# This is the name of the path that the arrow shoots to
var path_name = ""

# This is the damage of the arrow
var bullet_damage = 5


func _physics_process(_delta: float) -> void:
	# This gets the path node from the main scene and this is where the bullet is shooting 
	var path_spawner_node = get_tree().get_root().get_node("Main/PathSpawner")
	
	# 
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
