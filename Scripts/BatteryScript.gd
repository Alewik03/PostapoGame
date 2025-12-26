extends Area2D

@export var energy_amount = 50.0 # Ile energii przywraca ta konkretna bateria

func _on_body_entered(body: Node2D) -> void:
	# Sprawdzamy, czy obiekt który wszedł ma zmienną battery_level
	# To lepsze niż sprawdzanie nazwy "Player", bo zadziała na wszystko co ma baterię
	if body.has_method("add_battery"):
		body.add_battery(energy_amount)
		queue_free() # Usuwa baterię ze sceny
