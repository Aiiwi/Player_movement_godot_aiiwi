extends CharacterBody3D

@export_group("Camera")
 #mouse sens

@export_group("Player_Movement")
@export var move_speed :float = 5.0 #player normal speed
@export var acceleration :float = 20.0

@onready var pause_ui:CanvasLayer = $CameraPoint/UI/Pause_UI
@onready var _camera:Camera3D = %CameraPoint
@onready var headbob:AnimationPlayer = $CameraPoint/headbob

var _camera_input_direction = Vector2.ZERO

func _ready() -> void:
	pause_ui.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent):
	
	if event.is_action_pressed("UI_PAUSE"): #handled pause input with hotkey
		pause_ui.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _unhandled_input(event: InputEvent) -> void:
	var is_camera_mov = (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	
	if is_camera_mov:
		_camera_input_direction = event.screen_relative * GLOBAL.mouse_sensitivity

func _physics_process(delta: float) -> void:
	_camera.rotation.x += -_camera_input_direction.y * delta
	_camera.rotation.x = clamp(_camera.rotation.x, deg_to_rad(-80),deg_to_rad(80)) 
	_camera.rotation.y -= _camera_input_direction.x * delta
	
	_camera_input_direction = Vector2.ZERO
	
	var raw_input := Input.get_vector("MOVE_LEFT","MOVE_RIGHT","MOVE_FORWARD","MOVE_BACK") #hotkeys wasd
	
	if raw_input && is_on_floor():
		headbob.play("head_bobbing")
	else:
		headbob.pause()
	
	var move_dir = _camera.global_basis.z * raw_input.y + (-_camera.global_basis.x) * raw_input.x
	move_dir.y=0.0
	move_dir = move_dir.normalized()
	
	velocity = velocity.move_toward(move_dir* move_speed, acceleration * delta)
	
	move_and_slide()
