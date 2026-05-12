extends CharacterBody2D
# Merchant ally — follows player, heals, spouts combat dialogue

@export var follow_distance := 80.0
@export var speed := 75.0
@export var heal_amount := 10
@export var heal_interval := 5.0

var player: Node2D = null
var heal_timer := 0.0
var combat_lines: Array = []
var next_line_index := 0

@onready var dialogue_label = $DialogueLabel
@onready var dialogue_timer = $DialogueTimer

func _ready():
	# Find player
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	heal_timer = heal_interval

func _setup(lines: Array):
	combat_lines = lines

func _physics_process(delta):
	if not player or player.is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var to_player = player.global_position - global_position
	var dist = to_player.length()
	
	# Follow player
	if dist > follow_distance:
		var dir = to_player.normalized()
		velocity = dir * speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	# Heal
	heal_timer -= delta
	if heal_timer <= 0:
		if player.has_method("merchant_heal"):
			player.merchant_heal(heal_amount)
			_show_dialogue("Healed +%d HP" % heal_amount, 1.5)
		heal_timer = heal_interval

func say(line: String, duration: float = 2.5):
	_show_dialogue(line, duration)

func _show_dialogue(text: String, duration: float):
	dialogue_label.text = text
	dialogue_label.visible = true
	dialogue_timer.wait_time = duration
	dialogue_timer.start()

func _on_dialogue_timer_timeout():
	dialogue_label.visible = false

func take_damage(amount: int):
	# Merchant is invulnerable
	_show_dialogue("I'm not a fighter!", 1.0)
