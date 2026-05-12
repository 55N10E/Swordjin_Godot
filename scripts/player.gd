extends CharacterBody2D

@export var speed := 200.0
@export var attack_duration := 0.3
@export var attack_cooldown := 0.4
@export var max_health := 100

var health: int
var is_attacking := false
var attack_timer := 0.0
var cooldown_timer := 0.0
var is_dead := false

@onready var sprite = $Polygon2D
@onready var attack_hitbox = $AttackHitbox/CollisionShape2D
@onready var label = $Label

func _ready():
	add_to_group("player")
	health = max_health
	attack_hitbox.set_deferred("disabled", true)
	_update_label()

func _physics_process(delta):
	if is_dead:
		return
	
	# Cooldown and attack timers
	if attack_timer > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			_end_attack()
	
	if cooldown_timer > 0:
		cooldown_timer -= delta
	
	# Input
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	if input.length() > 0:
		input = input.normalized()
		
		# Face direction  
		if input.x > 0:
			sprite.scale.x = 1
		elif input.x < 0:
			sprite.scale.x = -1
	
	# Attack input
	if Input.is_action_just_pressed("attack") and cooldown_timer <= 0 and not is_attacking:
		_start_attack()
	
	# Movement (only when not attacking, or allow movement during attack — your call)
	if not is_attacking:
		velocity = input * speed
	else:
		velocity = input * speed * 0.5  # Slow while attacking
	
	move_and_slide()

func take_damage(amount: int):
	if is_dead:
		return
	
	health -= amount
	_update_label()
	
	AudioManager.play_sfx("player_hurt")
	
	# Flash red
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	if not is_dead:
		modulate = Color.WHITE
	
	if health <= 0:
		_die()

func _update_label():
	if label:
		label.text = "Player HP: %d/%d" % [health, max_health]

func _die():
	is_dead = true
	print("Player defeated!")
	
	# Death animation placeholder
	modulate = Color.DARK_BLUE
	velocity = Vector2.ZERO
	
	# Disable collision
	$CollisionShape2D.set_deferred("disabled", true)
	attack_hitbox.set_deferred("disabled", true)
	
	# Show death message
	if label:
		label.text = "DEAD — Press R to restart"
	
	# Could restart after delay or wait for input
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		get_tree().reload_current_scene()

func _start_attack():
	is_attacking = true
	attack_timer = attack_duration
	cooldown_timer = attack_duration + attack_cooldown
	attack_hitbox.disabled = false
	
	AudioManager.play_random_pitch("sword_swing", 0.95, 1.05)
	
# Face direction for lunge
	var facing_right = sprite.scale.x >= 0
	var facing = Vector2.RIGHT if facing_right else Vector2.LEFT
	velocity = facing * speed * 2.0
	
	# TODO: play swing animation, spawn VFX, sound
	print("SWING!")

func _end_attack():
	is_attacking = false
	attack_hitbox.disabled = true
	velocity = Vector2.ZERO

func _on_attack_hitbox_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(10)
		AudioManager.play_random_pitch("sword_hit", 0.9, 1.1)
		print("Hit: ", body.name)
