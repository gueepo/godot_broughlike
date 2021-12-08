extends "res://Scenes/Monster_Base.gd"
	
func StartMonster():
	print("initializing player")
	InitializeMonster(3)
	_is_player = true
	_teleportCounter = 0
	
	# temp
	_spellBag.append(1)
	
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
	
	var newPosition = self.position + movementDirection;
	if(newPosition != self.position):
		MoveTo(newPosition)
