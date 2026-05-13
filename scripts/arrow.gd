extends Area2D
# Arrow — Ranged projectile fired by SkeletonArcher

var direction := Vector2.RIGHT
var speed := 220.0
var damage := 7
var lifetime := 3.0
var pierce := false

@onready var timer = $Timer if has_node("Timer") else null

func _ready():
	# Auto-destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
		AudioManager.play_sfx("arrow_hit")
		queue_free()
	elif body.is_in_group("enemy"):
		# Don't hit enemies (friendly fire off)
		pass
	else:
		# Hit wall/obstacle
		AudioManager.play_sfx("arrow_impact")
		queue_free()
