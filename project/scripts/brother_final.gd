extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func appear_at(pos: Vector2) -> void:
	global_position = pos
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	if anim:
		anim.play("idle")
