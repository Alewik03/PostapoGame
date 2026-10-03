extends CharacterBody2D

signal battery_changed(new_value)

# Zmienne szybkości
var Initspeed = 100
var speed = Initspeed
var sprint = 200
var crouch = 50
var alive = true

# Zmienne latarki
var battery_level = 100
var drain_speed = 10

# Pozostałe zmienne
@export var rotation_speed = 10.0

@onready var torso_node: Node2D = $Torso_Node2D
@onready var legs_sprite: AnimatedSprite2D = $Legs_AnimatedSprite2D
@onready var flashlight_beam = $Torso_Node2D/FlashlightBeam


func _process(delta: float) -> void:
	if not alive:
		return
		
	# Obracamy TYLKO tułów (i podpiętą do niego latarkę) w stronę myszki
	var mouse_pos = get_global_mouse_position()
	var target_angle = (mouse_pos - global_position).angle()
	torso_node.rotation = lerp_angle(torso_node.rotation, target_angle, rotation_speed * delta)

func _input(event: InputEvent) -> void:
	if not alive:
		return
	if event.is_action_pressed("Flashlight"):
		flashlight_beam.visible = !flashlight_beam.visible

func _physics_process(delta: float) -> void:
	if not alive:
		return
		
	# Sprawdzanie trybu ruchu
	if Input.is_action_pressed("crouch"):
		speed = crouch
	elif Input.is_action_pressed("sprint"):
		speed = sprint
	else:
		speed = Initspeed

	# Obsługa baterii latarki
	if flashlight_beam.visible:
		battery_level -= drain_speed * delta
		battery_changed.emit(battery_level)
		if battery_level < 25:
			flashlight_beam.enabled = (randf() <= 0.92)
		else:
			flashlight_beam.enabled = true
	else:
		flashlight_beam.enabled = false
		
	battery_level = clamp(battery_level, 0, 100)
	if battery_level <= 0:
		flashlight_beam.enabled = false

	# Ruch i animacja nóg
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()
	
	_update_legs(direction)

func _update_legs(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		# Obracamy nogi w stronę, w którą faktycznie idziemy (WASD)
		legs_sprite.rotation = direction.angle()
		
		# Dopasowujemy prędkość animacji do prędkości chodu/biegu
		if speed == sprint:
			legs_sprite.speed_scale = 1.5
		elif speed == crouch:
			legs_sprite.speed_scale = 0.6
		else:
			legs_sprite.speed_scale = 1.0
			
		legs_sprite.play("walk")
	else:
		legs_sprite.play("idle")

func add_battery(amount: float) -> void:
	battery_level = clamp(battery_level + amount, 0, 100)
	battery_changed.emit(battery_level)
	print("Podniesiono baterie!")

func _on_health_component_died() -> void:
	alive = false
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("death")
