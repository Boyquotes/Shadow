extends Character
class_name Player

signal dash_finished()

onready var hand_pivot = $HandPivot
onready var hand = $HandPivot/Hand
onready var character_sprite = $Body/CharacterSprite
onready var dash_tween = $Tweens/DashTween

var dash_velocity = 10 * 30
var move_input : Vector2
var facing := Vector2.RIGHT
var dash_duration = 0.3

onready var animationPlayer = $AnimationPlayer

##func _input(event):
	##if event.is_action_pressed("attack"):
		##attack()
	##elif event.is_action_pressed("secondary_attack"):
		##secondary_attack()

func aim_weapon():
	var mouse_angle = (get_global_mouse_position() - hand_pivot.global_position).angle()
	hand_pivot.rotation = mouse_angle
	##if weapon != null:
		##hand.transform = weapon.get_hand_transform(attack_modifier)
		##hand_pivot.show_behind_parent = weapon.global_position.y < hand_pivot.global_position.y

func _update_move_input():
	move_input.x = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	move_input.y = -int(Input.is_action_pressed("move_up")) + int(Input.is_action_pressed("move_down"))
	move_input = move_input.normalized()
	if move_input == Vector2.ZERO:
		animationPlayer.play("idle")
	if move_input != Vector2.ZERO:
		animationPlayer.play("run")

func _update_facing():
	if move_input != Vector2.ZERO:
		facing = move_input
	var mouse = get_global_mouse_position() - hand_pivot.global_position
	body.scale.x = -1 if mouse.x < 0 else 1
	hand_pivot.scale.y = body.scale.x

func apply_velocity():
	var desired_velocity = move_input * move_speed_units * 16
	velocity = velocity.linear_interpolate(desired_velocity, get_move_weight())

func apply_dash_velocity():
	velocity = velocity.linear_interpolate(Vector2.ZERO, 0.005)
	
func dash():
	if move_input < Vector2.ZERO:
		body.scale.x = -1
		hand_pivot.scale.y = body.scale.x
		animationPlayer.play("dash")
		
	else:
		animationPlayer.play("dash")
	
	dash_tween.interpolate_property(body, "position:y", 0, \
			dash_duration / 2.0, Tween.TRANS_SINE, Tween.EASE_OUT)
	dash_tween.interpolate_property(body, "position:y", 0, \
			dash_duration / 2.0, Tween.TRANS_SINE, Tween.EASE_IN, dash_duration / 2.0)
	dash_tween.interpolate_callback(self, dash_duration, "_on_dash_finished")
	dash_tween.start()
	
	##hitbox_collision.disabled = true
	velocity = facing * dash_velocity

func _on_dash_finished():
	$DashTimer.stop()
	emit_signal("dash_finished")
	##hitbox_collision.disabled = false


func _on_DashTimer_timeout():
		$DashTimer.start()
		var this_ghost = preload("res://Ghost.tscn").instance()
		#give the ghost a parent
		this_ghost.position = position
		this_ghost.texture = $Body.texture
		this_ghost.vframes = $Body.vframes
		this_ghost.hframes = $Body.hframes
		this_ghost.frame = $Body.frame
		if move_input < Vector2.ZERO:
			this_ghost.scale.x = -1
			hand_pivot.scale.y = this_ghost.scale.x
		get_parent().add_child(this_ghost)
