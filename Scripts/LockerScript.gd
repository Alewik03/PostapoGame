extends StaticBody2D

@onready var exit_marker: Marker2D = $Exit_Marker2D
@onready var locker_camera: Camera2D = $Camera2D

var is_player_nearby: bool = false
var player_node: Node2D = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_node:
		if not player_node.is_hiding and is_player_nearby:
			enter_locker()
		elif player_node.is_hiding and player_node.current_locker == self:
			exit_locker()

func enter_locker() -> void:
	player_node.hide_in_locker(self, exit_marker.global_position, locker_camera)

func exit_locker() -> void:
	player_node.unhide_from_locker()

func _on_interaction_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = true
		player_node = body

func _on_interaction_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not body.is_hiding:
			is_player_nearby = false
			player_node = null
