extends CharacterBody2D


#Zmienne szybkosci
var Initspeed = 1000
var speed = Initspeed
var sprint = 2000
var crouch = 500
#pozostałe zmienne
@export var rotation_speed = 10.0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var target_angle = (mouse_pos - global_position).angle()
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
	

func _input(event):
	if event.is_action_pressed("Flashlight"):
		$PointLight2D.visible = !$PointLight2D.visible
		
		
func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("crouch"):
		speed = crouch
	elif Input.is_action_pressed("sprint"):
		speed = sprint
	else:
		speed = Initspeed
	
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()
