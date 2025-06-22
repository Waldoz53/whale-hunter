extends Control

#signal quote_closed

@onready var label = $QuoteLabel

func show_quote(text: String):
	label.text = text
	visible = true
	get_tree().paused = true
	$QuoteMusic.play()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		visible = false
		get_tree().paused = false
		$QuoteMusic.stop()
		#emit_signal("quote_closed")
