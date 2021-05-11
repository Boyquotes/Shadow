extends Character
class_name Player

signal dash_finished
signal move

export(PackedScene) var Running_Steps
var last_step = 0

##Character Info
onready var statemachine = $StateMachine

#TWEENS
onready var dash_tween = $Tweens/DashTween

#Particles
onready var particlePosition = $ParticlePoint
onready var particleScene = preload("res://Scripts/Running_Steps.gd")

#Movement
var dash_velocity = 10 * 35
var move_input : Vector2
var facing := Vector2.RIGHT
var dash_duration = 0.3

#Attack/Weapon
var weapon = null

#Animations
onready var animationPlayer = $AnimationPlayer

func _ready():
	set_weapon(preload("res://Scenes/Stick.tscn").instance())
	
func _process(delta):
	weapon.aim_weapon()

func set_weapon(weapon):
	if self.weapon != null:
		self.weapon.queue_free()
	
	if weapon != null:
		add_child(weapon)
		self.weapon = weapon
		weapon.init(self)
#		hitbox.add_exception(weapon.damage_area)
		weapon.damage_area.collision_layer = CollisionLayers.ENEMY_HAZARD


func _input(event):
	if event.is_action_pressed("attack") && statemachine.can_attack():
		weapon.attack()
	elif event.is_action_pressed("secondary_attack") && statemachine.can_attack():
		weapon.secondary_attack()

func _update_move_input():
	move_input.x = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	move_input.y = -int(Input.is_action_pressed("move_up")) + int(Input.is_action_pressed("move_down"))
	move_input = move_input.normalized()
	if move_input == Vector2.ZERO:
		animationPlayer.play("idle")
	if move_input != Vector2.ZERO:
		emit_signal("move")
		
		##THIS SECTION CONTROLS PLAYER FOOTSTEP PARTICLES
		var running_step = Running_Steps.instance()
		if body.frame == 3 || body.frame == 5:
			running_step.global_position = Vector2(global_position.x - 4, global_position.y + 8)
			if move_input < Vector2.ZERO:
				running_step.global_position = Vector2(global_position.x + 4, global_position.y + 8)
			running_step.emitting = true
		get_parent().add_child(running_step)
		
		animationPlayer.play("run")
		

func _update_facing():
	if move_input != Vector2.ZERO:
		facing = move_input
	var mouse = get_global_mouse_position() - weapon.hand_pivot.global_position
	body.scale.x = -1 if mouse.x < 0 else 1
	weapon.hand_pivot.scale.y = body.scale.x

func apply_velocity():
	var desired_velocity = move_input * move_speed_units * 16
	velocity = velocity.linear_interpolate(desired_velocity, get_move_weight())

func apply_dash_velocity():
	velocity = velocity.linear_interpolate(Vector2.ZERO, 0.005)
	
func dash():
	weapon.hide()
	weapon.hand.hide()
	if move_input < Vector2.ZERO:
		body.scale.x = -1
		weapon.hand_pivot.scale.y = body.scale.x
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
	weapon.show()
	weapon.hand.show()
	emit_signal("dash_finished")
	##hitbox_collision.disabled = false


func _on_DashTimer_timeout():
		$DashTimer.start()
		var this_ghost = preload("res://Scenes/Ghost.tscn").instance()
		#give the ghost a parent
		this_ghost.position = position
		this_ghost.texture = $Body.texture
		this_ghost.vframes = $Body.vframes
		this_ghost.hframes = $Body.hframes
		this_ghost.frame = $Body.frame
		if move_input < Vector2.ZERO:
			this_ghost.scale.x = -1
			weapon.hand_pivot.scale.y = this_ghost.scale.x
		get_parent().add_child(this_ghost)
		
