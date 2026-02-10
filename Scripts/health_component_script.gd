extends Node

@export var MaxHealth = 100
var CurrentHealth
signal isDead

func _ready() -> void:
	CurrentHealth = MaxHealth

func TakeDamage(damage):
	CurrentHealth = CurrentHealth - damage 
	print("Obrażenie! Pozostało HP: ", CurrentHealth)
	if CurrentHealth <= 0:
		isDead.emit()
		print("GAME OVER")
