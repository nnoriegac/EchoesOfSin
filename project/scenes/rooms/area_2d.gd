extends Area2D


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GameState.set_flag("entered_save_room_once", true)
