extends Node
class_name BattleController

## Class for battle

## Stores nodes of enemies to fight
var enemies_to_fight: Array

## Holds gameover state
var gameover: bool = false


## Holds the controller for characters
@onready var battle_flow_manager: BattleFlowManager = $BattleFlowManager
@onready var characters_controller: CharactersController = $CharactersController
@onready var ui_controller: UIController = $UIController


## Initialize battle scene. Has to be called before adding to scene tree.
## Accepts an array of enemy nodes to fight.
func initialize(enemies_to_fight: Array):
	self.enemies_to_fight = enemies_to_fight


## Initializes controllers
func init_controllers():
	battle_flow_manager.initialize(
		characters_controller,
		ui_controller
	)
	characters_controller.initialize(
		battle_flow_manager,
		ui_controller
	)
	ui_controller.initialize(
		battle_flow_manager
	)


## Ready function
func _ready():
	init_controllers()
	characters_controller.add_characters(enemies_to_fight)
	characters_controller.setup_characters()
	ui_controller.connect_signals()
