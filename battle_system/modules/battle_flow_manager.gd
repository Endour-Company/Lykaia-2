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

## Defense modifier while guarding, will influence the character's total
## defense power.
@export var defense_modifier_with_guard: float = 2.5


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
		## If currently targeted enemy is dead, change target.
		if chars_controller.get_enemy(index_target_enemy).is_dead:
			index_target_enemy = chars_controller.get_next_enemy(index_target_enemy)
		
		## Spawns battle pointer
		ui_controller.spawn_battle_pointer(
			chars_controller.get_enemy(index_target_enemy).position
		)
		
		## Shows command buttons
		ui_controller.command_buttons.show_actions()
	else:
		## Initate enemy strategy
		chars_controller.initiate_enemy_strategy(acting_character)


## Ends a character's turn
func end_turn():
	## Clears character's combo queue
	acting_character.combo_queue.clear()
	
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
		acting_character.battle_delay,
		acting_character.get_name()
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
func on_committed_attack_signal(index_attack: int, target = null):
	## Decreases character's energy by one.
	chars_controller.decrease_energy(acting_character)
	
	## If the character is a player, sets the target to enemy on index_target_enemy.
	## Otherwise, use the given target.
	if chars_controller.is_player(acting_character) >= 0:
		## Sets the attack target
		target = chars_controller.get_enemy(index_target_enemy)
		
		## If the player has runs out of energy or if enemy is dead,
		## disables attack choices in attack command buttons.
		if chars_controller.is_energy_empty(acting_character):
			ui_controller.command_buttons.disable_attack_choices()
	
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
	attack_id: String,
	target: BaseCharacter
):
	## Checks if attack hits
	if _does_attack_hit(attacker.accuracy, target.evasion):
		## Gets the attack's attack power
		var attack_data: Dictionary = Utils.find_dictionary_in_array_with_value(
			attacker.attack_set,
			"id",
			attack_id
		)
		var attack_power: float = attack_data.get("power")
		
		## Calculates damage
		var total_damage = _calculate_damage(
			attacker.strength,
			target.defense,
			attack_power,
			target.guarding
		)
		
		## Spawns damage indicator at the target's position
		ui_controller.spawn_damage_indicator(
			str(total_damage), target.position
		)
		
		## Changes the target's health
		target.health -= total_damage
		
		## Adds attack to combo queue
		attacker.combo_queue.append(attack_id)
		
		## Checks for skill activation
		var skill = attacker.get_fulfilled_skill()
		if skill != null:
			chars_controller.attack(
				attacker, skill, target, true
			)
	else:
		## Spawns damage indicator at the target's position that
		## indicates the attack missed.
		ui_controller.spawn_damage_indicator(
			"MISS", target.position
		)


## Handles dead signal, emitted whenever a character has died in battle.
## Removes battle timer, and plays dead animation.
func on_dead_signal(char_node: BaseCharacter):
	print(char_node.get_name() + "is DEAD")
	## Pauses the character's battle timer and removes its timer indicator.
	char_node.pause_battle_timer()
	ui_controller.wait_bar.remove_indicator_of_char(char_node.get_name())
	
	## Plays death animation.
	char_node.play_death_animation()


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
	attack_power: float,
	is_target_guarding: bool
):
	## Calculates total attack power
	var total_attack_power: float = \
	attack_modifier * attacker_strength * attack_power
	
	## Calculates total defense power
	var total_defense_power: float
	if is_target_guarding:
		total_defense_power = defense_modifier_with_guard * target_defense
	else:
		total_defense_power = defense_modifier * target_defense
	
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
