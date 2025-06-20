extends CanvasLayer

@onready var tracking_arrow = $TrackingArrow
@onready var player = $"../Player"

func _process(delta):
	if player.tracked_whale and player.tracked_whale.is_inside_tree():
		var player_pos = player.global_position
		var whale_pos = player.tracked_whale.global_position
		var dir = whale_pos - player_pos

		tracking_arrow.rotation = dir.angle() + PI / 2

		var dist = dir.length()
		tracking_arrow.modulate.a = clamp((dist - 100) / 300, 0.0, 1.0)
	else:
		tracking_arrow.modulate.a = 0.0
