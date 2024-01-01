extends CharacterBody2D

const gravity = 1000.0;
const horizontal_acceleration = 1300;
const jump_velocity = -330.0;
const lerp_value = -40;
const jump_termination_multiplier = 3;

var max_horizontal_speed = 120.0;
var ledge_grabbing = false;

@onready var ray_up = $RayUp;
@onready var ray_down = $RayDwn;
@onready var ray_ground = $RayGround;
@onready var anim = $AnimatedSprite2D;
@onready var coyote_timer = $CoyoteTimer;
@onready var ray_enable_timer = $RayEnableTimer;


func _physics_process(delta):
	var moveVector = get_movement_vector();
	
	## Character movement acceleration
	velocity.x += moveVector.x * horizontal_acceleration * delta;
	
	## linear interpolation
	# Slowly decrease player's movement
	if (moveVector.x == 0):
		velocity.x = lerp(0.0, velocity.x, pow(2, lerp_value * delta));
	
	# Limit player movement
	velocity.x = clamp(velocity.x, -max_horizontal_speed, max_horizontal_speed);
	
	## Character jump
	# Player will only jump if its on floor or coyote_timer is active or grabing a ledge
	if (moveVector.y < 0 && ((is_on_floor() || !coyote_timer.is_stopped()) || ledge_grabbing)):
		velocity.y = jump_velocity;
		coyote_timer.stop();
		ledge_grabbing = false;
		ray_down.enabled = false;
		ray_enable_timer.start();
	
	# Re-enable the ray cast after lading on ground
	if (is_on_floor()):
		ray_down.enabled = true;
	
	# Enable ray cast after a certain time
	enableRay_down();
	
	## Jump termination acceleration
	# Increase falling speed
	if (velocity.y < 0 && !Input.is_action_pressed("jump")):
		velocity.y += gravity * jump_termination_multiplier * delta;
	elif (ledge_grabbing):
		# Pause player in mid-air
		velocity.y = 0.0;
	else:
		velocity.y += gravity * delta;
	
	handleLedgeDetection();
	
	var was_on_floor = is_on_floor();
	move_and_slide();
	
	if (was_on_floor && !is_on_floor()):
		coyote_timer.start();
	
	update_animation();


# Enable ray cast after 0.25 second
func enableRay_down():
	await ray_enable_timer.timeout;
	ray_down.enabled = true;


func get_movement_vector():
	var moveVector = Vector2.ZERO;
	moveVector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left");
	moveVector.y = -1 if Input.is_action_just_pressed("jump") else 0;
	
	handleLdgDirection(moveVector.x);
	handleLedgeDetection();
	
	return moveVector;


func handleLdgDirection(moveVector):
	if moveVector > 0:
		ray_up.target_position.x = abs(ray_up.target_position.x);
		ray_down.target_position.x = abs(ray_down.target_position.x);
	elif moveVector < 0:
		ray_up.target_position.x = abs(ray_up.target_position.x) * -1;
		ray_down.target_position.x = abs(ray_down.target_position.x) * -1;


func handleLedgeDetection():
	if (ray_down.is_colliding() && !ray_up.is_colliding() && !is_on_floor() && !ray_ground.is_colliding()):
		ledge_grabbing = true;
	else:
		ledge_grabbing = false;


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
	
	if (ledge_grabbing):
		anim.play("ledge_grab");
		anim.animation_finished;
	elif (!falling && !jumping && moveVector.x != 0):
		anim.play("run");
	elif (jumping && !falling):
		anim.play("jump");
	elif (falling && !jumping && !ledge_grabbing):
		anim.play("fall");
	elif (!falling && !jumping && moveVector.x == 0):
		anim.play("idle");
	
	if (moveVector.x != 0):
		anim.flip_h = true if moveVector.x < 0 else false;

func _on_animated_sprite_2d_animation_finished():
	if (anim.animation == "ledge_grab"):
		anim.frame = 5;
