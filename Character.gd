extends KinematicBody2D
class_name Character

onready var body = $Body
onready var state_machine = $StateMachine
onready var animation_player = $AnimationPlayer

export var move_speed_units = 8
export var knockback_velocity = 300

var velocity : Vector2

func apply_stop_velocity():
	velocity = velocity.linear_interpolate(Vector2.ZERO, get_move_weight())

func apply_movement():
	velocity = move_and_slide(velocity)

func get_move_weight() -> float:
	var move_weight = 0.3
	return move_weight

func is_moving():
	return velocity.length() > 8
