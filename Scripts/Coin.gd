extends Area3D

# ---------- VARIABLES ---------- #

# You can change these values from inspector!
@export_category("Properties")
@export var amplitude := 0.2
@export var frequency := 4

var time_passed = 0


# Vector
var initial_position := Vector3.ZERO

# ---------- FUNCTIONS ---------- #

func _ready():
	initial_position = position

func _process(delta):
	coin_hover(delta) # Call the coin_hover function
	rotate_y(deg_to_rad(3))
	
# Coin Hover Animation
func coin_hover(delta):
	time_passed += delta
	
	var new_y = initial_position.y + amplitude * sin(frequency * time_passed)
	position.y = new_y

# ---------- SIGNALS ---------- #

func _on_body_entered(body):
	# Delete The Coin and Add Score
	if body.is_in_group("Player"):
		GameManager.add_score()
		AudioManager.coin_sfx.play()
		queue_free()
