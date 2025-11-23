extends CanvasLayer

@export var message_duration := 3.0 
@onready var message_label = $Message

func _ready() -> void:
	message_label.visible = false

# muestre mensaje cuando recoges objeto
func show_message(text: String) -> void:
	message_label.text = text
	message_label.visible = true
	await get_tree().create_timer(message_duration).timeout
	message_label.visible = false 	
