extends Panel

# Preloads the tower scene that will be placed by dragging from this panel
@onready var tower = preload("res://Towers/tower_samurai.tscn")
var curr_tile

# this stores the tile currently under the mouse while placing a tower
func _on_gui_input(event: InputEvent):
	# it stops immediately if tower placement is currently disabled
	if not Game.can_place_towers:
		return
		
	# Only allows placement if the player has enough gold
	if Game.Gold >= 50:
		var temp_tower = tower.instantiate()
		if event is InputEventMouseButton and event.button_mask == 1:
			#left click down
			add_child(temp_tower)
			
			# Disables the processing on the preview tower while it is being placed
			temp_tower.process_mode = Node.PROCESS_MODE_DISABLED
			# scales the tower to the desired size
			temp_tower.scale = Vector2(0.32,0.32)
			
		# Detects mouse movement while left button being held down
		elif event is InputEventMouseMotion and event.button_mask == 1:
			#left click down drag
			if get_child_count() > 1:
				# Moves the preview tower where the mouse cursor is
				get_child(1).global_position = event.global_position
				
				# Accesses the tile map to check what the mouse is hovering
				var map_path = get_tree().get_root().get_node("Main/TileMap")
				var tile = map_path.local_to_map(get_global_mouse_position())
				# Gets the atlas coordinates
				curr_tile = map_path.get_cell_atlas_coords(0, tile, false)
				
				# Checks if the preview is overlapping any other bodies
				var targets = get_child(1).get_node("TowerDetector").get_overlapping_bodies()
				print(targets)
				# Checks if the preview tower is on the correct tile type and if not then it turns red 
				if(curr_tile == Vector2i(1,1)):
					if (targets.size() > 0):
						get_child(1).get_node("Area").modulate = Color(255,0,0,0.3)
					else:
						get_child(1).get_node("Area").modulate = Color(0,255,0,0.3)
				else:
					get_child(1).get_node("Area").modulate = Color(255,0,0,0.3)
		# Detects left mouse button release
		elif event is InputEventMouseButton and event.button_mask == 0:
			#left click up
			
			# If released over the screen or UI area on the far right, cancels placement 
			if event.global_position.x >= 3584:
				if get_child_count() > 1:
					get_child(1).queue_free()
			else:
				# Removes the preview tower from the panel 
				if get_child_count() > 1:
					get_child(1).queue_free()
				# If current tile is valid for placement
				if curr_tile == Vector2i(1,1):
					var path = get_tree().get_root().get_node("Main/Towers")
					
					# Checks if any overlapping occurs 
					var targets = get_child(1).get_node("TowerDetector").get_overlapping_bodies()
					
					# If nothing overlaps place the real tower
					if (targets.size() < 1):
						path.add_child(temp_tower)
						temp_tower.global_position = event.global_position
						
						# Hides the placement area after placing
						temp_tower.get_node("Area").hide()
						
						# Takes 50 gold from the players gold resources 
						Game.Gold -= 50
		else: 
			# Any other input case, remove preview tower
			if get_child_count() > 1:
				get_child(1).queue_free()
