extends ProgressBar

# Calls node when enters the scene tree
func _ready() -> void:
	# Parent node with the variable "Health" which sets the progress bar to the maximum value to match it
	self.max_value = get_parent().Health
	
# Called every frame
func _process(delta: float) -> void:
	# Updates the progress bar to the current value of the enemy archers health each damage taken
	self.value = get_parent().Health
