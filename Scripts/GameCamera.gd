extends Camera2D

@export var backgroundColor = Color();
var targetPosition = Vector2.ZERO;
var lerpValue = -15;

func _ready():
	RenderingServer.set_default_clear_color(backgroundColor);

func _process(delta):
	acquire_target_position();
	
	global_position = lerp(targetPosition, global_position, pow(2, lerpValue * delta));

func acquire_target_position():
	var players = get_tree().get_nodes_in_group("player");
	if (players.size() > 0):
		var player = players[0];
		targetPosition = player.global_position;
