extends Node

# these should global variables (or something like that)
# since all actors/monsters (a player is a monter) are going to use it, maybe it could be on a parent node
var tiles_on_horizontal = 9
var tiles_on_vertical = 9
var amount_to_move = 16

# this also has to more global, not only to the player	
func is_valid_position(position):
	return !(position.x < 0 || position.x >= (tiles_on_horizontal * amount_to_move) || position.y < 0 || position.y >= (tiles_on_vertical * amount_to_move))

func MoveTo(position):
	# check if new position is valid
	# #todo: engage in combat will happen here
	# if position is valid, is passable, and there is no combat, we just move
	if(is_valid_position(position)):
		print(position)
		self.position = position

func _process(delta):
	var movementDirection = Vector2()
	if Input.is_action_just_pressed("ui_right"):
		movementDirection.x = amount_to_move
	elif Input.is_action_just_pressed("ui_left"):
		movementDirection.x = -amount_to_move
	elif Input.is_action_just_pressed("ui_down"):
		movementDirection.y = amount_to_move
	elif Input.is_action_just_pressed("ui_up"):
		movementDirection.y = -amount_to_move
	
	var newPosition = self.position + movementDirection;
	MoveTo(newPosition)
