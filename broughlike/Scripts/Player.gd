extends "res://Scripts/Monster_Base.gd"
	
signal on_player_finished_turn

func StartMonster():
	_is_player = true
	_teleportCounter = 0
	
func _process(delta):	
	var movementDirection = Vector2()
	if Input.is_action_just_pressed("ui_right"):
		_animatedSprite.flip_h = false
		movementDirection.x = _amount_to_move
	elif Input.is_action_just_pressed("ui_left"):
		_animatedSprite.flip_h = true
		movementDirection.x = -_amount_to_move
	elif Input.is_action_just_pressed("ui_down"):
		movementDirection.y = _amount_to_move
	elif Input.is_action_just_pressed("ui_up"):
		movementDirection.y = -_amount_to_move
		
	if Input.is_action_just_pressed("spell_0"):
		UseSpell(0)
	elif Input.is_action_just_pressed("spell_1"):
		UseSpell(1)
	elif Input.is_action_just_pressed("spell_2"):
		UseSpell(2)
	elif Input.is_action_just_pressed("spell_3"):
		UseSpell(3)
	elif Input.is_action_just_pressed("spell_4"):
		UseSpell(4)
	elif Input.is_action_just_pressed("spell_5"):
		UseSpell(5)
	
	var newPosition = self.position + movementDirection;
	if(newPosition != self.position):
		var movedSuccesfully = MoveTo(newPosition)
		if(movedSuccesfully):
			emit_signal("on_player_finished_turn")
