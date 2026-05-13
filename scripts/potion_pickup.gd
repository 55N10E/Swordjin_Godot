extends Area2D
# PotionPickup — small health orb dropped by enemies
# Auto-pickup on player overlap, heals 15 HP

@export var heal_amount := 15

@onready var visual = $Polygon2D

func _ready():
	body_entered.connect(_on_body_entered)
	# Gentle bob animation
	var tween = create_tween().set_loops()
	tween.tween_property(visual, "position:y", -4, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(visual, "position:y", 0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("heal"):
		body.heal(heal_amount)
		queue_free()
