extends Area2D
var direction = Vector2()
export var speed = 500

func shoot(aim_position, gun_position):
	global_position = gun_position
	$AnimationPlayer.play("Swipe")
	direction = (aim_position - gun_position).normalized()
	rotation = direction.angle()

func _process(delta):
	position += direction * speed * delta

func _on_Swipe_body_entered(body):
	queue_free()

func _on_LifeTime_timeout():
	pass
	
func delete_projectile():
	$CollisionPolygon2D.disabled = true
	queue_free()
