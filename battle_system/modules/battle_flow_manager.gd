extends Node
class_name BattleFlowManager

## Class for managing battle flow,
## such as starting and ending of a character's turn.


## Stores character that currently has their turn.
var acting_character: BaseCharacter

## Stores index of currently targeted enemy
var index_target_enemy: int = 0

## BattleFlowManager has to store a CharactersController and a UIController.
var chars_controller: CharactersController
var ui_controller: UIController

## Modifiers for some battle parameters such as attack and defense
@export_group("Battle Modifiers")

## Attack modifier, will influence the character's total attack power.
@export var attack_modifier: float = 2.5

## Defense modifier, will influence the character's total defense power.
@export var defense_modifier: float = 1.25


## Begins a character's turn
func begin_turn(char_node: BaseCharacter):
	## Sets acting character
	acting_character = char_node
	
	## Pauses all characters' turn timer
	chars_controller.set_paused_battle_timers(true)
	
	## Pauses all turn timer indicators
	ui_controller.wait_bar.pause_indicators()
	
	## Recharges character's energy
	chars_controller.increase_energy(acting_character)
	
	## Cancels character's guard state
	chars_controller.set_character_guard(acting_character, false)
	
	## If acting character is a player, spawn battle pointer
	## at targeted enemy and shows command buttons.
	if chars_controller.is_player(acting_character) >= 0:
		ui_controller.spawn_battle_pointer(
			chars_controller.get_enemy(index_target_enemy).position
		)
		ui_controller.command_buttons.show_actions()
	else:
		## Initate enemy strategy
		chars_controller.initiate_enemy_strategy(acting_character)


## Ends a character's turn
func end_turn():
	## Moves character back to its original position if they're not already,
	## and waits until they finished moving.
	if not chars_controller.is_in_original_position(acting_character):
		chars_controller.move_to_original_position(acting_character)
		await acting_character.action_finished
	
	## If acting character is a player, despawns battle pointer
	## and hides command buttons.
	if chars_controller.is_player(acting_character) >= 0:
		ui_controller.remove_battle_pointer()
		ui_controller.command_buttons.hide_actions()
	
	## Waits 0.7 secs to give some delay before ending the turn
	await get_tree().create_timer(0.7).timeout
	
	## Resumes battle timer indicators
	ui_controller.wait_bar.resume_indicators()
	
	## Resumes all characters' battle timer
	chars_controller.set_paused_battle_timers(false)
	
	## Respawns acting character's battle timer indicator
	ui_controller.wait_bar.add_indicator(
		acting_character.char_battle_indicator,
		acting_character.battle_delay
	)


## Initializes BattleFlowManager.
func initialize(
	chars_controller: CharactersController,
	ui_controller: UIController
):
	self.chars_controller = chars_controller
	self.ui_controller = ui_controller


## Handles attack signal from command buttons.
## Hides current command buttons, and show attack command buttons.
func on_attack_signal():
	ui_controller.command_buttons.hide_actions(false)
	ui_controller.command_buttons.show_attack_commands(
		acting_character.attack_set
	)


## Handles cancel attack signal from command buttons.
## Hides attack command buttons and shows main command buttons.
func on_cancel_attack_signal():
	ui_controller.command_buttons.hide_attack_commands()
	ui_controller.command_buttons.show_actions(false)


## Handles committed attack signal from command buttons,
## which will be emitted when the player has chosen
## an attack from attack command buttons.
## Accepts the index of attack in attack_set array,
## and, optionally, the index of the target.
func on_committed_attack_signal(index_attack: int, index_target: int = 0):
	## Stores the attack target
	var target: BaseCharacter
	
	## Decreases character's energy by one.
	chars_controller.decrease_energy(acting_character)
	
	## If the character is a player, sets the index_target to the targeted.
	if chars_controller.is_player(acting_character) >= 0:
		index_target = index_target_enemy
		
		## Sets the attack target
		target = chars_controller.get_enemy(index_target)
		
		## If the player has runs out of energy, disabled attack choices
		## in attack command buttons.
		if chars_controller.is_energy_empty(acting_character):
			ui_controller.command_buttons.disable_attack_choices()
	else:
		## If the acting character is an enemy, sets a player as the attack
		## target.
		target = chars_controller.get_player(index_target)
	
	## Sends attack command to CharactersController
	chars_controller.attack(
		acting_character,
		acting_character.attack_set[index_attack]["id"],
		target
	)


## Handles damage signal, which will be emitted whenever a character
## has initiated an attack and the damage calculation is supposed to happen.
func on_damage_signal(
	attacker: BaseCharacter,
	attack_name: String,
	target: BaseCharacter
):
	## Checks if attack hits
	if _does_attack_hit(attacker.accuracy, target.evasion):
		## Gets the attack's attack power
		var attack_data: Dictionary = Utils.find_dictionary_in_array_with_value(
			attacker.attack_set,
			"id",
			attack_name
		)
		var attack_power: float = attack_data.get("power")
		
		## Calculates damage
		var total_damage = _calculate_damage(
			attacker.strength,
			target.defense,
			attack_power
		)
		print(total_damage)
	else:
		print("ATTACK MISSED")


## Handles end attack signal.
## Ends a character's attack combo, hides command buttons, and ends turn.
func on_end_attack_signal():
	## Hides attack command buttons immediately to prevent multiple calls.
	ui_controller.command_buttons.hide_attack_commands()
	
	## Wait for animation to finish
	## if acting character is currently moving/attacking.
	if acting_character.is_moving:
		await acting_character.action_finished
	
	end_turn()


## Handles guard signal from command buttons.
## Enables acting character's guard state
func on_guard_signal():
	chars_controller.set_character_guard(acting_character, true)
	end_turn()


## Handles target signal from command buttons.
## Changes target enemy to the next one in enemies array.
func on_target_signal():
	index_target_enemy = chars_controller.get_next_enemy(index_target_enemy)
	
	## If acting character is a player, resets battle pointer's position
	if chars_controller.is_player(acting_character) >= 0:
		ui_controller.spawn_battle_pointer(
			chars_controller.get_enemy(index_target_enemy).position
		)


## Calculates battle damage.
func _calculate_damage(
	attacker_strength: int,
	target_defense: int,
	attack_power: float
):
	## Calculates total attack power
	var total_attack_power: float = \
	attack_modifier * attacker_strength * attack_power
	
	## Calculates total defense power
	var total_defense_power: float = defense_modifier * target_defense
	
	## Gets a random value to lastly modify total damage
	var total_damage: float = total_attack_power - total_defense_power
	var damage_modifier: float = randf_range(
		-total_damage/15,
		total_damage/15
	)
	
	## Calculates final damage
	var final_damage: float = total_damage + damage_modifier
	if final_damage < 0:
		final_damage = 0
	elif final_damage > 999:
		final_damage = 999
	
	## Returns the rounded down result
	return floor(final_damage)


## Calculates whether an attack hits or not by substracting accuracy by
## evasion, and then divides the result with the accuracy and multiply
## it by 100 to convert it to a percentage value. Then, produce a random number
## ranging between 0-100, and if it's lower than that value, it will hit.
func _does_attack_hit(attacker_accuracy: int, target_evasion: int) -> bool :
	## Calculates hit chance
	var hit_chance: float = \
	1.0 * (attacker_accuracy - target_evasion) / attacker_accuracy * 100.0
	
	## Gets random value
	var random_value: int = randi() % 100
	
	## Checks if random value is lower than hit_chance, if it is then the
	## attack will hit.
	return random_value < hit_chance
