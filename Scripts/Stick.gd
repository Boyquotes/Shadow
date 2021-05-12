extends "res://Scripts/Sword.gd"

#single dot calls the parent function, with the child function taking priority

func attack():
	if !is_projectile_firing:
		var slash_instance = load("res://Scenes/Slash.tscn").instance()
		slash_instance.shoot(get_global_mouse_position(), hand_pivot.global_position)
		get_parent().owner.add_child(slash_instance)
	.attack()
	

func secondary_attack():
	if !is_projectile_firing:
		var swipe_instance = load("res://Scenes/Swipe.tscn").instance()
		swipe_instance.shoot(get_global_mouse_position(), self.global_position)
		get_parent().owner.add_child(swipe_instance)
	.secondary_attack()


