extends Node2D
class_name Level

onready var player: KinematicBody2D = get_node("Player")

func _ready() -> void:
	var _game_over:bool  = player.get_node("Texture").connect("game_over", self, "on_game_over")
	pass # Replace with function body.

func on_game_over() -> void:
	var _reload = get_tree().reload_current_scene()
	
