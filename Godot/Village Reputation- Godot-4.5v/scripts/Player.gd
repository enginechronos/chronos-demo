extends CharacterBody2D  # Fixed: Must match the node type in your scene

@export var speed: float = 150.0

func _ready() -> void:
	print("PLAYER READY: script running")

func _physics_process(_delta: float) -> void:
	var dir := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		dir.x += 1.0
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1.0
	if Input.is_action_pressed("ui_down"):
		dir.y += 1.0
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1.0

	# Apply movement using CharacterBody2D's built-in features
	velocity = dir.normalized() * speed
	move_and_slide()
