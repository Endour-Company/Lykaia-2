extends Node

## Main class


## Stores scene nodes
var battle_scene: BattleController

## Stores enemies to fight in battle
var enemies_to_fight: Array = []

## Stores loading screen's node
@onready var loading_screen: CanvasLayer = $LoadingScreen


## Adds enemies to fight, accepts up to three enemy identifiers/char_name
func adds_enemies_to_fight(enemies: Array):
	for i in range(3):
		## Breaks out of loop if i is already larger than enemies array length
		if i > enemies.size() - 1:
			return
		
		## Skips if enemy is invalid
		if not Utils.Resources.has(enemies[i].to_upper()):
			continue
		enemies_to_fight.append(Utils.Resources[enemies[i].to_upper()].instantiate())


func _ready():
	## Adds enemies to fight
	var enemies = ["Wolf", "Wolf", "Wolf"]
	adds_enemies_to_fight(enemies)
	
	## Loads battle screen, for now
	loading_screen.load_scene(Utils.Path["BATTLE_SCENE"])


## Starts battle with enemies
func _start_battle(scene: PackedScene):
	battle_scene = scene.instantiate()
	battle_scene.initialize(enemies_to_fight)
	add_child(battle_scene)


func _on_loading_screen_loading_complete(loaded_scene):
	## Gets scene's name
	var scene_name: String = loaded_scene.get_state().get_node_name(0)
	
	## Do actions based on which scene it is
	match scene_name:
		"Battle":
			_start_battle(loaded_scene)
