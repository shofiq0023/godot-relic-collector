extends CharacterBody2D

const gravity = 1000.0;
const maxHorizontalSpeed = 120.0;
const horizontalAcceleration = 1300;
const jumpVelocity = -330.0;
const lerpValue = -40;
const jumpTerminationMultiplier = 3;

func _physics_process(delta):
	var moveVector = get_movement_vector();
	
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
	update_animation();
	
func get_movement_vector():
	var moveVector = Vector2.ZERO;
	moveVector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left");
	moveVector.y = -1 if Input.is_action_just_pressed("jump") else 0;
	return moveVector;

func update_animation():
	var falling = false;
	var jumping = true;
	var moveVector = get_movement_vector();
	
	if (velocity.y < 0):
		jumping = true;
		falling = false;
	elif (velocity.y > 0):
		falling = true;
		jumping = false;
		
	if (is_on_floor()):
		jumping = false;
		falling = false;
	
	if (!falling && !jumping && moveVector.x != 0):
		$AnimatedSprite2D.play("run");
	elif (jumping && !falling):
		$AnimatedSprite2D.play("jump");
	elif (falling && !jumping):
		$AnimatedSprite2D.play("fall");
	elif (!falling && !jumping && moveVector.x == 0):
		$AnimatedSprite2D.play("idle");

	if (moveVector.x != 0):
		$AnimatedSprite2D.flip_h = true if moveVector.x < 0 else false;

