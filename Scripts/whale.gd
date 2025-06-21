extends Area2D
class_name Whale

@export var speed := 30.0
@export var hp := 3
@export var base_scale := 1.0
var current_speed := 0.0
var is_dead := false
var rotation_speed := 5.0
var direction := Vector2.ZERO
var velocity := Vector2.ZERO
var target_velocity := Vector2.ZERO
var acceleration := 400.0
var friction = 50.0
var is_white_whale = false

enum ReactionState { IDLE, FLEEING, ATTACKING }
var state := ReactionState.IDLE
var reaction_speed := 90.0

@onready var main_sprite := $MainSprite
@onready var dead_sprite := $DeadSprite
@onready var player := $"../Player"
var original_modulate = null

func _ready():
	direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	original_modulate = main_sprite.modulate
	
func _physics_process(delta: float) -> void:
	match state:
		ReactionState.IDLE:
			current_speed = move_toward(current_speed, speed, acceleration * delta)
		ReactionState.FLEEING, ReactionState.ATTACKING:
			current_speed = move_toward(current_speed, reaction_speed, acceleration * delta)
			
	velocity = direction * current_speed
	position += velocity * delta
			
	if direction.length() > 0.01:
		var target_angle = direction.angle() + PI / 2
		rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("spears") and not is_dead:
		call_deferred("_lodge_spear", area)
	elif area.name == "Player":
		area.take_damage()
		if not is_dead:
			hp -= 1
	else:
		return

func _lodge_spear(spear):
	hp -= 1
	
	if hp <= 0:
		_die()

	if reaction_speed > speed:
		reaction_speed -= 10
		
	spear.direction = Vector2.ZERO
	spear.set_process(false)
	spear.set_physics_process(false)
	
	spear.remove_from_group("spears")
	
	var xform = spear.global_transform
	spear.get_parent().remove_child(spear)
	add_child(spear)
	
	spear.global_transform = xform
	
	if state != ReactionState.IDLE:
		return
		
	if is_white_whale:
		_attack()
	else:
		var reaction_roll = randi_range(0, 1)
		if reaction_roll == 0:
			_flee()
		else:
			_attack()
	
	player.track_whale(self)
	$HitSound.play()
	$MainSprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.2).timeout
	$MainSprite.modulate = original_modulate
		
func _flee():
	state = ReactionState.FLEEING
	if is_instance_valid(player):
		var player_pos = player.global_position
		direction = (global_position - player_pos).normalized()
	await get_tree().create_timer(5.0).timeout
	state = ReactionState.IDLE
		
func _attack():
	state = ReactionState.ATTACKING
	if is_instance_valid(player):
		var player_pos = player.global_position
		direction = (player_pos - global_position).normalized()
	await get_tree().create_timer(2.5).timeout
	state = ReactionState.IDLE

func set_up_stats(is_white: bool):
	if is_white:
		hp = 10
		speed = 60.0
		base_scale = 2.5
		is_white_whale = true
		_apply_white_whale_sprite()
		player.track_whale(self)
		$"../UI/LogLabel".text = "A white whale is near..."
	else:
		hp = randi_range(1, 10)
		speed = randf_range(20.0, 50.0)
		base_scale = randf_range(0.8, 1.5)
		
	main_sprite.scale = Vector2.ONE * base_scale
	dead_sprite.scale = Vector2.ONE * base_scale
	$CollisionShape2D.scale = Vector2.ONE * base_scale
	await get_tree().create_timer(5.0).timeout
	$"../UI/LogLabel".text = ""
		
func _apply_white_whale_sprite():
	main_sprite.texture = preload("res://Tiles/whale_hunter Sprites/white_whale_ALIVE.png")
	dead_sprite.texture = preload("res://Tiles/whale_hunter Sprites/white_whale_DEAD.png")

func _die():
	is_dead = true
	$"../.".register_whale_kill()
	set_physics_process(false)
	
	direction = Vector2.ZERO 
	
	dead_sprite.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(dead_sprite, "modulate:a", 1.0, 1.5)
	await get_tree().create_timer(1.5).timeout
	main_sprite.visible = false
	
