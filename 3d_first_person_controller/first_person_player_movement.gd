extends CharacterBody3D
# https://www.youtube.com/watch?v=A3HLeyaBCq4

var speed: float
const WALK_SPEED = 5.0
const SPRINT_SPEED: float = 10
const JUMP_VELOCITY = 4.5
const SENSITIVITY: float = 0.003

@onready var head_pivot: Node3D = $HeadPivot
@onready var camera: Camera3D = $HeadPivot/Camera3D


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


## Unhandled input is called any time ANY input happens (mouse movement, buttons, etc)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# mouse x is camera y and vice versa
		head_pivot.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY) # if the head rotates on x the whole thing will collapse
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head_pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0
			velocity.z = 0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0) # keeps player from freezing midair
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)

	move_and_slide()
