extends CharacterBody2D


# The monkball starts as null because it does not know where to go yet
var target = null

# The speed of the monkball
var Speed = 1000

# This is the name of the path that the monkball shoots to
var path_name = ""

# This is the damage of the monkball
var bullet_damage = 5

func _physics_process(_delta: float) -> void:
	# This gets the path node from the main scene and this is where the monkball is shooting 
	var path_spawner_node = get_tree().get_root().get_node("Main/PathSpawner")
	
	# Resets the target before it checks the path again
	target = null
	
	# This for loop gets the child node from the stages tscn child node Path2D, PathFollow2D, EnemyArcher
	for i in range(path_spawner_node.get_child_count()):
		# Checks if the child node matches monkball path name
		if path_spawner_node.get_child(i).name == path_name:
			# if it matches then it gets the targets global position
			target = path_spawner_node.get_child(i).get_child(0).get_child(0).global_position
			break
			
	# If there is no target found it will delete the monkball
	if target == null:
		queue_free()
		return
	
	# Finds the direction of the target and applies speed
	velocity = global_position.direction_to(target) * Speed
	
	# Monkball then rotates to the target
	look_at(target)
	
	# Moves the Monkball using velocity values
	move_and_slide()

# Checks if the Monkball has touched the enemy
func _on_area_2d_body_entered(body: Node2D) -> void:
	if "Enemy" in body.name:
		body.Health -= bullet_damage
		queue_free()
