extends Node
class_name CharactersController

## Class for controlling in-battle characters


## Stores root scene.
## Used for adding child scenes.
@onready var root: Node = $".."

## Holds nodes of knight and cowboy
var knight_node: Node2D = Utils.Resources["KNIGHT"].instantiate()
var cowboy_node: Node2D = Utils.Resources["COWBOY"].instantiate()
var player_nodes: Array

## Holds nodes of enemies
var enemy_nodes: Array


## Begin export groups for character's position in-battle.
@export_category("Players")
@export_group("Positions")
## Stores the player's battle position when there's only one hero.
@export var SINGLE_PLAYER_POS = Vector2(600, 500)

## Stores the players' battle position when there are 2-3 heroes.
@export var MULTIPLE_PLAYER_POS = [
	Vector2(700, 285),
	Vector2(700, 750),
	Vector2(500, 525)
]

@export_category("Enemies")
@export_group("Positions")
## Stores the enemy's battle position if there's only one enemy.
@export var SINGLE_ENEMY_POS = Vector2(1300, 500)

## Stores the players' battle position when there are 2-3 enemies.
@export var MULTIPLE_ENEMY_POS = [
	Vector2(1200, 285),
	Vector2(1200, 750),
	Vector2(1400, 525)
]


## Holds how many players are on field
var player_count: int = 2

## Holds how many enemies are on field
var enemy_count: int = 0

## Holds the scene of character's battle health bar
var health_bar_scene: PackedScene = Utils.Resources["BATTLE_HEALTH_BAR"]

## CharactersController has to store BattleFlowManager and UIController
var battle_flow_manager: BattleFlowManager
var ui_controller: UIController


## Adds battle characters to scene tree
func add_characters(
	enemies: Array,
	players: Array = [knight_node, cowboy_node]
):
	## Returns if enemies array is empty
	if enemies.is_empty():
		return
	
	## Stores nodes and adds to scene tree
	player_nodes = players.duplicate()
	for player in players:
		add_child(player)
	
	## Do the same but for the enemies
	enemy_nodes = enemies.duplicate()
	for enemy in enemies:
		add_child(enemy)


## Using a given character, attacks a given enemy.
func attack(
	attacker: BaseCharacter,
	attack_id: String,
	target: BaseCharacter,
	is_skill: bool = false
):
	## Handles if attack is a skill
	if is_skill:
		attacker.skill_attack(attack_id, target)
	else:
		attacker.attack(attack_id, target)


## Decreases character's energy by given value.
func decrease_energy(char_node: BaseCharacter, value: int = 1):
	char_node.energy -= value


## Gets enemy node from enemy_nodes array at given index.
func get_enemy(index: int) -> BaseCharacter:
	return enemy_nodes[index]


## Gets index of the next enemy in enemy_nodes array after given index.
## Returns -1 if all enemies are dead.
func get_next_enemy(index: int) -> int:
	## Checks if all enemies are dead.
	var is_all_dead: bool = true
	for enemy in enemy_nodes:
		if not enemy.is_dead:
			is_all_dead = false
			break
	if is_all_dead:
		return -1
	
	## Increment index
	index += 1
	
	## If index has overflowed the array, go back to 0.
	if index >= enemy_nodes.size():
		index = 0
	
	## If currently selected enemy is dead, returns the next not-dead enemy.
	if enemy_nodes[index].is_dead:
		return get_next_enemy(index)
	
	## Otherwise, returns the incremented index.
	return index


## Gets a character's original position
func get_original_position(char_node: BaseCharacter):
	var index: int
	var pos: Vector2
	
	## Handles cases where character is a player or an enemy
	index = is_player(char_node)
	if index >= 0: ## Is a player
		if player_count > 1:
			pos = MULTIPLE_PLAYER_POS[index]
		else:
			pos = SINGLE_PLAYER_POS
	else: ## Is an enemy
		index = is_enemy(char_node)
		if enemy_count > 1:
			pos = MULTIPLE_ENEMY_POS[index]
		else:
			pos = SINGLE_ENEMY_POS
	
	return pos


## Gets player node from player_nodes array at given index.
func get_player(index: int) -> BaseCharacter:
	return player_nodes[index]


## Recharge character's energy, increment current energy by given value.
func increase_energy(char_node: BaseCharacter, value: int = 2):
	char_node.energy += value


## Initiates strategy. Called only for enemy.
## Accepts the acting enemy as argument.
func initiate_enemy_strategy(acting_enemy: BaseEnemy):
	## Connects the enemy signals (one-shot)
	acting_enemy.action_attack.connect(
		battle_flow_manager.on_committed_attack_signal,
		CONNECT_ONE_SHOT
	)
	acting_enemy.action_guard.connect(
		battle_flow_manager.on_guard_signal,
		CONNECT_ONE_SHOT
	)
	## Tells the enemy to take action
	var action: String = acting_enemy.take_action(player_nodes.duplicate())
	
	match action:
		"attack":
			## Waits for action to finish, then end turn
			await acting_enemy.action_finished
			battle_flow_manager.end_turn()


## Initializes CharactersController
func initialize(
	battle_flow_manager: BattleFlowManager,
	ui_controller: UIController
):
	self.battle_flow_manager = battle_flow_manager
	self.ui_controller = ui_controller


## Checks if a character is an enemy.
## Returns the index of char_node in enemy_nodes array if found,
## otherwise returns -1.
func is_enemy(char_node: BaseCharacter) -> int :
	return enemy_nodes.find(char_node)


## Checks if a character has run out of energy.
func is_energy_empty(char_node: BaseCharacter) -> bool :
	return char_node.energy == 0


## Checks if a character is in its original position.
func is_in_original_position(char_node: BaseCharacter) -> bool :
	return char_node.position == get_original_position(char_node)


## Checks if a character is a player.
## Returns the index of char_node in player_nodes array if found,
## otherwise returns -1.
func is_player(char_node: BaseCharacter) -> int :
	return player_nodes.find(char_node)


## Moves a character to its original position.
func move_to_original_position(char_node: BaseCharacter):
	## Gets its original position
	var pos: Vector2 = get_original_position(char_node)
	
	## Moves character to its original position.
	char_node.move_to(pos)


## Sets character's guard state
func set_character_guard(char_node: BaseCharacter, is_guarding: bool):
	char_node.guarding = is_guarding


## Pauses/Resumes characters' battle timer
func set_paused_battle_timers(is_paused: bool):
	for child in get_children():
		## Skips if child is not a character
		if not child is CharacterBody2D:
			continue
		
		## Skips if character is dead
		if child.is_dead:
			continue
		
		match is_paused:
			true:
				child.pause_battle_timer()
			false:
				child.resume_battle_timer()


## Sets up battle characters.
func setup_characters():
	## For each characters, creates a battle turn indicator for it,
	## places them on their positions, connects their battle signals,
	## and creates their health bars. Use MULTIPLE_[PLAYER/ENEMY]_POS
	## if there are more than one players/enemies on field, otherwise
	## use SINGLE_[PLAYER/ENEMY]_POS.
	
	player_count = player_nodes.size()
	if player_count > 1:
		for i in player_count:
			_setup_character(
				player_nodes[i],
				MULTIPLE_PLAYER_POS[i],
				false
			)
	else:
		_setup_character(
			player_nodes[0],
			SINGLE_PLAYER_POS,
			false
		)
	
	enemy_count = enemy_nodes.size()
	if enemy_count > 1:
		for i in enemy_count:
			_setup_character(
				enemy_nodes[i],
				MULTIPLE_ENEMY_POS[i],
				true
			)
	else:
		_setup_character(
			enemy_nodes[0],
			SINGLE_ENEMY_POS,
			true
		)


## Sets up an individual character.
## This is a tail function for _setup_characters.
func _setup_character(
	char_node: BaseCharacter,
	pos: Vector2,
	is_enemy: bool,
):
	## Adds indicator
	ui_controller.wait_bar.add_indicator(
		char_node.char_battle_indicator,
		char_node.battle_delay,
		char_node.get_name()
	)
	
	## Places them on their positions
	char_node.set_position(pos)
	
	## Adds health bars
	ui_controller.create_healthbar(char_node, is_enemy)
	
	## Connects battle, damage, skill_activated, and dead signal
	char_node.battle_action.connect(battle_flow_manager.begin_turn)
	char_node.damage.connect(battle_flow_manager.on_damage_signal)
	char_node.skill_activated.connect(ui_controller.create_skill_indicator)
	char_node.death.connect(battle_flow_manager.on_dead_signal)
