extends Node2D

# Preloads the enemy path scenes for each enemy type/stage 
@onready var path_1 = preload("res://mobs/Stage 1.tscn")
@onready var path_2 = preload("res://mobs/Stage 2.tscn")
@onready var path_3 = preload("res://mobs/Stage 3.tscn")
@onready var path_4 = preload("res://mobs/Stage 4.tscn")

# Tracks if the wave is currently being spawned
var spawning_wave := false

# Each wave contains the different enemy types, how many enemies and the delay between each enemy
var waves = [
	[
		{"scene": preload("res://mobs/Stage 1.tscn"), "count": 1, "delay": 2},
		{"scene": preload("res://mobs/Stage 2.tscn"), "count": 1, "delay": 2},
		{"scene": preload("res://mobs/Stage 3.tscn"), "count": 1, "delay": 3},
		{"scene": preload("res://mobs/Stage 4.tscn"), "count": 1, "delay": 4}
	],
	[
		{"scene": preload("res://mobs/Stage 1.tscn"), "count": 7, "delay": 1.3}
	],
	[
		{"scene": preload("res://mobs/Stage 1.tscn"), "count": 8, "delay": 1.2},
		{"scene": preload("res://mobs/Stage 2.tscn"), "count": 2, "delay": 5}
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

# Called when this node enters the scene tree
func _ready() -> void:
	Game.current_wave = 0
	Game.enemy_count = 0
	start_next_wave()


func start_next_wave() -> void:
	var main = get_tree().current_scene
	# Hides the next wave button when it starts the new wave
	main.get_node("UI/Next wave button").hide()
	
	# Stops starting a new wave if there is one already running
	if spawning_wave:
		return

	# If all waves are finished, mark the map as complete
	if Game.current_wave >= waves.size():
		print("Map Complete")
		return

	# Moves onto the next wave
	Game.current_wave += 1
	var wave_data = waves[Game.current_wave - 1]
	Game.enemy_count = get_total_enemies(wave_data)
	spawning_wave = true

	# Spawns the enemies for the specific wave
	await spawn_wave(wave_data)

	# Marks the spawning as finished after all enemies have been created 
	spawning_wave = false

func get_total_enemies(wave_data: Array) -> int:
	# Counts the total number of enemies given in the wave which is set in the group
	var total := 0
	for group in wave_data:
		total += group["count"]
	return total

# Goes through each group in the wave data, spawns requested number of enemies in that group
# Delay for spawning new enemy
# Creates and adds the path scene to the spawenr 
func spawn_wave(wave_data: Array) -> void:
	for group in wave_data:
		for i in range(group["count"]):
			await get_tree().create_timer(group["delay"]).timeout
			var temp_path = group["scene"].instantiate()
			add_child(temp_path)

# Decreases the enemies count when defeated
func enemy_removed() -> void:
	Game.enemy_count -= 1
	if Game.enemy_count < 0:
		Game.enemy_count = 0

	# If all enemies are gone and no longer spawning show wave complete screen
	if Game.enemy_count == 0 and not spawning_wave:
		if Game.current_wave >= waves.size():
			show_map_complete()
		else:
			show_wave_complete()

# The gold rewards for each wave from 1-10
var wave_rewards = [20, 25, 30, 35, 40, 45, 50, 55, 60, 75]

# Shows the wave completed scene and then 
func show_wave_complete() -> void:
	var main = get_tree().current_scene
	var panel = main.get_node("UI/Wave Completed")
	var next_wave_button = main.get_node("UI/Next wave button")
	
 	# Default reward count
	var reward := 0
	# Get reward for completing the wave
	if Game.current_wave - 1 < wave_rewards.size():
		reward = wave_rewards[Game.current_wave - 1]
	
	# Disable tower placing until next wave starts
	# Gives player gold
	# Show Wave complete and hide mini next wave button
	Game.can_place_towers = false
	Game.Gold += reward
	panel.show()
	next_wave_button.hide()

	# Updates the panel with the wave number, with the certain amount of reward depending on the wave
	panel.get_node("Label").text = "WAVE " + str(Game.current_wave) + " COMPLETED\n\n+" + str(reward) + " Gold"
	
	# Changes to map compelete scene when the map is completed 
func show_map_complete() -> void:
	var _main = get_tree().current_scene
	var _panel = get_tree().change_scene_to_file("res://map_complete.tscn")
