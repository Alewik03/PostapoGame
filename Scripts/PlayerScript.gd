extends CharacterBody2D

signal battery_changed(new_value)

#Zmienne szybkosci
var Initspeed = 100
var speed = Initspeed
var sprint = 200
var crouch = 50

#zmienne latarki
var battery_level = 100
var drain_speed = 10
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
	
#Wlaczanie i wylaczanie latarki
func _input(event):
	if event.is_action_pressed("Flashlight"):
		$PointLight2D.visible = !$PointLight2D.visible
		
		
func _physics_process(delta: float) -> void:
	#Sprawdzanie jaka forme ruchu wykonuje postac
	if Input.is_action_pressed("crouch"):
		speed = crouch
	elif Input.is_action_pressed("sprint"):
		speed = sprint
	else:
		speed = Initspeed
		
	#Skrypt do latarki, jesli latarka ejst visible to ciagnie baterie i jesli bateria jest ponizej
	#25% to latarka ma 8% szans ze zniknie w kazdej klatce
	if $PointLight2D.visible == true:
		battery_level -= drain_speed * delta
		battery_changed.emit(battery_level)
		if battery_level < 25	:
			if randf() > 0.92:
				$PointLight2D.enabled = false
			else:
				$PointLight2D.enabled = true
		else:
			$PointLight2D.enabled = true
	#nakladamy limity dla latarki
	battery_level = clamp(battery_level, 0, 100)
	#jesli latarka bedzie miala 0% to wylaczamy ja calkowicie
	if battery_level <= 0:
		$PointLight2D.enabled = false
	
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()
#Funkcja do baterii, jesli podniesiemy baterie to zwiekszamy energie latarki o 50
func add_battery(amount: float) -> void:
	battery_level += amount
	battery_level = clamp(battery_level, 0, 100)
	battery_changed.emit(battery_level)
	print("Podniesiono baterie!")
