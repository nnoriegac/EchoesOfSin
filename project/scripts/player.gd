extends CharacterBody2D

@export var speed := 200.0

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	velocity = input.normalized()*speed
	move_and_slide()


func _on_item_key_body_entered(body):
	if body.name == "Player":
		var hud = get_parent().get_node("HUD")
		hud.show_message("¡Has recogido el arma!")
		get_parent().get_node("ItemKey").queue_free() # desaparece del mapa
