extends BaseCharacter
class_name BaseEnemy


## Base class for enemy


## Begin export group of weights.
## Weights are used for any probability methods.
@export_group("Weights")

## The initial weight of a character.
@export var initial_weight: int = 10

## The value to increase weight by, when they have the lowest health.
@export var delta_weight_on_health: int = 40

## The value to increase weight by, when they have the highest strength.
@export var delta_weight_on_str: int = 30

## The value to increase weight by, when they have the lowest defense.
@export var delta_weight_on_def: int = 30

## Holds action signals
signal action_attack(index_attack, index_target)
signal action_guard


## Thinks which action to take.
## Possible actions are attack, skill, and guard.
## Accepts an array of players to target.
## Emits the signal that corresponds to the chosen action,
## and returns the name of the chosen action.
## Can be overridden by derived class to create a different strategy.
func take_action(player_nodes: Array) -> String :
	## Default strategy is to always attack with their default attack.
	var action: String = "attack"
	
	match action:
		"attack":
			action_attack.emit(0, _choose_target(player_nodes))
	
	return action


## Adjusts weights based on some conditions.
func _adjust_weights(player_nodes: Array, weights: Array):
	_calculate_weights_on_health(player_nodes, weights)
	_calculate_weights_on_strength(player_nodes, weights)
	_calculate_weights_on_defense(player_nodes, weights)


## Calculate the total weight of all characters' weights.
func _calculate_total_weight(weights: Array) -> int :
	var total_weight: int = 0
	for weight in weights:
		total_weight += weight
	return total_weight


## Calculate the weight of each characters in an array based on their defense.
## The lower their defense is, the higher their weight.
## Accepts an array of players and an array of their weights.
## This method will modify the array of weights.
func _calculate_weights_on_defense(
	player_nodes: Array,
	weights: Array
):
	## Cancels if weights is empty
	if weights.is_empty():
		return
	
	## Stores the index of the lowest defense character
	var index: int
	
	## Stores the lowest defense
	var lowest_def: int = 999999
	
	## Gets lowest defense
	for i in player_nodes.size():
		var player: BaseCharacter = player_nodes[i]
		if player.defense < lowest_def:
			lowest_def = player.defense
			index = i
	
	## Increase the weight of the lowest defense character
	weights[index] += delta_weight_on_def


## Calculate the weight of each characters in an array based on their health.
## The lower their health is, the higher their weight will be.
## Accepts an array of players and an array of their weights.
## This method will modify the array of weights.
func _calculate_weights_on_health(
	player_nodes: Array,
	weights: Array
):
	## Cancels if weights is empty
	if weights.is_empty():
		return
	
	## Stores the index of the character with the lowest health
	var index: int
	
	## Stores the lowest health
	var lowest_health: int = 999999
	
	## Gets the lowest health
	for i in player_nodes.size():
		var player: BaseCharacter = player_nodes[i]
		if player.health < lowest_health:
			lowest_health = player.health
			index = i
	
	## Increase the weight of the character with the lowest health.
	weights[index] += delta_weight_on_health


## Calculate the weight of each characters in an array based on their strength.
## The higher their strength, the higher their weight.
## Accepts an array of players and an array of their weights.
## This method will modify the array of weights.
func _calculate_weights_on_strength(
	player_nodes: Array,
	weights: Array
):
	## Cancels if weights is empty
	if weights.is_empty():
		return
	
	## Stores the index of the character with the highest strength
	var index: int
	
	## Stores the highest strength
	var highest_str: int = -1
	
	## Gets the highest str
	for i in player_nodes.size():
		var player: BaseCharacter = player_nodes[i]
		if player.strength > highest_str:
			highest_str = player.strength
			index = i
	
	## Increase the weight of the character with the highest strength
	weights[index] += delta_weight_on_str


## Thinks which player to target.
## Accepts an array of players, and returns the index of the chosen target.
## Returns -1 if fail to choose, e.g. when all players are dead.
## Can be overridden by derived class to create a different strategy.
func _choose_target(player_nodes: Array) -> BaseCharacter :
	## Filters dead players
	player_nodes = player_nodes.filter(func(player): return !player.is_dead)
	
	## Player arrays can not be empty
	assert(!player_nodes.is_empty())
	
	## Declares initial weights of characters
	var weights: Array = _setup_initial_weights(player_nodes.size())
	
	## Adjusts weights
	_adjust_weights(player_nodes, weights)
	
	## Gets total weight of all characters
	var total_weight: int = _calculate_total_weight(weights)
	
	return player_nodes[_choose_weighted_target(weights, total_weight)]


## Chooses a target using a weighted probability.
## Accepts an array of weights, returns the index of the chosen target.
## Returns -1 in case no target is chosen, but it should never happen.
func _choose_weighted_target(weights: Array, total_weight: int) -> int :
	## Generates a random number between 0 and total_weight
	var chosen_weight: int = randi() % total_weight
	
	## Loops through the weights array and adds up the weights cumulatively
	## and selects based on chosen_weight.
	var cumulative_weight: int = 0
	for i in weights.size():
		cumulative_weight += weights[i]
		if chosen_weight < cumulative_weight:
			return i
	
	return -1


## Sets up initial weights
func _setup_initial_weights(size: int) -> Array :
	var weights: Array = []
	weights.resize(size)
	weights.fill(initial_weight)
	
	return weights
