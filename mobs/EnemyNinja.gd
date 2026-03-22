extends ProgressBar

func _ready() -> void:
	self.max_value = get_parent().Health
	
func _process(delta: float) -> void:
	self.value = get_parent().Health
