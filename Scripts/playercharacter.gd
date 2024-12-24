extends CharacterBody2D

class_name Player

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var deal_damage_zone: Area2D = $DealDamageZone

const jump_power = -350.0

var speed = 300.0
var attack_type: String
var current_attack: bool
var health = 100
var health_max = 100
var health_mix = 0
var can_take_damage: bool
var dead: bool

var gravity = 900


func _ready() -> void:
	Global.playerBody = self
	current_attack = false
	dead = false
	can_take_damage = true
	Global.playerAlive = true

func _physics_process(delta: float) -> void:	
	if not is_on_floor():
		velocity.y += gravity * delta
		Global.playerDamageZone = deal_damage_zone

	if !dead:
		if Input.is_action_just_pressed("jump") and is_on_floor() and !current_attack:
			velocity.y = jump_power

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)


		if !current_attack:
			if Input.is_action_just_pressed("attack1") or Input.is_action_just_pressed("attack2"):
				current_attack = true
				if Input.is_action_just_pressed("attack1") and is_on_floor():
					attack_type = "single"
				elif Input.is_action_just_pressed("attack2") and is_on_floor():
					attack_type = "double"
				else: 
					attack_type = "air"
			set_damage(attack_type)
			handle_attack_animation(attack_type)
			handle_movement_animation(direction)
			check_hitbox()
		move_and_slide()
		
func check_hitbox():
	var hitbox_areas = $PlayerHitbox.get_overlapping_areas()
	var damage: int
	if hitbox_areas:
		var hitbox = hitbox_areas.front()
		if hitbox.get_parent() is EyeEnemy:
			damage = Global.eyeDamageAmount
		elif hitbox.get_parent() is MushroomEnemy:
			damage = Global.mushDamageAmount
		
	if can_take_damage:
		take_damage(damage)
		
func take_damage(damage):
	if damage != 0:
		if health > 0:
			health -= damage
			print("player health: ", health)
			if health <= 0:
				health = 0
				dead = true
				handle_death_animation()
			take_damage_cooldown(1.0)
		
		
func handle_death_animation():
	animated_sprite.play("death")
	$Camera2D.position.y += 60
	$Camera2D.zoom.x = 3
	$Camera2D.zoom.y = 3
	await get_tree().create_timer(3).timeout
	Global.playerAlive = false
	await get_tree().create_timer(0.5).timeout
	self.queue_free()
	
func take_damage_cooldown(wait_time):
	can_take_damage = false
	await get_tree().create_timer(wait_time).timeout
	can_take_damage = true
	
func handle_movement_animation(dir):
		if is_on_floor() and !current_attack:
			if !velocity:
				animated_sprite.play("idle")
			if velocity:
				animated_sprite.play("walk")
				toggle_flip_sprite(dir)
		elif !is_on_floor() and !current_attack:
			animated_sprite.play("fall")
		
		
func toggle_flip_sprite(dir):
	if dir == 1:
		animated_sprite.flip_h = false
		deal_damage_zone.scale.x = 1
	if dir == -1:
		animated_sprite.flip_h = true
		deal_damage_zone.scale.x = -1

func handle_attack_animation(attack_type):
		if current_attack:
			var animation = str(attack_type, "_attack")
			animated_sprite.play(animation)
			toggle_damage_collision(attack_type)
			if attack_type == "air":
				speed = 100
			elif attack_type != "air":
				speed = 0

func toggle_damage_collision(attack_type):
	var damage_zone_collision = deal_damage_zone.get_node("CollisionShape2D")
	var wait_time: float
	if attack_type == "air":
		wait_time = 0.267
	elif attack_type == "single":
		wait_time = 0.3077
	elif attack_type == "double":
		wait_time = 0.7692
	damage_zone_collision.disabled = false
	await get_tree().create_timer(wait_time).timeout
	damage_zone_collision.disabled = true

func _on_animated_sprite_2d_animation_finished() -> void:
	current_attack = false 
	speed = 300

func set_damage(attack_type):
	var current_damage_to_deal: int
	if attack_type == "single":
		current_damage_to_deal = 8 
	elif attack_type == "double":
		current_damage_to_deal = 16
	elif attack_type == "air":
		current_damage_to_deal = 5
	Global.playerDamageAmount = current_damage_to_deal
