extends Node

## Class for utility functions


## Stores PATH to files that are needed by some scenes
var Path = {
	"ATTACK_SET": "res://resources/characters/modules/attack_set.json",
	"BATTLE_SCENE": "res://battle_system/battle.tscn",
	"SKILL_SET": "res://resources/characters/modules/skill_set.json",
}


## Stores RESOURCES that needs to be loaded by some scenes
var Resources = {
	"BATTLE_HEALTH_BAR": preload("res://resources/interfaces/battle_screen/modules/battle_health_bar/battle_health_bar.tscn"),
	"BATTLE_POINTER": preload("res://resources/interfaces/battle_screen/modules/battle_pointer/battle_pointer.tscn"),
	"BATTLE_WAIT_INDICATOR": preload("res://resources/interfaces/battle_screen/modules/battle_wait_bar/battle_wait_indicator.tscn"),
	"DAMAGE_INDICATOR": preload("res://resources/interfaces/battle_screen/modules/damage_indicator/damage_indicator.tscn"),
	"SKILL_INDICATOR": preload("res://resources/interfaces/battle_screen/modules/skill_indicator/skill_indicator.tscn"),
	"INPUT_CIRCLE": preload("res://resources/interfaces/input_prompt_icons/playstation_button_circle.png"),
	"INPUT_CROSS": preload("res://resources/interfaces/input_prompt_icons/playstation_button_cross.png"),
	"INPUT_SQUARE": preload("res://resources/interfaces/input_prompt_icons/playstation_button_square.png"),
	"INPUT_TRIANGLE": preload("res://resources/interfaces/input_prompt_icons/playstation_button_triangle.png"),
	"INPUT_TRIGGER_L1": preload("res://resources/interfaces/input_prompt_icons/playstation_trigger_l1.png"),
	"INPUT_TRIGGER_R1": preload("res://resources/interfaces/input_prompt_icons/playstation_trigger_r1.png"),
	"PLAYER_TURN_COWBOY": preload("res://resources/characters/player/cowboy/sprite_halfbody_cowboy.png"),
	"PLAYER_TURN_KNIGHT": preload("res://resources/characters/player/knight/sprite_halfbody_knight.png"),
	"KNIGHT": preload("res://resources/characters/player/knight/knight.tscn"),
	"COWBOY": preload("res://resources/characters/player/cowboy/cowboy.tscn"),
	"WOLF": preload("res://resources/characters/enemies/wolf/wolf.tscn"),
}


## Reads json from file and returns its parsed value
func parse_json_by_filepath(path: String) -> Variant:
	## Returns null if file doesn't exist
	if not FileAccess.file_exists(path):
		return null
		
	## Reads and parses JSON
	var file = FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	
	## Closes file before returning
	file.close()
	return parsed


## Finds a dictionary that contains the specified key in an array,
## and returns the value of that key or the dictionary itself based on the
## given return_dict_value argument.
func find_dictionary_in_array_with_key(
	arr: Array,
	key: Variant,
	return_dict_value: bool = true):
	for element in arr:
		if element.has(key):
			if return_dict_value:
				return element[key]
			else:
				return element
	
	return null


## Finds a dictionary in an array that contains a value for a given key,
## and returns the dictionary.
func find_dictionary_in_array_with_value(
	arr: Array,
	key: Variant,
	value: Variant
):
	for dict in arr:
		if dict.get(key) == value:
			return dict
	
	return null
