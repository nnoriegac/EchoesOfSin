extends Area2D

@export var speed: float = 500.0
@export var damage: int = 20
@export var life_time: float = 0.4   # segundos antes de desaparecer

var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Por si acaso, se destruye sola al cabo de un tiempo
	await get_tree().create_timer(life_time).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		return  # ignorar colisión con el jugador

	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
	
	# Tanto si ha dado a un enemigo como si no, la bala desaparece al primer impacto
	queue_free()
