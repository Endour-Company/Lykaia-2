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
		## Ignores health change if character is dead.
		if is_dead:
			return
		
		## Sets health value and makes sure that it doesn't overflow/underflow.
		health = _on_health_changed(value)
		health_changed.emit(health)
		
		## Sends death signal if remaining health has reached 0
		if health == 0:
			is_dead = true
			death.emit(self)

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

## Stores attack & combo queue.
## They store the same thing, but attack queue's element will be freed whenever
## the attack has been done, but combo queue's element will only be freed
## when the character has finished all their attacks. And only attacks that
## connected will be added to combo queue.
var attack_queue: Array = []
var combo_queue: Array = []

## Stores whether character is moving/playing animation
var is_moving: bool = false

## Stores dead state
var is_dead: bool = false

## Stores guarding state
var guarding: bool = false

## Stores target, used to emit damage signal
var target: BaseCharacter

## Max energy of a character
const MAX_ENERGY: int = 5

## Holds character's turn delay in-battle
var battle_delay: float

## Holds character's AnimationTree to handle animation changes
@onready var anim_tree: AnimationTree = $AnimationTree

## Stores current animation
var cur_anim_name: String

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
signal damage(attacker, attack_id, target, is_skill) ## Sent in-battle to begin damage calculation
signal skill_activated(skill_name) ## Sent in-battle when skill is activated, before playing the corresponding anim
signal death(node) ## Sent if health reached 0
signal action_finished


## Attacks with given attack animation to given target enemy.
func attack(
	attack_id: String,
	target: BaseCharacter
):
	## Adds attack to queue
	attack_queue.append(attack_id)
	
	## Stores target
	self.target = target
	
	## If character is not currently moving and not in the correct 
	## attacking position, move to the correct position first
	## before playing animation. Else if character is not moving but is already
	## in the correct position, then plays the given attack animation
	## immediately.
	var target_pos: Vector2 = target.position + attack_pos_offest
	if not is_moving:
		if position != target_pos:
			move_to(target_pos)
		else:
			_play_next_attack_animation()


## Checks for any skills that can be activated with the current combo queue.
## Returns the skill id if any pattern is fulfilled, otherwise returns null.
func get_fulfilled_skill():
	print(combo_queue)
	for skill in skill_set:
		if combo_queue == skill["pattern"]:
			return skill["id"]
	return null


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


## Plays death animation.
func play_death_animation():
	anim_tree.set(
		"parameters/Dead/request",
		AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	)


## Removes battle timer.
func remove_battle_timer():
	battle_timer.queue_free()


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


## Attacks with given skill animation to given target enemy.
func skill_attack(
	skill_id: String,
	target: BaseCharacter
):
	print("ACTIVATES " + skill_id)
	## Adds attack to attack queue but in front
	attack_queue.push_front(skill_id)


## Calculates battle turn delay.
func _calculate_battle_delay():
	return 30.0 / randf_range(speed-1, speed+1)


## Gets character's attack sets.
func _get_attack_set():
	## Reads and parse attack_set.json
	var data: Array = Utils.parse_json_by_filepath(Utils.Path["ATTACK_SET"])
	
	## Searches the data using the character's name
	return Utils.find_dictionary_in_array_with_key(data, char_name)


## Gets character's skill sets.
func _get_skill_set():
	## Reads and parses skill_set.json
	var data: Array = Utils.parse_json_by_filepath(Utils.Path["SKILL_SET"])
	
	## Searches the data using the character's name
	var skill_set = Utils.find_dictionary_in_array_with_key(data, char_name)
	return skill_set if skill_set != null else []


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
	energy = 5
	
	## Gets character's attack & skill sets
	attack_set = _get_attack_set()
	skill_set = _get_skill_set()
	
	## Start battle timer (also set it to one-shot)
	battle_timer.set_one_shot(true)
	_start_battle_delay()


## Starts battle delay timer.
func _start_battle_delay():
	battle_delay = _calculate_battle_delay()
	battle_timer.start(battle_delay)


## Sends damage signal.
func _send_damage_signal(is_skill: bool = false):
	var attack_id: String = cur_anim_name ## May also be skill's id
	damage.emit(self, attack_id, target, is_skill)


## Sends skill activate signal.
func _send_skill_activated_signal():
	## Gets skill's name
	var skill_id: String = cur_anim_name
	var skill_data = Utils.find_dictionary_in_array_with_value(
		skill_set, "id", skill_id
	)
	var skill_name: String = skill_data["name"]
	
	## Emits corresponding signal
	skill_activated.emit(skill_name)


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
	
	## If anim_name is "dead", stop animation tree, else plays next animation.
	if anim_name == "dead":
		anim_tree.set_active(false)
	
	_play_next_attack_animation()


## Handles when anim_player started playing an animation.
## Stores the current anim_name as cur_anim_name.
func _on_animation_tree_animation_started(anim_name):
	cur_anim_name = anim_name
