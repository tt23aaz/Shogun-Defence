extends Node2D

@onready var path_1 = preload("res://mobs/Stage 1.tscn")
@onready var path_2 = preload("res://mobs/Stage 2.tscn")
@onready var path_3 = preload("res://mobs/Stage 3.tscn")
@onready var path_4 = preload("res://mobs/Stage 4.tscn")

func _on_timer_timeout() -> void:
	$Timer.stop()

	for i in range(1):
		var temp_path = path_1.instantiate()
		add_child(temp_path)
		await get_tree().create_timer(3.0).timeout

	for i in range(1):
		var temp_path_2 = path_2.instantiate()
		add_child(temp_path_2)
		await get_tree().create_timer(3.0).timeout
		
	for i in range(1):
		var temp_path_3 = path_3.instantiate()
		add_child(temp_path_3)
		await get_tree().create_timer(3.0).timeout
		
	for i in range(1):
		var temp_path_4 = path_4.instantiate()
		add_child(temp_path_4)
		await get_tree().create_timer(3.0).timeout
