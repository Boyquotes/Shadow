extends Area2D
var direction = Vector2()
export var speed = 200

func shoot(aim_position, gun_position):
	global_position = gun_position
	$Slash/AnimationPlayer.play("Slash")
	direction = (aim_position - gun_position).normalized()
	rotation = direction.angle()

func _process(delta):
	position += direction * speed * delta

func _on_Slash_body_entered(body):
	queue_free()

func _collision_on():
	$CollisionPolygon2D.disabled = false

func delete_projectile():
	$CollisionPolygon2D.disabled = true
	queue_free()
