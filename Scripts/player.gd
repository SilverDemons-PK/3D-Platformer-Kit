# ----------------------------------------------------------------------------------- #
# -------------- FEEL FREE TO USE IN ANY PROJECT, COMMERCIAL OR NON-COMMERCIAL ------ #
# ---------------------- 3D PLATFORMER CONTROLLER BY SD STUDIOS --------------------- #
# ---------------------------- ATTRIBUTION NOT REQUIRED ----------------------------- #
# ----------------------------------------------------------------------------------- #

extends CharacterBody3D

# ---------- VARIABLES ---------- #

@export_category("Player Properties")
@export var move_speed : float
@export var jump_force : float
@export var follow_lerp_factor : float
@export var jump_limit : int = 2

# Onready Variables
@onready var model = $gobot
@onready var animation = $gobot/AnimationPlayer
@onready var spring_arm = $SpringArm3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# ---------- FUNCTIONS ---------- #

func _ready():
	pass


func _process(delta):
	player_animations()
	get_input(delta)
	
	# Smoothly follow player's position
	spring_arm.position = lerp(spring_arm.position, position, delta * follow_lerp_factor)
	
	# Player Rotation
	if velocity.length() > 4:
		var look_direction = Vector2(velocity.z, velocity.x)
		model.rotation.y = lerp_angle(model.rotation.y, look_direction.angle(), delta * 12)
	
	# Gravity
	if !is_on_floor():
		velocity.y -= gravity * delta
	else:
		jump_limit = 2
	
	# Jumping
	if Input.is_action_just_pressed("jump") and jump_limit > 0:
		velocity.y = jump_force
		jump_limit -= 1


# Get Player Input
func get_input(_delta):
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_axis("move_left", "move_right")
	move_direction.z = Input.get_axis("move_forward", "move_back")
	
	# Move The player Towards Spring Arm/Camera Rotation
	move_direction = move_direction.rotated(Vector3.UP, spring_arm.rotation.y).normalized()
	velocity = Vector3(move_direction.x * move_speed, velocity.y, move_direction.z * move_speed)

	move_and_slide()


# Handle Player Animations
func player_animations():
	if is_on_floor():
		if abs(velocity.z) > 1 or abs(velocity.x) > 1: # Checks if player is moving
			animation.play("Run", 0.5)
		else:
			animation.play("Idle", 0.5)
	else:
		animation.play("Jump", 0.3)
