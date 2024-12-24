extends Node2D

@onready var player_camera  = $Player/Camera2D
@onready var scene_transition_animation = $SceneTransitionAnimation/AnimationPlayer


var current_wave: int = 1
@export var mush_scene: PackedScene 
@export var eye_scene: PackedScene 

var starting_nodes: int 
var current_nodes: int
var wave_spawn_ended

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene_transition_animation.get_parent().get_node("ColorRect").color.a = 255
	scene_transition_animation.play("fade_out")
	player_camera.enabled = true
	Global.current_wave = current_wave
	starting_nodes = get_child_count()
	current_nodes = get_child_count()
	position_to_next_wave()
	
	
func position_to_next_wave():
	if current_nodes == starting_nodes: 
		if current_wave != 0:
			Global.moving_to_next_wave = true
		scene_transition_animation.play("between_wave")
		current_wave += 1
		Global.current_wave = current_wave
		await get_tree().create_timer(0.5).timeout
		prepare_spawn("eyes", 4.0, 4) #type, multiplier, spawns
		prepare_spawn("mushes", 1.5, 2) #type, multiplier, spawns
		print("Current Wave = ", current_wave)
	
	
func prepare_spawn(type, multiplier, mob_spawns):
	var mob_amount = float(current_wave) * multiplier
	var mob_wait_time: float = 2.0
	print("mob_amount: ", mob_amount)
	var mob_spawn_rounds = mob_amount/mob_spawns
	spawn_type(type, mob_spawn_rounds, mob_wait_time)
	
func spawn_type(type, mob_spawn_rounds, mob_wait_time):
	if type == "eyes":
		var eye_spawn1 = $EyeSpawnPoint1
		var eye_spawn2 = $EyeSpawnPoint2
		var eye_spawn3 = $EyeSpawnPoint3
		var eye_spawn4 = $EyeSpawnPoint4
		if mob_spawn_rounds >= 1:
			for i in mob_spawn_rounds:
				var eye1 = eye_scene.instantiate()
				eye1.global_position = eye_spawn1.global_position
				var eye2 = eye_scene.instantiate()
				eye2.global_position = eye_spawn2.global_position
				var eye3 = eye_scene.instantiate()
				eye3.global_position = eye_spawn3.global_position
				var eye4 = eye_scene.instantiate()
				eye4.global_position = eye_spawn4.global_position
				add_child(eye1)
				add_child(eye2)
				add_child(eye3)
				add_child(eye4)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
	elif type == "mushes":
		var mush_spawn1 = $MushSpawnPoint1
		var mush_spawn2 = $MushSpawnPoint2
		if mob_spawn_rounds >= 1:
			for i in mob_spawn_rounds:
				var mush1 = mush_scene.instantiate()
				mush1.global_position = mush_spawn1.global_position
				var mush2 = mush_scene.instantiate()
				mush2.global_position = mush_spawn2.global_position
				add_child(mush1)
				add_child(mush2)
				mob_spawn_rounds -= 1
				await get_tree().create_timer(mob_wait_time).timeout
			wave_spawn_ended = true
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !Global.playerAlive: 
		Global.gameStarted = false
		scene_transition_animation.play("fade_in")
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://Scenes/lobby.tscn")
