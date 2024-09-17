extends CharacterBody2D
class_name BaseCharacter

## Base class for a character

## Begin export group identifier
@export_group("Identfier")

## Holds character's identifier.
## Used to get attack set, etc.
@export var char_name: String

## Holds character's battle indicator's texture,
## will be shown at the waiting bar on the battle screen.
@export var char_battle_indicator: Texture2D

## Begin export group for stats
@export_group("Stats")

## The character's max health point.
@export var max_health: int

## Remaining character's health, must not be more than max_health.
## Dead if this reaches 0.
var health: int :
	get:
		return health
	set(value):
		health = _on_health_changed(value)
		health_changed.emit(health)
		
		## Sends death signal if remaining health has reached 0
		if health == 0:
			is_dead = true
			death.emit()

## The character's energy (0-5), needed to take action in battle.
var energy: int = 0 :
	get:
		return energy
	set(value):
		energy = _on_energy_changed(value)
		energy_changed.emit(energy)

## The character's strength, affects how strong their attacks will be.
@export var strength: int

## The character's defense, affects how much they can lessen the damage
## of incoming attacks.
@export var defense: int

## The character's speed, affects the delay between their turns.
## Higher speed means shorter delay.
@export var speed: int

## The character's accuracy, affects the chance their attacks will hit.
## Lower accuracy means higher chance of missing attacks.
@export var accuracy: int

## The character's evasion, affects the chance they can dodge incoming attacks.
@export var evasion: int

## Begin export group for battle related variables
@export_group("Battle")

## Stores attacking position's offset relative to target enemy
@export var attack_pos_offest: Vector2 = Vector2.ZERO

## Stores attack queue
var attack_queue: Array = []

## Stores whether character is moving/playing animation
var is_moving: bool = false

## Stores dead state
var is_dead: bool = false

## Stores guarding state
var guarding: bool = false

## Max energy of a character
const MAX_ENERGY: int = 5

## Holds character's turn delay in-battle
var battle_delay: float

## Holds character's AnimationTree to handle animation changes
@onready var anim_tree: AnimationTree = $AnimationTree

## Holds character's battle turn timer
@onready var battle_timer: Timer = $BattleTurnTimer

## Holds character's available actions in-battle
var attack_set: Array
var skill_set: Array
var core_set: Array

## Signals
signal health_changed(health)
signal energy_changed(energy)
signal battle_action(node) ## Sent in-battle when it's this character's turn
signal death ## Sent if health reached 0
signal action_finished


## Attacks with given attack animation with target enemy at given position.
func attack(
	attack_name: String,
	enemy_pos: Vector2
):
	## Adds attack to queue
	attack_queue.append(attack_name)
	
	## If character is not currently moving and not in the correct 
	## attacking position, move to the correct position first
	## before playing animation. Else if character is not moving but is already
	## in the correct position, then plays the given attack animation
	## immediately.
	var target_pos: Vector2 = enemy_pos + attack_pos_offest
	if not is_moving:
		if position != target_pos:
			move_to(target_pos)
			return
		else:
			_play_next_attack_animation()


## Moves character to given position.
func move_to(target_pos: Vector2):
	## Cancels move if character is already in target_pos
	if position == target_pos:
		action_finished.emit()
		return
	
	## Plays jumping animation
	anim_tree.set(
		"parameters/Jumping/request",
		AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	)
	
	## Moves to given position using tween.
	## The tween duration is how long the jumping animation is.
	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, 1.3)
	
	is_moving = true


## Pauses battle timer.
func pause_battle_timer():
	battle_timer.set_paused(true)


## Resume battle timer.
func resume_battle_timer():
	battle_timer.set_paused(false)


## Sets custom character's stats.
func set_stats(
	max_health = null,
	health = null,
	energy = null,
	strength = null,
	defense = null,
	speed = null,
	accuracy = null,
	evasion = null
):
	self.max_health = max_health if max_health != null else self.max_health
	self.health = health if health != null else self.health
	self.energy = energy if energy != null else self.energy
	self.strength = strength if strength != null else self.strength
	self.defense = defense if defense != null else self.defense
	self.speed = speed if speed != null else self.speed
	self.accuracy = accuracy if accuracy != null else self.accuracy
	self.evasion = evasion if evasion != null else self.evasion


## Calculates battle turn delay.
func _calculate_battle_delay():
	return 30.0 / randf_range(speed-1, speed+1)


## Gets character's attack sets.
func _get_attack_set():
	## Reads and parse attack_set.json
	var data: Array = Utils.parse_json_by_filepath(Utils.Path["ATTACK_SET"])
	
	## Searches the data using the character's name
	return Utils.find_dictionary_in_array_with_key(data, char_name)


## Handles player's health change (when they're attacked or healed).
func _on_health_changed(health: int) -> int:
	## Handles health overflow
	if health > max_health:
		return max_health
	elif health < 0:
		return 0
		
	return health


## Sets character's current energy.
func _on_energy_changed(energy: int):
	## Handles energy overflow
	if energy > MAX_ENERGY:
		return MAX_ENERGY
	elif energy < 0:
		return 0
	
	return energy


## Plays given attack animation.
func _play_attack_animation(attack_name: String):
	anim_tree.set(
		"parameters/" + attack_name + "/request",
		AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	)
	is_moving = true


## Plays next attack animation in queue.
func _play_next_attack_animation():
	if attack_queue.is_empty():
		## Sends attack_finished signal to let CharactersController knows
		## when an animation has finished and there are no animation to play
		## anymore. This signal is used when the player clicked on End Attack
		## when character is moving.
		action_finished.emit()
		return
	
	var attack_name: String = attack_queue.pop_front()
	_play_attack_animation(attack_name)


## Ready function.
func _ready():
	## Sets health to max_health
	health = max_health
	
	## Parse attack_set.json and gets this character's set
	attack_set = _get_attack_set()
	
	## Start battle timer (also set it to one-shot)
	battle_timer.set_one_shot(true)
	_start_battle_delay()


## Starts battle delay timer.
func _start_battle_delay():
	battle_delay = _calculate_battle_delay()
	battle_timer.start(battle_delay)


## Handles timeout of battle turn timer.
func _on_battle_turn_timer_timeout():
	## Restart timer
	_start_battle_delay()
	
	## Sends battle action signal
	battle_action.emit(self)


## Handles when anim_player finishes playing an animation.
func _on_animation_tree_animation_finished(anim_name):
	## Sets is_moving to false and plays the next attack animation,
	## if there is any.
	is_moving = false
	_play_next_attack_animation()
