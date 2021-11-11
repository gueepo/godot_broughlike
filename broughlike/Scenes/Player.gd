extends Node

onready var _mainSceneReference = get_node("/root/MainScene")
var amount_to_move
onready var _animatedSprite = $AnimatedSprite

# this also has to more global, not only to the player	

func _ready():
	amount_to_move = _mainSceneReference.TILE_SIZE

func MoveTo(position):
	# check if new position is valid
	# #todo: engage in combat will happen here
	# if position is valid, is passable, and there is no combat, we just move
	if(_mainSceneReference.is_valid_position(position)):
		self.position = position

func _process(delta):	
	var movementDirection = Vector2()
	if Input.is_action_just_pressed("ui_right"):
		_animatedSprite.flip_h = false
		movementDirection.x = amount_to_move
	elif Input.is_action_just_pressed("ui_left"):
		_animatedSprite.flip_h = true
		movementDirection.x = -amount_to_move
	elif Input.is_action_just_pressed("ui_down"):
		movementDirection.y = amount_to_move
	elif Input.is_action_just_pressed("ui_up"):
		movementDirection.y = -amount_to_move
	
	var newPosition = self.position + movementDirection;
	if(newPosition != self.position):
		MoveTo(newPosition)
