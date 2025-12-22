extends CharacterBody2D
#Zmienne szybkosci
var Initspeed = 1000
var speed = Initspeed
var sprint = 2000
#zmienne do staminy
var stamina = 100
var max_stamina = 100
var stamina_consumption = 30.0 # Ile staminy zabiera na sekundę
var stamina_regeneration = 15.0 # Ile odzyskuje na sekundę
var stamina_cooldown_timer = 3
#pozostałe zmienne
@export var rotation_speed = 10.0
var is_exhausted = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var target_angle = (mouse_pos - global_position).angle()
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
	print(stamina)
	print(stamina_cooldown_timer)
	

func _input(event):
	if event.is_action_pressed("Flashlight"):
		$Sprite2D/PointLight2D.visible = !$Sprite2D/PointLight2D.visible
		
	if event.is_action("sprint"):
		if event.pressed:
			speed = sprint  # Wartość podczas biegu
			
		else:
			speed = Initspeed  # Powrót do normalnej prędkości
		
func _physics_process(delta: float) -> void:
	var is_sprinting = Input.is_action_pressed("sprint") and stamina > 0
	
	if is_sprinting:
		speed = sprint
		stamina -= stamina_consumption * delta # Odejmujemy staminę w czasie
		stamina_cooldown_timer = 3
	else:
		speed = Initspeed
		stamina_cooldown_timer -= 1 * delta
		# Odzyskujemy staminę, jeśli nie biegniemy i nie mamy maksa
		if stamina < max_stamina and stamina_cooldown_timer <= 0:
			stamina += stamina_regeneration * delta

	# 2. Zapobiegamy wyjściu staminy poza zakres 0-100
	stamina = clamp(stamina, 0, max_stamina)
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()
