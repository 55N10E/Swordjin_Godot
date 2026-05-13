extends StaticBody2D
# IronGate — Blocks player until key acquired

@onready var gate_sprite = $Polygon2D
@onready var interaction_area = $InteractionArea
@onready var label = $Label

var is_open := false

func _ready():
	update_visual()
	label.text = "🔒 Gate Locked"

func update_visual():
	if is_open:
		gate_sprite.modulate = Color(0.3, 0.3, 0.3, 0.3)  # ghostly/faded
		$CollisionShape2D.set_deferred("disabled", true)
		label.text = "🚪 Gate Open"
	else:
		gate_sprite.modulate = Color(0.4, 0.25, 0.15)  # iron rust
		$CollisionShape2D.set_deferred("disabled", false)

func _on_interaction_area_body_entered(body):
	if not body.is_in_group("player"):
		return
	
	if is_open:
		return
	
	if GameState.has_gate_key:
		open_gate()
	else:
		# Show "locked" briefly
		label.text = "🔒 Gate Locked — Kill the Captain!"
		await get_tree().create_timer(1.5).timeout
		if not is_open:
			label.text = "🔒 Gate Locked"

func open_gate():
	is_open = true
	update_visual()
	AudioManager.play_sfx("shield_block")
	label.text = "🚪 Gate Opens!"
	print("Gate opened with key!")
	
	# Visual: flash white then fade
	gate_sprite.modulate = Color.WHITE
	await get_tree().create_timer(0.2).timeout
	
	# Fade out tween
	var tw = create_tween()
	tw.tween_property(gate_sprite, "modulate", Color(0.3, 0.3, 0.3, 0.0), 0.5)
	tw.tween_callback(queue_free)

	# Notify level manager that gate is open
	var lm = get_tree().current_scene
	if lm and lm.has_method("_on_gate_opened"):
		lm._on_gate_opened()
