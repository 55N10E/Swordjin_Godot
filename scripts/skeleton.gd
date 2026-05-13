extends CharacterBody2D

@export var max_health := 30
@export var speed := 80.0
@export var detection_range := 250.0
@export var attack_range := 32.0
@export var attack_damage := 8
@export var attack_cooldown := 1.2
@export var attack_duration := 0.4

var health: int
var player: Node2D = null
var is_attacking := false
var attack_timer := 0.0
var cooldown_timer := 0.0
var is_dead := false

@onready var sprite = $Polygon2D
@onready var attack_hitbox = $AttackHitbox/CollisionShape2D
@onready var detection_area = $DetectionArea
@onready var label = $Label
@onready var health_bar = $HealthBar

func _ready():
	health = max_health
	attack_hitbox.set_deferred("disabled", true)
	_update_label()
	
	# Find player in scene
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if is_dead:
		return
	
	# Timers
	if attack_timer > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			_end_attack()
	
	if cooldown_timer > 0:
		cooldown_timer -= delta
	
	if not player or player.is_dead:
		return
	
	var to_player = player.global_position - global_position
	var dist = to_player.length()
	
	# Face player
	if to_player.x > 0:
		sprite.scale.x = 1
	elif to_player.x < 0:
		sprite.scale.x = -1
	
	# Chase if in range
	if dist <= detection_range and dist > attack_range:
		var dir = to_player.normalized()
		velocity = dir * speed
	elif dist <= attack_range and cooldown_timer <= 0 and not is_attacking:
		_start_attack()
		velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func _start_attack():
	is_attacking = true
	attack_timer = attack_duration
	cooldown_timer = attack_duration + attack_cooldown
	attack_hitbox.disabled = false
	
	AudioManager.play_random_pitch("sword_swing", 0.85, 1.15)
	
	# Small lunge toward player
	if player:
		var to_player = (player.global_position - global_position).normalized()
		velocity = to_player * speed * 1.5
	
	print("Skeleton attacks!")

func _end_attack():
	is_attacking = false
	attack_hitbox.disabled = true
	velocity = Vector2.ZERO

func take_damage(amount: int):
	if is_dead:
		return
	
	health -= amount
	_update_label()
	
	AudioManager.play_random_pitch("sword_hit", 0.9, 1.1)
	
	# Flash red
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	if not is_dead:
		modulate = Color.WHITE
	
	if health <= 0:
		_die()

func _update_label():
	if label:
		label.text = "HP: %d/%d" % [health, max_health]
	if health_bar:
		health_bar.update_health(health, max_health)

func _die():
	is_dead = true
	print("Skeleton defeated!")
	
	AudioManager.play_sfx("skeleton_death")
	
	# Death animation placeholder
	modulate = Color.DARK_GRAY
	velocity = Vector2.ZERO
	
	# Disable collision
	$CollisionShape2D.set_deferred("disabled", true)
	attack_hitbox.set_deferred("disabled", true)
	
	# Remove after delay
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_attack_hitbox_body_entered(body):
	if body.has_method("take_damage") and body != self:
		body.take_damage(attack_damage)
		print("Skeleton hit: ", body.name)

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body):
	if body.is_in_group("player") and body == player:
		player = null
