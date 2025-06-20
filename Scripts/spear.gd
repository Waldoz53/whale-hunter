extends Area2D
class_name Spear

@export var speed := 300.0
var direction := Vector2.ZERO
var drag := 300.0
var lifespan := 1.5 # seconds

func _physics_process(delta: float) -> void:
	if speed > 0:
		speed -= drag * delta
		if speed < 0:
			speed = 0
			
	position += direction * speed * delta
	
	lifespan -= delta
	if lifespan < 0.5:
		$Sprite2D.modulate.a = lifespan / 0.5
	if lifespan <= 0:
		queue_free()
