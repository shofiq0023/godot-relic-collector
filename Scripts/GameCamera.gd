extends Camera2D

@export var background_color = Color(); #545454
var target_position = Vector2.ZERO;
var lerp_value = -15;

func _ready():
	RenderingServer.set_default_clear_color(background_color);


func _physics_process(delta):
	acquire_target_position();
	
	global_position = lerp(target_position, global_position, pow(2, lerp_value * delta));


func acquire_target_position():
	var players = get_tree().get_nodes_in_group("player");
	if (players.size() > 0):
		var player = players[0];
		target_position = player.global_position;
