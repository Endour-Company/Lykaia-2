extends Node
class_name UIController

## Class for controlling battle UI elements

## Holds the battle screen node for future adding of any UI items
@onready var battle_screen: CanvasLayer = $BattleScreen

## Holds the battle wait bar interface for handling character's indicators
@onready var wait_bar: BattleWaitBar = $BattleScreen/BattleWaitBar

## Holds the player turn indicator node for indicating which turn
## of the player's characters it is.
@onready var player_turn_indicator: PlayerTurnIndicator = $BattleScreen/PlayerTurnIndicator

## Holds the combo prompt node for controlling buttons that appears in prompt.
@onready var combo_prompt: ComboPrompt = $BattleScreen/ComboPrompt

## Holds the battle command buttons for handling showing and hiding buttons
@onready var command_buttons: CommandButtons = $BattleScreen/CommandButtons

## Holds the scene of character's battle health bar
var health_bar_scene: PackedScene = Utils.Resources["BATTLE_HEALTH_BAR"]

## Holds the scene of battle pointer and its node
var battle_pointer_scene: PackedScene = Utils.Resources["BATTLE_POINTER"]
var battle_pointer: Control

## Stores offset of battle pointer relative to character
var battle_pointer_offset: Vector2 = Vector2(-32, -150)

## Holds the scene of damage indicator
var damage_indicator_scene: PackedScene = Utils.Resources["DAMAGE_INDICATOR"]

## Holds the skill indicator scene for creating skill activation's popups.
var skill_indicator_scene: PackedScene = Utils.Resources["SKILL_INDICATOR"]

## UIController has to store BattleFlowManager
var battle_flow_manager: BattleFlowManager


## Creates health bar
func create_healthbar(char_node: BaseCharacter, is_enemy: bool):
	var health_bar: BattleHealthBar = health_bar_scene.instantiate()
	var health_bar_pos: Vector2
	if is_enemy:
		health_bar_pos = char_node.position + Vector2(25,10)
	else:
		health_bar_pos = char_node.position + Vector2(-225,10)
	battle_screen.add_child(health_bar)
	health_bar.setup(
		char_node.char_name,
		char_node.health,
		char_node.max_health,
		char_node.energy,
		health_bar_pos,
		is_enemy
	)
	
	## Connects character's health and energy changed signals to healthbar
	char_node.health_changed.connect(health_bar.set_health)
	char_node.energy_changed.connect(health_bar.set_energy)


## Creates and shows skill indicator.
func create_skill_indicator(skill_name: String):
	## Creates a new skill indicator node, it will automatically be freed
	## when it's done playing its animation.
	var skill_indicator: SkillIndicator = skill_indicator_scene.instantiate()
	battle_screen.add_child(skill_indicator)
	
	## Sets skill's name.
	skill_indicator.set_indicator_text(skill_name)


## Connects command button signals
func connect_signals():
	## Connects the signal of when the main attack button is pressed,
	## to transition to attack mode.
	command_buttons.attack_pressed.connect(
		battle_flow_manager.on_attack_signal
	)
	
	## Connects the signal of when player has chosen an attack.
	command_buttons.attack.connect(
		battle_flow_manager.on_committed_attack_signal
	)
	command_buttons.attack.connect(
		combo_prompt.add_button
	)
	
	## Connects the end attack signal, to end a combo.
	command_buttons.end_attack.connect(
		battle_flow_manager.on_end_attack_signal
	)
	
	## Connects the cancel attack signal, to cancel and go back to main mode.
	## This can only happen when the attack is in attack mode, but
	## has not chosen any attack yet.
	command_buttons.cancel_attack.connect(
		battle_flow_manager.on_cancel_attack_signal
	)
	
	## Connects the guard signal, to set guard mode of character.
	command_buttons.guard_pressed.connect(
		battle_flow_manager.on_guard_signal
	)
	
	## Connects the target signal, to change targeted enemy.
	command_buttons.target_pressed.connect(
		battle_flow_manager.on_target_signal
	)


## Initializes UIController
func initialize(battle_flow_manager: BattleFlowManager):
	self.battle_flow_manager = battle_flow_manager


## Spawns battle pointer at given position
func spawn_battle_pointer(position):
	## Instantiate a new battle pointer if there is none yet
	if not is_instance_valid(battle_pointer):
		battle_pointer = battle_pointer_scene.instantiate()
		
		## Adds battle pointer to scene tree
		battle_screen.add_child(battle_pointer)
	
	## Sets battle pointer's position
	battle_pointer.set_position(position + battle_pointer_offset)


## Spawns damage indicator with given text and at given position
func spawn_damage_indicator(text: String, pos: Vector2):
	## Stores offset
	var offset: Vector2 = Vector2(0, -80)
	
	## Instantiates a damage indicator scene
	var damage_indicator: Control = damage_indicator_scene.instantiate()
	damage_indicator.setup(text, pos + offset)
	
	## Adds the scene to tree
	battle_screen.add_child(damage_indicator)


## Removes battle pointer from scene
func remove_battle_pointer():
	battle_pointer.queue_free()
