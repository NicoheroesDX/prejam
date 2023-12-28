extends Node

const BASE_WINDOW_SIZE = Vector2i(1152, 648)
const CONFIG_FILE_LOCATION = "user://somnistar_options.cfg"

var speed = 0
var collectedLight = 100000

signal update_collected_light_signal(new_light_amount, old_light_amount)

func update_speed(newGlobalSpeed):
	speed = newGlobalSpeed;

func change_collected_light(lightAmountOperation):
	var oldLightAmount = collectedLight
	var newLightAmount = collectedLight + lightAmountOperation
	if newLightAmount < 0:
		newLightAmount = 0;
	collectedLight = newLightAmount;
	update_collected_light_signal.emit(newLightAmount, oldLightAmount)

func reset_game_data():
	speed = 0
	collectedLight = 0

func change_scene_with_translation(pathToScene):
	var transitionLayer = get_tree().root.get_node("MainScene").get_node("TransitionLayer")
	if (transitionLayer != null):
		transitionLayer.start_transition_and_change_scene(pathToScene)
	else:
		change_scene(pathToScene)

func change_scene(pathToScene):
	var mainScene = get_tree().root.get_node("MainScene").get_node("MainDisplay")
	var transitionLayer = get_tree().root.get_node("MainScene").get_node("TransitionLayer")
	
	if (mainScene != null):
		var removable = mainScene.get_child(0)
		removable.queue_free()

		var scene_to_instantiate = load(pathToScene)
		var instantiated_scene = scene_to_instantiate.instantiate()
		
		mainScene.add_child(instantiated_scene)
