extends CharacterBody2D

var damage_number_scene = preload("res://scenes/ui/damage_number.tscn")

@export var speed := 200.0
@export var attack_duration := 0.3          # swing anim time, fixed
var attack_cooldown: float = 0.4            # from GameState weapon
var attack_damage: int = 10                 # from GameState weapon
var max_health := 100

var health: int
var is_attacking := false
var attack_timer := 0.0
var cooldown_timer := 0.0
var is_dead := false

@onready var sprite = $Polygon2D
@onready var attack_hitbox = $AttackHitbox/CollisionShape2D
@onready var label = $Label
@onready var health_bar = $HealthBar

func _ready():
	add_to_group("player")
	_apply_weapon()
	health = max_health
	attack_hitbox.set_deferred("disabled", true)
	_update_label()
	if health_bar:
		health_bar.update_health(health, max_health)

func _apply_weapon():
	var weapon := GameState.get_weapon_stats()
	attack_damage = weapon.get("damage", 10)
	attack_cooldown = weapon.get("cooldown", 0.4)
	max_health = GameState.saved_max_health
	health = GameState.saved_health
	print("Player weapon: %s — DMG %d, Cooldown %.2fs, HP %d/%d" % [GameState.equipped_weapon, attack_damage, attack_cooldown, health, max_health])

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
	
	# Movement (only when not attacking, or allow movement during attack)
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
	show_damage_number(amount)
	
	# Screen shake on heavy hits
	if amount >= 8:
		ScreenShake.shake(3.0, 0.3)
		HitStop.trigger_heavy()
	elif amount >= 5:
		ScreenShake.shake(1.5, 0.2)
		HitStop.trigger_light()
	
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
	if health_bar:
		health_bar.update_health(health, max_health)
	# Auto-save HP state so "Continue" works
	GameState.saved_health = health
	GameState.saved_max_health = max_health

func heal(amount: int):
	# Generic heal — used by potion pickups, merchant, etc.
	if is_dead:
		return
	health = mini(health + amount, max_health)
	_update_label()
	show_damage_number(amount, true)
	AudioManager.play_sfx("ui_click")
	modulate = Color.GREEN
	await get_tree().create_timer(0.2).timeout
	if not is_dead:
		modulate = Color.WHITE

# Backward-compat alias
func merchant_heal(amount: int):
	heal(amount)

func show_damage_number(amount: int, is_heal := false):
	var dn = damage_number_scene.instantiate() as Node2D
	dn.global_position = global_position + Vector2(0, -24)
	get_tree().current_scene.add_child(dn)
	if is_heal:
		dn.setup_heal(amount)
	else:
		dn.setup(amount)

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
		body.take_damage(attack_damage)
		AudioManager.play_random_pitch("sword_hit", 0.9, 1.1)
		HitStop.trigger_light()
		print("Hit: %s for %d DMG with %s" % [body.name, attack_damage, GameState.equipped_weapon])

func get_current_health() -> int:
	return health
