extends "res://CharacterFSM.gd"

onready var animationPlayer = $AnimationPlayer

func _ready():
	add_state("idle")
	add_state("run")
	add_state("dash")
	call_deferred("set_state", states.idle)

func _input(event):
	if event.is_action_pressed("dash"):
		if state in [states.run]:
			parent.dash()
			set_state(states.dash)

func _state_logic(delta):
	match state:
		states.idle, states.run:
			parent._update_move_input()
			parent._update_facing()
			parent.apply_velocity()
			parent.apply_movement()
		states.dash:
			parent.apply_dash_velocity()
			parent.apply_movement()
			parent.aim_weapon()
		_:
			parent.apply_stop_velocity()
			parent.apply_movement()

func _get_transition(delta):
	match state:
		states.idle:
			if parent.is_moving():
				return states.run
		states.run:
			if !parent.is_moving():
				return states.idle
	return null

func _enter_state(new_state, old_state):
	var state_label = parent.get_node("StateLabel")
	state_label.text = states.keys()[new_state]

func _exit_state(old_state, new_state):
	pass

func _on_Player_dash_finished():
	if state == states.dash:
		set_state(states.idle)
