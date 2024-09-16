extends Node

## Class for utility functions


## Stores PATH to files that are needed by some scenes
var Path = {
	"ATTACK_SET": "res://resources/characters/modules/attack_set.json",
	"BATTLE_SCENE": "res://battle_system/battle.tscn",
}


## Stores RESOURCES that needs to be loaded by some scenes
var Resources = {
	"BATTLE_HEALTH_BAR": preload("res://resources/interfaces/battle_screen/modules/battle_health_bar/battle_health_bar.tscn"),
	"BATTLE_POINTER": preload("res://resources/interfaces/battle_screen/modules/battle_pointer/battle_pointer.tscn"),
	"BATTLE_WAIT_INDICATOR": preload("res://resources/interfaces/battle_screen/modules/battle_wait_bar/battle_wait_indicator.tscn"),
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
## and returns the value.
func find_dictionary_in_array_with_key(arr: Array, key: Variant):
	for element in arr:
		if element.has(key):
			return element[key]
	
	return null
