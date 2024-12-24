extends Node2D

@onready var player_camera  = $Player/Camera2D
@onready var scene_transition_animation = $SceneTransitionAnimation/AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene_transition_animation.get_parent().get_node("ColorRect").color.a = 255
	scene_transition_animation.play("fade_out")
	player_camera.enabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_scene_change_detector_body_entered(body) -> void:
	if body is Player:
		Global.gameStarted = true
		scene_transition_animation.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://Scenes/StageLevel.tscn")
