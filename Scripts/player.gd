extends Node2D

# combat
var hp := 3
var can_be_hit := true
var hit_timer := 0.5
var hit_timer_interval := 0.0

# movement
@export var turn_speed := 10.0 # degrees per second
var velocity := Vector2.ZERO
var acceleration := 10.0
var max_speed := 85.0
var friction := 50.0

# spear-related
@onready var spear_scene = preload("res://Scenes/spear.tscn")
@onready var spear_spawner = $SpearSpawn
var can_shoot := true
var cooldown := 5.0
var cooldown_timer := 0.0

# ui-related
@onready var cooldown_label = $"../UI/CooldownLabel"
@onready var sprite := $"Sprite2D"
var original_modulate = null

func _ready() -> void:
	cooldown_label.text = ""
	original_modulate = sprite.modulate

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if can_shoot:
			_launch_spear(get_global_mouse_position())
			can_shoot = false
			cooldown_timer = cooldown

func _physics_process(delta: float) -> void:
	if not can_shoot:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_shoot = true
			
	if not can_be_hit:
		hit_timer_interval += delta
		if hit_timer_interval >= hit_timer:
			can_be_hit = true
			hit_timer_interval = 0.0
	
	_movement(delta)

func _process(_delta: float) -> void:
	_update_cooldown_label()
	
func _movement(delta: float):
	var input_dir = -transform.y
	if Input.is_action_pressed("speed_up"):
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
	elif Input.is_action_pressed("slow_down"):
		turn_speed = 25.0
		velocity = velocity.move_toward(input_dir * (max_speed * .25), acceleration * delta)
	else:
		turn_speed = 10.0
		velocity = velocity.move_toward(input_dir * (max_speed  * .5), acceleration * delta)

	if Input.is_action_pressed("turn_left"):
		rotation -= deg_to_rad(turn_speed) * delta

	if Input.is_action_pressed("turn_right"):
		rotation += deg_to_rad(turn_speed) * delta
		
	position += velocity * delta

func _launch_spear(mouse_pos: Vector2) -> void:
	var spear = spear_scene.instantiate()
	get_tree().current_scene.add_child(spear)
	
	var global_spawn_pos = spear_spawner.global_position
	spear.global_position = global_spawn_pos
	
	var dir = (mouse_pos - global_spawn_pos).normalized()
	spear.direction = dir
	
	spear.rotation = dir.angle() + deg_to_rad(90) # aka PI / 2
	
func _update_cooldown_label():
	var mouse_pos = get_viewport().get_mouse_position()
	cooldown_label.position = mouse_pos + Vector2(10, 10)
	
	if not can_shoot:
		cooldown_label.text = str(cooldown_timer).pad_decimals(1)
	else:
		cooldown_label.text = ""
		
func take_damage():
	if not can_be_hit:
		return
		
	hp -= 1
	can_be_hit = false
	$Sprite2D.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	$Sprite2D.modulate = original_modulate
	
	
	if hp <= 0:
		_die()
		
func _die():
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn")
