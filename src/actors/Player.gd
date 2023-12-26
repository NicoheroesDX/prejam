extends CharacterBody2D

const SPEED = 30.0
const SPEED_LIMIT = 300.0
const AIR_RESISTANCE = 10.0;

@onready var stompCooldown = get_node("StompCooldown")
@onready var glider = get_node("GlideParticles")
@onready var stompParticles = get_node("StompParticles")

@onready var beam = get_node("PlayerAttack/BeamParticles")
@onready var beamCore = get_node("PlayerAttack/CoreParticles")
@onready var beamHitbox = get_node("PlayerAttack/BeamArea")

@onready var stompSound = get_node("StompSound")
@onready var beamSound = get_node("PlayerAttack/BeamSound")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var isPlayingBeamSound = false;

func _process(delta):
	var closest_enemy = find_closest_enemy()

func find_closest_enemy() -> Node2D:
	var closest_enemy: Node2D = null
	var min_distance = float('inf')
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		
		if distance < min_distance and distance < 1000:
			min_distance = distance
			closest_enemy = enemy
	
	return closest_enemy

func _physics_process(delta):
	# Check if player is out of bounds
	if global_position.y > 800:
		die();
	
	Global.update_speed((700 + global_position.x) * 0.1)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("player_left", "player_right")
	if direction:
		velocity.x += direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	beam.emitting = Global.collectedLight > 0 && Input.is_action_pressed("player_shoot")
	
	beamCore.emitting = beam.emitting
	
	if beam.emitting:
		Global.change_collected_light(-24);
		velocity.x -= 150
		if not isPlayingBeamSound:
			beamSound.play()
			isPlayingBeamSound = true
		for body in beamHitbox.get_overlapping_bodies():
			if (body.get_groups().has("enemy")):
				body.deal_damage(15);
	else:
		beamSound.stop();
		isPlayingBeamSound = false;
	
	velocity.x -= AIR_RESISTANCE;
	
	if velocity.x > 0:
		velocity.x = min(SPEED_LIMIT, velocity.x)
	elif velocity.x < 0:
		velocity.x = max(-SPEED_LIMIT, velocity.x)
	
	if stompCooldown.time_left == 0 && Global.collectedLight > 0 && Input.is_action_just_pressed("player_down"):
		velocity.y = 1000;
		Global.change_collected_light(-8);
		stompSound.play();
		stompCooldown.wait_time = 0.2;
		stompCooldown.start();
	
	if Global.collectedLight > 0 && Input.is_action_pressed("player_up"):
		velocity.y = 10;
		glider.emitting = true;
		Global.change_collected_light(-16);
	else:
		glider.emitting = false;
	
	if velocity.y > 600:
		stompParticles.emitting = true
	else:
		stompParticles.emitting = false
	
	move_and_slide()

func die():
	global_position.y = -300
	velocity = Vector2(0,0)
	Global.change_scene("res://src/menu/GameOver.tscn")
