extends CharacterBody2D

const gravity = 1000.0;
const horizontalAcceleration = 1300;
const jumpVelocity = -330.0;
const lerpValue = -40;
const jumpTerminationMultiplier = 3;

var maxHorizontalSpeed = 120.0;
var ledgeGrabbing = false;

@onready var rayUp = $RayUp;
@onready var rayDown = $RayDwn;
@onready var rayGround = $RayGround;
@onready var anim = $AnimatedSprite2D;
@onready var coyoteTimer = $CoyoteTimer;
@onready var rayEnableTimer = $RayEnableTimer;


func _physics_process(delta):
	var moveVector = get_movement_vector();
	
	## Character movement acceleration
	velocity.x += moveVector.x * horizontalAcceleration * delta;
	
	## linear interpolation
	# Slowly decrease player's movement
	if (moveVector.x == 0):
		velocity.x = lerp(0.0, velocity.x, pow(2, lerpValue * delta));
	
	# Limit player movement
	velocity.x = clamp(velocity.x, -maxHorizontalSpeed, maxHorizontalSpeed);
	
	## Character jump
	# Player will only jump if its on floor or coyoteTimer is active or grabing a ledge
	if (moveVector.y < 0 && ((is_on_floor() || !coyoteTimer.is_stopped()) || ledgeGrabbing)):
		velocity.y = jumpVelocity;
		coyoteTimer.stop();
		ledgeGrabbing = false;
		rayDown.enabled = false;
		rayEnableTimer.start();
	
	# Re-enable the ray cast after lading on ground
	if (is_on_floor()):
		rayDown.enabled = true;
	
	# Enable ray cast after a certain time
	enableRayDown();
	
	## Jump termination acceleration
	# Increase falling speed
	if (velocity.y < 0 && !Input.is_action_pressed("jump")):
		velocity.y += gravity * jumpTerminationMultiplier * delta;
	elif (ledgeGrabbing):
		# Pause player in mid-air
		velocity.y = 0.0;
	else:
		velocity.y += gravity * delta;
	
	handleLedgeDetection();
	
	var was_on_floor = is_on_floor();
	move_and_slide();
	
	if (was_on_floor && !is_on_floor()):
		coyoteTimer.start();
	
	update_animation();


# Enable ray cast after 0.25 second
func enableRayDown():
	await rayEnableTimer.timeout;
	rayDown.enabled = true;


func get_movement_vector():
	var moveVector = Vector2.ZERO;
	moveVector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left");
	moveVector.y = -1 if Input.is_action_just_pressed("jump") else 0;
	
	handleLdgDirection(moveVector.x);
	handleLedgeDetection();
	
	return moveVector;


func handleLdgDirection(moveVector):
	if moveVector > 0:
		rayUp.target_position.x = abs(rayUp.target_position.x);
		rayDown.target_position.x = abs(rayDown.target_position.x);
	elif moveVector < 0:
		rayUp.target_position.x = abs(rayUp.target_position.x) * -1;
		rayDown.target_position.x = abs(rayDown.target_position.x) * -1;


func handleLedgeDetection():
	if (rayDown.is_colliding() && !rayUp.is_colliding() && !is_on_floor() && !rayGround.is_colliding()):
		ledgeGrabbing = true;
	else:
		ledgeGrabbing = false;


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
	
	if (ledgeGrabbing):
		anim.play("ledge_grab");
		anim.animation_finished;
	elif (!falling && !jumping && moveVector.x != 0):
		anim.play("run");
	elif (jumping && !falling):
		anim.play("jump");
	elif (falling && !jumping && !ledgeGrabbing):
		anim.play("fall");
	elif (!falling && !jumping && moveVector.x == 0):
		anim.play("idle");
	
	if (moveVector.x != 0):
		anim.flip_h = true if moveVector.x < 0 else false;

func _on_animated_sprite_2d_animation_finished():
	if (anim.animation == "ledge_grab"):
		anim.frame = 5;
