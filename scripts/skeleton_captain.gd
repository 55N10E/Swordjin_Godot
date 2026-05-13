extends CharacterBody2D
# SkeletonCaptain — Boss variant with shield + charge attack
# Inherits base skeleton behavior, adds captain mechanics

var damage_number_scene = preload("res://scenes/ui/damage_number.tscn")


@export var max_health := 80
@export var speed := 65.0
@export var detection_range := 280.0
@export var attack_range := 36.0
@export var attack_damage := 15
@export var attack_cooldown := 1.5
@export var attack_duration := 0.5

var health: int
var player: Node2D = null
var is_attacking := false
var attack_timer := 0.0
var cooldown_timer := 0.0
var is_dead := false

# Captain Mechanics
@export var shield_max := 3
var shield_charges := 0
var is_shielded := false
var shield_cooldown := 0.0
var charge_ready := false
var charge_timer := 0.0

@onready var sprite = $Polygon2D
@onready var shield_sprite = $Shield
@onready var attack_hitbox = $AttackHitbox/CollisionShape2D
@onready var detection_area = $DetectionArea
@onready var label = $Label
@onready var health_bar = $HealthBar

func _ready():
	health = max_health
	shield_charges = shield_max
	_update_shield_visual()
	attack_hitbox.set_deferred("disabled", true)
	_update_label()
	
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
	
	if shield_cooldown > 0:
		shield_cooldown -= delta
		if shield_cooldown <= 0 and shield_charges < shield_max:
			shield_charges += 1
			_update_shield_visual()
	
	if charge_timer > 0:
		charge_timer -= delta
	else:
		charge_ready = true
	
	if not player or player.is_dead:
		return
	
	var to_player = player.global_position - global_position
	var dist = to_player.length()
	
	# Face player
	if to_player.x > 0:
		sprite.scale.x = 1
		shield_sprite.scale.x = 1
	elif to_player.x < 0:
		sprite.scale.x = -1
		shield_sprite.scale.x = -1
	
	# Chase / Attack
	if dist <= detection_range and dist > attack_range:
		var dir = to_player.normalized()
		if charge_ready and shield_charges > 0:
			# Charge dash
			velocity = dir * speed * 2.5
			shield_charges -= 1
			_update_shield_visual()
			charge_ready = false
			charge_timer = 4.0
		else:
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
	
	AudioManager.play_random_pitch("sword_swing", 0.7, 1.0)
	
	# Lunge
	if player:
		var to_player = (player.global_position - global_position).normalized()
		velocity = to_player * speed * 1.5
	
	print("Captain attacks!")

func _end_attack():
	is_attacking = false
	attack_hitbox.disabled = true
	velocity = Vector2.ZERO

func show_damage_number(amount: int, is_heal := false):
	var dn = damage_number_scene.instantiate() as Node2D
	dn.global_position = global_position + Vector2(0, -24)
	get_tree().current_scene.add_child(dn)
	if is_heal:
		dn.setup_heal(amount)
	else:
		dn.setup(amount)

func take_damage(amount: int):
	if is_dead:
		return
	
	# Shield absorbs one hit
	if shield_charges > 0:
		shield_charges -= 1
		_update_shield_visual()
		# Flash gold for blocked
		modulate = Color.GOLD
		await get_tree().create_timer(0.15).timeout
		if not is_dead:
			modulate = Color.WHITE
		# Counterattack faster
		cooldown_timer = 0.5
		AudioManager.play_sfx("shield_block")
		print("Captain blocked!")
		return
	
	show_damage_number(amount)
	
	health -= amount
	_update_label()
	
	# Flash red
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	if not is_dead:
		modulate = Color.WHITE
	
	if health <= 0:
		_die()

func _update_shield_visual():
	shield_sprite.visible = shield_charges > 0
	if label:
		label.self_modulate = Color.GOLD if shield_charges > 0 else Color.WHITE

func _update_label():
	if label:
		label.text = "CAPTAIN\nHP: %d/%d\n🛡%d" % [health, max_health, shield_charges]
	if health_bar:
		health_bar.update_health(health, max_health)

func _die():
	is_dead = true
	print("Captain defeated!")
	
	modulate = Color.DARK_GRAY
	velocity = Vector2.ZERO
	
	$CollisionShape2D.set_deferred("disabled", true)
	attack_hitbox.set_deferred("disabled", true)
	
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _on_attack_hitbox_body_entered(body):
	if body.has_method("take_damage") and body != self:
		body.take_damage(attack_damage)
		print("Captain hit: ", body.name)

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_detection_area_body_exited(body):
	if body.is_in_group("player") and body == player:
		player = null
