extends Area3D

# ---------- VARIABLES ---------- #

@onready var spawn_position = %SpawnPosition
@onready var player = get_tree().get_first_node_in_group("Player")

# ---------- SIGNALS ---------- #

func _on_body_entered(body):
	# Checks if player is colliding with the dead zone & reset player position if true
	if body.is_in_group("Player"):
		player.global_position = spawn_position.global_position
