extends CharacterBody3D

@export var sens := 0.005
@export var speed := 5.0
@export var jump_velocity := 4.5
@export var networkPlayerNumber: int
@export var prettyName: String

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree():
	if name.is_valid_int():
		set_multiplayer_authority(name.to_int())

func _ready():
	StartWrapper.print_to_chat("Player node " + name + " authority is: " + str(get_multiplayer_authority()) + " | Local ID: " + str(multiplayer.get_unique_id()))

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and is_multiplayer_authority():
		rotate_y(-event.relative.x * sens)
		$CameraPivot.rotate_x(-event.relative.y * sens)
		$CameraPivot.rotation.x = clamp($CameraPivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if is_multiplayer_authority():
		# Handle Jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity

		# Get the input direction and handle the movement/deceleration.
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

		move_and_slide()
