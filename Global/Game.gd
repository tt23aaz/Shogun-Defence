extends Node

var Gold = 100
var Health = 10
var current_wave = 0
var total_waves = 10
var enemy_count = 0
var can_place_towers = true

func reset_stats() -> void:
	Health = 10
	Gold = 100
	current_wave = 0
	total_waves = 10
	enemy_count = 0
	can_place_towers = true
