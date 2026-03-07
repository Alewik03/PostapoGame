extends Node

@export var MaxHealth = 100
var CurrentHealth
var isDead = false
signal died

func _ready() -> void:
	CurrentHealth = MaxHealth

func TakeDamage(damage):
	if isDead == true: #Potrzebujemy tego,  zeby gracz/item nie umarł przez przypadek dwa razy,
		return #jakby dostał dwa razy obrażenia poniżej 0 HP
	
	CurrentHealth = CurrentHealth - damage 
	print("Obrażenie! Pozostało HP: ", CurrentHealth)
	if CurrentHealth <= 0:
		isDead = true
		died.emit()
		print("GAME OVER")
