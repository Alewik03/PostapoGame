extends CharacterBody2D

var speed = 120
@onready var nav_agent = $NavigationAgent2D # Musisz mieć ten węzeł w scenie!
var player = null
var targets_in_range = []

# Zakładamy, że gracz jest na Warstwie Kolizji (Collision Layer) nr 1. 
# Jeśli gracz jest na innej warstwie, zmień ten numer poniżej (1-32):
@export var player_collision_layer: int = 1 

func _ready() -> void:
	# Szukamy gracza w grupie
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	# Jeśli gracz ukrywa się w szafce, traktujemy go jak niewidzialnego / brak celu
	if player and not (player.has_method("is_hiding") and player.is_hiding):
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
	else:
		# Gdy gracz schowany, wróg zatrzymuje się lub szuka dalej
		velocity = Vector2.ZERO
		move_and_slide()


func _on_attack_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not body in targets_in_range:
			targets_in_range.append(body) # Dodaj gracza do listy "do bicia"
		
		# Sprawdzamy czy timer istnieje ($AttackTimer lub $AttackCooldown)
		var timer = get_node_or_null("AttackTimer")
		if timer and timer.is_stopped():
			timer.start() # Odpal odliczanie
			_deal_damage_to_all() # Uderz od razu przy dotknięciu
			
func _on_attack_zone_body_exited(body: Node2D) -> void:
	if body in targets_in_range:
		targets_in_range.erase(body) # Gracz uciekł, usuń go z listy
		if targets_in_range.is_empty():
			var timer = get_node_or_null("AttackTimer")
			if timer:
				timer.stop() # Nikt nie został w zasięgu? Wyłącz timer.


# Obsługa timera (zależnie czy nazwałeś go AttackTimer czy AttackCooldown)
func _on_attack_timer_timeout() -> void:
	_deal_damage_to_all()

func _on_attack_cooldown_timeout() -> void:
	_deal_damage_to_all()

func _deal_damage_to_all():
	for target in targets_in_range:
		var health = target.get_node_or_null("HealthComponent")
		if health:
			health.TakeDamage(10)
			print("Wróg zadał obrażenia! Wyłączam kolizję z graczem na 1.5s")
			
			# TYMCZASOWE WYŁĄCZENIE KOLIZJI Z GRACZEM
			_disable_collision_with_player_temporarily()

func _disable_collision_with_player_temporarily() -> void:
	# Wyłączamy wykrywanie kolizji w maski dla warstwy gracza
	set_collision_mask_value(player_collision_layer, false)
	
	# Tworzymy bezpieczny timer jednorazowy w Godocie na 1.5 sekundy
	await get_tree().create_timer(1.5).timeout
	
	# Przywracamy kolizję z graczem
	set_collision_mask_value(player_collision_layer, true)
