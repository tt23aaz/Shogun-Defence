extends Node

# Amount of gold the player has
var Gold = 100

# The health of the player
var Health = 10

# The current wave counter
var current_wave = 0

# The total waves of the map
var total_waves = 10

# The enemy counter
var enemy_count = 0
var can_place_towers = true

# This function resets the stats when the player wants to replay the game.
func reset_stats() -> void:
	Health = 10
	Gold = 100
	current_wave = 0
	total_waves = 10
	enemy_count = 0
	can_place_towers = true
