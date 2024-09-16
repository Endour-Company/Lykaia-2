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
@export var health: int :
	get:
		return health
	set(value):
		health = _on_health_changed(value)
		health_changed.emit(health)

## The character's energy (0-5), needed to take action in battle.
@export_range(0,5) var energy: int :
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


func _ready():
	## Sets character's health to max_health
	health = max_health
	
	## Parse attack_set.json and gets this character's set
	attack_set = _get_attack_set()
	
	## Start battle timer (also set it to one-shot)
	battle_timer.set_one_shot(true)
	_start_battle_delay()


## Sets custom character's stats
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


## Pause battle timer
func pause_battle_timer():
	battle_timer.set_paused(true)


## Resume battle timer
func resume_battle_timer():
	battle_timer.set_paused(false)


## Handles player's health change (when they're attacked or healed)
func _on_health_changed(health: int) -> int:
	## Handles health overflow
	if health > max_health:
		return max_health
	elif health < 0:
		return 0
		
	## Sends death signal if remaining health has reached 0
	if health == 0:
		is_dead = true
		death.emit()
		
	return health


## Sets character's current energy
func _on_energy_changed(energy: int):
	## Handles energy overflow
	if energy > MAX_ENERGY:
		return MAX_ENERGY
	elif energy < 0:
		return 0
	
	return energy


## Gets character's attack sets
func _get_attack_set():
	## Reads and parse attack_set.json
	var data: Array = Utils.parse_json_by_filepath(Utils.Path["ATTACK_SET"])
	
	## Searches the data using the character's name
	return Utils.find_dictionary_in_array_with_key(data, char_name)


## Starts battle delay timer
func _start_battle_delay():
	battle_delay = _calculate_battle_delay()
	battle_timer.start(battle_delay)


## Calculates battle turn delay
func _calculate_battle_delay():
	var random = RandomNumberGenerator.new()
	return 30.0 / random.randf_range(speed-1, speed+1)


func _on_battle_turn_timer_timeout():
	## Restart timer
	_start_battle_delay()
	
	## Sends battle action signal
	battle_action.emit(self)


func _on_animation_tree_animation_finished(anim_name):
	pass
