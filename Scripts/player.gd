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

@export_group("Game Juice")
@export var jumpStretchSize : Vector3

# Booleans
var is_grounded = false
var can_double_jump = false

# Onready Variables
@onready var model = $gobot
@onready var animation = $gobot/AnimationPlayer
@onready var spring_arm = %Gimbal

@onready var particle_trail = $ParticleTrail

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2

# ---------- FUNCTIONS ---------- #

func _ready():
	pass


func _process(delta):
	player_animations()
	get_input(delta)
	
	# Smoothly follow player's position
	spring_arm.position = lerp(spring_arm.position, position, delta * follow_lerp_factor)
	
	# Player Rotation
	if velocity.length() > 5:
		var look_direction = Vector2(velocity.z, velocity.x)
		model.rotation.y = lerp_angle(model.rotation.y, look_direction.angle(), delta * 12)
	
	# Check if player is grounded or not
	is_grounded = true if is_on_floor() else false
	
	# If grounded, reset the jump count else gravity
	if is_grounded:
		can_double_jump = true
	
	velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jumpTween()
			velocity.y = jump_force
			animation.play("Jump", 0.5)
		elif can_double_jump:
			animation.play("Flip", -1, 1.5)
			velocity.y = jump_force
			await animation.animation_finished
			can_double_jump = false
			animation.play("Jump", 0.5)


func jumpTween():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", jumpStretchSize, 0.1)
	tween.tween_property(self, "scale", Vector3(1,1,1), 0.1)


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
	particle_trail.emitting = false
	if is_on_floor():
		if abs(velocity.z) > 0.2 or abs(velocity.x) > 0.2: # Checks if player is moving
			animation.play("Run", 0.5)
			particle_trail.emitting = true
		else:
			animation.play("Idle", 0.5)
#	else:
#		animation.play("Jump", 0.3)
