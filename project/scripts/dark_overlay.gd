extends ColorRect

func _on_ready() -> void:
	if GameState.power_on:
		visible = false
	else:
		visible = true
