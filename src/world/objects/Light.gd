extends AnimatableBody2D

var speed = 0

func _process(delta):
	if global_position.x < -1000:
		queue_free()

func _physics_process(delta):
	speed = -0.03 * Global.speed;
	move_and_collide(Vector2(speed, 0))

func _on_player_collector_body_entered(body):
	if (body.get_groups().has("player")):
		collect()

func collect():
	Global.change_collected_light(+1);
	queue_free();
