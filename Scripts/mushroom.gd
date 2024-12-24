extends CharacterBody2D

class_name MushroomEnemy

var speed = 50
var is_mush_chase: bool = true

var health = 80
var max_health = 80
var health_min = 0

var dead: bool = false
var taking_damage: bool = false
var damage = 20
var is_dealing_damage: bool = false

var dir: Vector2
const gravity = 900
var knockback_force = -20
var is_roaming: bool = true

var player: CharacterBody2D
var player_in_area: bool = false

func _process(delta: float):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
		
		Global.mushDamageAmount = damage
		Global.mushDamageZone = $MushDealDamageArea
		player = Global.playerBody
		
	move(delta)
	handle_animation()
	move_and_slide()
	
func move(delta):
	if !dead:
		if !is_mush_chase:
			velocity += dir * speed * delta
		elif is_mush_chase and !taking_damage:
			var dir_to_player = position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage:
			var knockback_dir = position.direction_to(player.position) * knockback_force
			velocity.x = knockback_dir.x
		is_roaming = true
	elif dead:
		velocity.x = 0

func handle_animation():
	var animated_sprite = $AnimatedSprite2D
	if !dead and !taking_damage and !is_dealing_damage:
		animated_sprite.play("walk")
		if dir.x == -1:
			animated_sprite.flip_h = true
		elif dir.x == 1:
			animated_sprite.flip_h = false
	elif !dead and taking_damage and !is_dealing_damage:
		animated_sprite.play("hit")
		await get_tree().create_timer(0.5).timeout
		taking_damage = false
	elif dead and is_roaming:
		is_roaming = false
		animated_sprite.play("death")
		await get_tree().create_timer(1.0).timeout
		handle_death()
		
func handle_death():
	self.queue_free()

func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = choose([2.5,3.0,3.5])
	if !is_mush_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0
		

func choose(array):
	array.shuffle()
	return array.front()

func _on_mush_hitbox_area_entered(area: Area2D) -> void:
	var damage = Global.playerDamageAmount
	if area == Global.playerDamageZone:
		take_damage(damage)

func take_damage(damage):
	health -= damage
	taking_damage = true
	if health <= health_min:
		health = health_min
		dead = true
	print(str(self), "current health is ", health)
