extends Character
class_name Player

onready var hand_pivot = $HandPivot
onready var hand = $HandPivot/Hand
onready var character_sprite = $Body/CharacterSprite

var move_input : Vector2
var facing := Vector2.RIGHT

##func _input(event):
	##if event.is_action_pressed("attack"):
		##attack()
	##elif event.is_action_pressed("secondary_attack"):
		##secondary_attack()

func _update_move_input():
	move_input.x = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	move_input.y = -int(Input.is_action_pressed("move_up")) + int(Input.is_action_pressed("move_down"))
	move_input = move_input.normalized()

func _update_facing():
	if move_input != Vector2.ZERO:
		facing = move_input
	var mouse = get_global_mouse_position() - hand_pivot.global_position
	body.scale.x = -1 if mouse.x < 0 else 1
	hand_pivot.scale.y = body.scale.x

func apply_velocity():
	var desired_velocity = move_input * move_speed_units * 16
	velocity = velocity.linear_interpolate(desired_velocity, get_move_weight())
