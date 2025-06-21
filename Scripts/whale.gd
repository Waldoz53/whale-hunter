extends Area2D
class_name Whale

@export var speed := 30.0
@export var hp := 3
@export var base_scale := 1.0
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
var reaction_speed := 120.0

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
			target_velocity = direction * speed
		ReactionState.FLEEING, ReactionState.ATTACKING:
			target_velocity = direction * reaction_speed
			
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	position += velocity * delta
			
	if direction.length() > 0.01:
		var target_angle = direction.angle() + PI / 2
		rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
		
	if hp <= 0:
		_die()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("spears"):
		call_deferred("_lodge_spear", area)
	elif area.name == "Player":
		area.take_damage()
		hp -= 1
	else:
		return

func _lodge_spear(spear):
	hp -= 1
	
	if speed > 10:
		speed -= 10
	if reaction_speed > 10:
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
	await get_tree().create_timer(10.0).timeout
	state = ReactionState.IDLE
		
func _attack():
	state = ReactionState.ATTACKING
	if is_instance_valid(player):
		var player_pos = player.global_position
		direction = (player_pos - global_position).normalized()
	await get_tree().create_timer(10.0).timeout
	state = ReactionState.IDLE

func set_up_stats(is_white: bool):
	if is_white:
		hp = 10
		speed = 60.0
		base_scale = 2.5
		is_white_whale = true
		_apply_white_whale_sprite()
		player.track_whale(self)
		$"../UI/LogLabel".text = "The white whale is near..."
		await get_tree().create_timer(5.0).timeout
		$"../UI/LogLabel".text = ""
	else:
		hp = randi_range(1, 10)
		speed = randf_range(20.0, 50.0)
		base_scale = randf_range(0.8, 1.5)
		
	main_sprite.scale = Vector2.ONE * base_scale
	dead_sprite.scale = Vector2.ONE * base_scale
	$CollisionShape2D.scale = Vector2.ONE * base_scale
		
func _apply_white_whale_sprite():
	main_sprite.texture = preload("res://Tiles/whale_hunter Sprites/white_whale_ALIVE.png")
	dead_sprite.texture = preload("res://Tiles/whale_hunter Sprites/white_whale_DEAD.png")

func _die():
	player.hp += 1
	
	is_dead = true
	direction = Vector2.ZERO 
	
	dead_sprite.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(dead_sprite, "modulate:a", 1.0, 1.5)
	await get_tree().create_timer(1.5).timeout
	main_sprite.visible = false
	
