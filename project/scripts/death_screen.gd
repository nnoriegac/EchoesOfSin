extends Control

func _ready():
	$Button.pressed.connect(_on_retry_pressed)

func _on_retry_pressed():
	get_tree().reload_current_scene()
