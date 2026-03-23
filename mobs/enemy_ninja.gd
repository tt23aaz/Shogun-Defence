extends CharacterBody2D

@export var speed = 100
var Health = 10

func _process(delta: float) -> void:
	get_parent().set_progress(get_parent().get_progress() + speed * delta)

	if get_parent().get_progress_ratio() >= 1.0:
		Game.Health -= 1
		get_tree().current_scene.get_node("PathSpawner").enemy_removed()

		if Game.Health <= 0:
			get_tree().change_scene_to_file("res://lose_menu.tscn")
			return

		death()

	if Health <= 0:
		Game.Gold += 5
		get_tree().current_scene.get_node("PathSpawner").enemy_removed()
		death()

func death():
	get_parent().get_parent().queue_free()
