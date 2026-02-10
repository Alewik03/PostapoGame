extends CharacterBody2D

var speed = 120
@onready var nav_agent = $NavigationAgent2D # Musisz mieć ten węzeł w scenie!
var player = null
var targets_in_range = []

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


func _on_attack_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		targets_in_range.append(body) # Dodaj gracza do listy "do bicia"
		if $AttackTimer.is_stopped():
			$AttackTimer.start() # Odpal odliczanie
			_deal_damage_to_all() # Opcjonalnie: uderz od razu przy dotknięciu
			
func _on_attack_zone_body_exited(body: Node2D) -> void:
	if body in targets_in_range:
		targets_in_range.erase(body) # Gracz uciekł, usuń go z listy
		if targets_in_range.is_empty():
			$AttackTimer.stop() # Nikt nie został w zasięgu? Wyłącz timer.


func _on_attack_cooldown_timeout() -> void:
	_deal_damage_to_all()

func _deal_damage_to_all():
	for target in targets_in_range:
		var health = target.get_node_or_null("HealthComponent")
		if health:
			health.TakeDamage(10)
