extends CharacterBody2D

var speed = 50
@onready var nav_agent = $NavigationAgent2D # Musisz mieć ten węzeł w scenie!
var player = null

func _ready() -> void:
	# Szukamy gracza w grupie
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if player:
		# 1. Mówimy agentowi, gdzie jest gracz
		nav_agent.target_position = player.global_position
		
		# 2. Sprawdzamy, czy agent już wie, jak tam dojść
		if nav_agent.is_navigation_finished():
			return

		# 3. Pobieramy następny punkt na trasie (to omija ściany!)
		var next_path_pos = nav_agent.get_next_path_position()
		
		# 4. Obliczamy kierunek do TEGO punktu, a nie bezpośrednio do gracza
		var new_velocity = global_position.direction_to(next_path_pos) * speed
		
		velocity = new_velocity
		move_and_slide()
