extends AnimatableBody2D

var speed = 0
var isUsed = false;

@onready var player = get_parent().get_node("Player")
@onready var animationPlayer = get_node("AnimationPlayer")

func _process(delta):
	if global_position.x < -1000:
		queue_free()

func _physics_process(delta):
	speed = -0.1 * Global.speed;
	move_and_collide(Vector2(speed, 0))

func bounce_player():
	if isUsed: return
	player.velocity.y = -400;
	isUsed = true;
	animationPlayer.play("scaling");
	player.stompCooldown.wait_time = 0.1;
	player.stompCooldown.start();

func _on_player_bouncer_body_entered(body):
	if (body.get_groups().has("player")):
		bounce_player();

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "scaling":
		queue_free()
