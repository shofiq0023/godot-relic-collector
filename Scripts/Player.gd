extends CharacterBody2D

const gravity = 1000.0;
const maxHorizontalSpeed = 120.0;
const horizontalAcceleration = 1300;
const jumpVelocity = -330.0;
const lerpValue = -40;
const jumpTerminationMultiplier = 3;

func _physics_process(delta):
	var moveVector = getMovementVector();
	
	velocity.x += moveVector.x * horizontalAcceleration * delta;
	
	if (moveVector.x == 0):
		velocity.x = lerp(0.0, velocity.x, pow(2, lerpValue * delta));
	
	velocity.x = clamp(velocity.x, -maxHorizontalSpeed, maxHorizontalSpeed);
	
	if (moveVector.y < 0 && is_on_floor()):
		velocity.y = jumpVelocity;
	
	if (velocity.y < 0 && !Input.is_action_pressed("jump")):
		velocity.y += gravity * jumpTerminationMultiplier * delta;
	else:
		velocity.y += gravity * delta;
	
	move_and_slide();
	
func getMovementVector():
	var moveVector = Vector2.ZERO;
	moveVector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left");
	moveVector.y = -1 if Input.is_action_just_pressed("jump") else 0;
	return moveVector;
