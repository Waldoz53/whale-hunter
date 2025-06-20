extends Node

@export var spawn_radius := 500.0
@export var spawn_interval := 4.0
@export var 	whale_scene : PackedScene
var 	spawn_timer := 0.0

@onready var player = $"../Player"

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_whale()
		
func _spawn_whale():
	var whale = whale_scene.instantiate()
	get_tree().current_scene.add_child(whale)
	
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	whale.global_position = player.global_position + offset
	
	var hp = randi_range(1, 10)
	var speed = randf_range(20.0, 50.0)
	var scale = randf_range(0.8, 2.5)
	
	whale.hp = hp
	whale.speed = speed
	whale.base_scale = scale
	
