extends Node2D

@onready var path_1 = preload("res://mobs/Stage 1.tscn")
@onready var path_2 = preload("res://mobs/Stage 2.tscn")
@onready var path_3 = preload("res://mobs/Stage 3.tscn")
@onready var path_4 = preload("res://mobs/Stage 4.tscn")

var spawning_wave := false


var waves = [
	[
		{"scene": preload("res://mobs/Stage 1.tscn"), "count": 5, "delay": 1.5}
	],
	[
		{"scene": preload("res://mobs/Stage 1.tscn"), "count": 7, "delay": 1.3}
	],
	[
		{"scene": preload("res://mobs/Stage 1.tscn"), "count": 8, "delay": 1.2},
		{"scene": preload("res://mobs/Stage 2.tscn"), "count": 2, "delay": 1.5}
	],
	[
		{"scene": preload("res://mobs/Stage 1.tscn"), "count": 10, "delay": 1.1},
		{"scene": preload("res://mobs/Stage 4.tscn"), "count": 2, "delay": 1.5}
	],
	[
		{"scene": preload("res://mobs/Stage 1.tscn"), "count": 8, "delay": 1.0},
		{"scene": preload("res://mobs/Stage 2.tscn"), "count": 4, "delay": 1.3}
	],
	[
		{"scene": preload("res://mobs/Stage 1.tscn"), "count": 8, "delay": 1.0},
		{"scene": preload("res://mobs/Stage 4.tscn"), "count": 4, "delay": 1.5},
		{"scene": preload("res://mobs/Stage 3.tscn"), "count": 2, "delay": 1.2}
	],
	[
		{"scene": preload("res://mobs/Stage 1.tscn"), "count": 10, "delay": 0.9},
		{"scene": preload("res://mobs/Stage 2.tscn"), "count": 5, "delay": 1.2}
	],
	[
		{"scene": preload("res://mobs/Stage 1.tscn"), "count": 14, "delay": 0.8}
	],
	[
		{"scene": preload("res://mobs/Stage 1.tscn"), "count": 12, "delay": 0.8},
		{"scene": preload("res://mobs/Stage 2.tscn"), "count": 8, "delay": 1.0}
	],
	[
		{"scene": preload("res://mobs/Stage 1.tscn"), "count": 15, "delay": 0.7},
		{"scene": preload("res://mobs/Stage 2.tscn"), "count": 10, "delay": 0.9}
	]
]


func _ready() -> void:
	Game.current_wave = 0
	Game.enemy_count = 0
	start_next_wave()

func start_next_wave() -> void:
	var main = get_tree().current_scene
	main.get_node("UI/Next wave button").hide()

	if spawning_wave:
		return

	if Game.current_wave >= waves.size():
		print("Map Complete")
		return

	Game.current_wave += 1
	var wave_data = waves[Game.current_wave - 1]
	Game.enemy_count = get_total_enemies(wave_data)
	spawning_wave = true

	await spawn_wave(wave_data)

	spawning_wave = false

func get_total_enemies(wave_data: Array) -> int:
	var total := 0
	for group in wave_data:
		total += group["count"]
	return total

func spawn_wave(wave_data: Array) -> void:
	for group in wave_data:
		for i in range(group["count"]):
			var temp_path = group["scene"].instantiate()
			add_child(temp_path)
			await get_tree().create_timer(group["delay"]).timeout


func enemy_removed() -> void:
	Game.enemy_count -= 1
	if Game.enemy_count < 0:
		Game.enemy_count = 0

	if Game.enemy_count == 0 and not spawning_wave:
		if Game.current_wave >= waves.size():
			show_map_complete()
		else:
			show_wave_complete()

var wave_rewards = [20, 25, 30, 35, 40, 45, 50, 55, 60, 75]

func show_wave_complete() -> void:
	var main = get_tree().current_scene
	var panel = main.get_node("UI/Wave Completed")
	var next_wave_button = main.get_node("UI/Next wave button")

	var reward := 0
	if Game.current_wave - 1 < wave_rewards.size():
		reward = wave_rewards[Game.current_wave - 1]

	Game.can_place_towers = false
	Game.Gold += reward
	panel.show()
	next_wave_button.hide()

	panel.get_node("Label").text = "WAVE " + str(Game.current_wave) + " COMPLETED\n\n+" + str(reward) + " Gold"
	
func show_map_complete() -> void:
	var main = get_tree().current_scene
	var panel = get_tree().change_scene_to_file("res://map_complete.tscn")
