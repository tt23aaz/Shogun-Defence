extends CharacterBody2D

# The speed of the samurai
@export var speed = 100

# The health of the samurai
var Health = 55

# Called every frame
func _process(delta: float) -> void:
	# Moves the enemy forward along the parent PathFollow2D  based on the speed and time frame
	get_parent().set_progress(get_parent().get_progress() + speed * delta)

	# Checks if the enemy has reached the end of the path 
	if get_parent().get_progress_ratio() >= 1.0:
		# Reduces player health if the enemy reaches the end
		Game.Health -= 1
		get_tree().current_scene.get_node("PathSpawner").enemy_removed()

		# Players health less than or equals to 0 it changes to the lose menu screen
		if Game.Health <= 0:
			get_tree().change_scene_to_file("res://lose_menu.tscn")
			return

		# Removes the enemy from the scene
		death()

	# Enemy Health less than equals to 0 then the player is rewarded with gold
	if Health <= 0:
		Game.Gold += 35
		get_tree().current_scene.get_node("PathSpawner").enemy_removed()
		death()

# Removes the enemy from the parent container and deletes it
func death():
	get_parent().get_parent().queue_free()
