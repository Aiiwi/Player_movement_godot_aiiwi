extends CharacterBody3D

@export_group("Camera")
@export_range(0.0,1.0) var mouse_sensitivity := 0.2

@export_group("Player_Movement")
@export var move_speed := 5.0
@export var acceleration := 20.0

@onready var pause_ui= $CameraPoint/UI/Pause_UI as CanvasLayer
@onready var _camera:Camera3D = %CameraPoint

var _camera_input_direction := Vector2.ZERO

func _ready() -> void:
	pause_ui.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent):
	
	if event.is_action_pressed("UI_PAUSE"):
		pause_ui.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _unhandled_input(event: InputEvent) -> void:
	var is_camera_mov := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_mov:
		_camera_input_direction = event.screen_relative * mouse_sensitivity

func _physics_process(delta: float) -> void:
	_camera.rotation.x += -_camera_input_direction.y * delta
	_camera.rotation.x = clamp(_camera.rotation.x, -PI/6.5,PI/2.5) #Contiene la telecamera nel suo movimento
	_camera.rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO
	
	var raw_input := Input.get_vector("MOVE_LEFT","MOVE_RIGHT","MOVE_FORWARD","MOVE_BACK")
	var forward := _camera.global_basis.z
	var right := -_camera.global_basis.x
	
	var move_dir := forward * raw_input.y + right * raw_input.x
	move_dir.y=0.0
	move_dir = move_dir.normalized()
	
	velocity = velocity.move_toward(move_dir* move_speed, acceleration * delta)
	move_and_slide()
