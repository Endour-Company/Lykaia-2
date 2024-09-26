extends Control
class_name CommandButtons

## Class for command buttons in-battle

## Holds input state for controlling whether or not to accept inputs,
## other than button clicks.
enum INPUT_STATES {
	FORBIDDEN,
	ACTION,
	ATTACK,
	ATTACK_NO_ENERGY,
}
var input_state: int = INPUT_STATES.FORBIDDEN

## Holds all button nodes
@onready var attack_btn: Button = $AttackButton
@onready var core_btn: Button = $CoreButton
@onready var item_btn: Button = $ItemButton
@onready var guard_btn: Button = $GuardButton
@onready var run_btn: Button = $RunButton
@onready var target_btn: Button = $TargetButton
@onready var attack_btns: Array = [$Attack1Button, $Attack2Button, $Attack3Button]
@onready var end_attack_btn: Button = $EndAttackButton
@onready var cancel_attack_btn: Button = $CancelAttackButton
@onready var center_texture = $CenterContainer

## Stores how many attack to show in attack command buttons.
var attack_count: int

## Holds input prompt nodes
@onready var prompt1: TextureRect = $Action1PromptIcon
@onready var prompt2: TextureRect = $Action2PromptIcon
@onready var prompt3: TextureRect = $Action3PromptIcon
@onready var prompt4: TextureRect = $Action4PromptIcon

## Holds some anchor point values for buttons, etc
@export_group("General Anchor Points")
@export_range(0,1) var center_anchor: float = 0.5
@export_range(0,1) var top_anchor: float = 0.15
@export_range(0,1) var top_anchor_alt: float = 0.1
@export_range(0,1) var right_anchor: float = 0.85
@export_range(0,1) var right_anchor_alt: float = 0.8
@export_range(0,1) var bottom_anchor: float = 0.85
@export_range(0,1) var bottom_anchor_alt: float = 0.8
@export_range(0,1) var left_anchor: float = 0.15
@export_range(0,1) var left_anchor_alt: float = 0.1

## Holds some anchor point values for input prompt icons
@export_group("Anchor Points for Input Prompts")
@export_range(0,1) var prompt_top_anchor: float = 0.35
@export_range(0,1) var prompt_right_anchor: float = 0.65
@export_range(0,1) var prompt_bottom_anchor: float = 0.65
@export_range(0,1) var prompt_left_anchor: float = 0.35


## Holds how long a tween animation will be
var anim_dur: float = 0.5

## Button signals
signal attack_pressed
signal core_pressed
signal item_pressed
signal guard_pressed
signal run_pressed
signal target_pressed
signal attack(index)
signal end_attack
signal cancel_attack

#region Holds show/hide methods for the center texture.
## Shows center texture (move it to the center)
func show_center_texture(current_tween = null):
	## Show center texture is used with other show methods most of the time,
	## so ONLY create a new tween if this is the only show method called.
	var tween: Tween
	if current_tween != null:
		tween = current_tween
	else:
		tween = create_tween().set_trans(Tween.TRANS_CIRC)
	tween.tween_property(
		center_texture, "anchor_right", center_anchor, 0.2
	).from(right_anchor_alt)
	tween.parallel().tween_property(
		center_texture, "anchor_bottom", center_anchor, 0.2
	).from(bottom_anchor_alt)


## Hides center texture (move it back to bottom right)
func hide_center_texture(current_tween = null):
	## Hide_center_texture is used with other hide methods most of the time,
	## so ONLY create a new tween if this is the only hide method called.
	var tween: Tween
	if current_tween != null:
		tween = current_tween
	else:
		tween = create_tween().set_trans(Tween.TRANS_CIRC)
	tween.set_parallel(false)
	tween.tween_property(
		center_texture, "anchor_left", right_anchor_alt, 0.2
	).from(center_anchor)
	tween.parallel().tween_property(
		center_texture, "anchor_top", bottom_anchor_alt, 0.2
	).from(center_anchor)
#endregion


#region Holds show/hide methods for the input prompt icons.
## Shows input prompt icons to their respective positions.
## show_trigger controls whether to show the R1/L1 buttons, and
## main_action_count controls how many button prompts to show (1-4).
func show_input_prompts(
	current_tween = null,
	main_action_count: int = 4,
	show_trigger: bool = true
):
	## This method is used with other methods that use tween most of the time,
	## so only create a new tween if current_tween is null.
	var tween: Tween
	if current_tween != null:
		tween = current_tween
	else:
		tween = create_tween().set_trans(Tween.TRANS_CIRC)
	
	## Sets tween as parallel
	tween.set_parallel(true)
	
	## Animates input prompt icons
	if main_action_count >= 1:
		tween.tween_property(
			prompt1, "anchor_bottom", prompt_top_anchor, anim_dur
		).from(center_anchor)
		tween.tween_property(prompt1, "modulate:a", 1, anim_dur).from(0)
	
	if main_action_count >= 2:
		tween.tween_property(
			prompt2, "anchor_left", prompt_right_anchor, anim_dur
		).from(center_anchor)
		tween.tween_property(prompt2, "modulate:a", 1, anim_dur).from(0)
	
	if main_action_count >= 3:
		tween.tween_property(
			prompt3, "anchor_top", prompt_bottom_anchor, anim_dur
		).from(center_anchor)
		tween.tween_property(prompt3, "modulate:a", 1, anim_dur).from(0)
	
	## Prompt 4 will always be shown
	tween.tween_property(
		prompt4, "anchor_right", prompt_left_anchor, anim_dur
	).from(center_anchor)
	tween.tween_property(prompt4, "modulate:a", 1, anim_dur).from(0)


## Hides input prompt icons.
## hide_trigger controls whether to hide the R1/L1 buttons,
## and main_action_count controls how many button prompts to hide (1-4).
func hide_input_prompts(
	current_tween = null,
	main_action_count: int = 4,
	hide_trigger: bool = false
):
	## This method is used together with other methods that use tween most of
	## the time, so only create a new tween if current_tween is null.
	var tween: Tween
	if current_tween != null:
		tween = current_tween
	else:
		tween = create_tween().set_trans(Tween.TRANS_CIRC)
	
	## Sets tween parallel
	tween.set_parallel(true)
	
	## Animates input prompt icons
	if main_action_count >= 1:
		tween.tween_property(
			prompt1, "anchor_top", center_anchor, anim_dur
		)
		tween.tween_property(prompt1, "modulate:a", 0, anim_dur)
	
	if main_action_count >= 2:
		tween.tween_property(
			prompt2, "anchor_right", center_anchor, anim_dur
		)
		tween.tween_property(prompt2, "modulate:a", 0, anim_dur)
	
	if main_action_count >= 3:
		tween.tween_property(
			prompt3, "anchor_bottom", center_anchor, anim_dur
		)
		tween.tween_property(prompt3, "modulate:a", 0, anim_dur)
	
	## Prompt 4 would always be hidden.
	tween.tween_property(
		prompt4, "anchor_left", center_anchor, anim_dur
	)
	tween.tween_property(prompt4, "modulate:a", 0, anim_dur)
#endregion


#region Holds show/hide methods for the action buttons.
## Show action buttons with tween animation
func show_actions(move_center_texture: bool = true):
	## Sets visibility
	_set_action_btns_visibility(true)
	
	## Creates animations
	var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	
	## Moves center texture
	if move_center_texture:
		show_center_texture(tween)
	
	## Animates buttons
	tween.tween_property(
		attack_btn, "anchor_bottom", top_anchor, anim_dur
	).from(center_anchor)
	tween.set_parallel(true)
	tween.tween_property(attack_btn, "modulate:a", 1, anim_dur).from(0)
	
	tween.tween_property(
		core_btn, "anchor_left", right_anchor, anim_dur
	).from(center_anchor)
	tween.tween_property(core_btn, "modulate:a", 1, anim_dur).from(0)
	
	tween.tween_property(
		item_btn, "anchor_top", bottom_anchor, anim_dur
	).from(center_anchor)
	tween.tween_property(item_btn, "modulate:a", 1, anim_dur).from(0)
	
	tween.tween_property(
		guard_btn, "anchor_right", left_anchor, anim_dur
	).from(center_anchor)
	tween.tween_property(guard_btn, "modulate:a", 1, anim_dur).from(0)
	
	tween.tween_property(
		run_btn, "anchor_left", right_anchor, anim_dur
	).from(center_anchor)
	tween.tween_property(
		run_btn, "anchor_bottom", top_anchor_alt, anim_dur
	).from(0.5)
	tween.tween_property(run_btn, "modulate:a", 1, anim_dur).from(0)
	
	tween.tween_property(
		target_btn, "anchor_right", left_anchor, anim_dur
	).from(center_anchor)
	tween.tween_property(
		target_btn, "anchor_bottom", top_anchor_alt, anim_dur
	).from(center_anchor)
	tween.tween_property(target_btn, "modulate:a", 1, anim_dur).from(0)
	
	## Shows input prompts
	show_input_prompts(tween)
	
	## Enables all buttons when tween is finished and change input state
	tween.set_parallel(false)
	tween.tween_callback(_set_action_btns_disabled.bind(false))
	tween.tween_callback(set_input_state.bind(INPUT_STATES.ACTION))


## Hide action buttons with tween animation
func hide_actions(move_center_texture: bool = true):
	## Disables all buttons
	_set_action_btns_disabled(true)
	
	## Change input state
	set_input_state(INPUT_STATES.FORBIDDEN)
	
	## Creates animations
	var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	
	tween.tween_property(attack_btn, "anchor_top", 0.5, anim_dur).from(0.15)
	tween.set_parallel(true)
	tween.tween_property(attack_btn, "modulate:a", 0, anim_dur).from(1)
	tween.tween_property(core_btn, "anchor_right", 0.5, anim_dur).from(0.85)
	tween.tween_property(core_btn, "modulate:a", 0, anim_dur).from(1)
	tween.tween_property(item_btn, "anchor_bottom", 0.5, anim_dur).from(0.85)
	tween.tween_property(item_btn, "modulate:a", 0, anim_dur).from(1)
	tween.tween_property(guard_btn, "anchor_left", 0.5, anim_dur).from(0.15)
	tween.tween_property(guard_btn, "modulate:a", 0, anim_dur).from(1)
	tween.tween_property(run_btn, "anchor_right", 0.5, anim_dur).from(0.85)
	tween.tween_property(run_btn, "anchor_top", 0.5, anim_dur).from(0.1)
	tween.tween_property(run_btn, "modulate:a", 0, anim_dur).from(1)
	tween.tween_property(target_btn, "anchor_left", 0.5, anim_dur).from(0.15)
	tween.tween_property(target_btn, "anchor_top", 0.5, anim_dur).from(0.1)
	tween.tween_property(target_btn, "modulate:a", 0, anim_dur).from(1)
	
	## Hides input prompts
	hide_input_prompts(tween)
	
	## Moves center texture to bottom right
	if move_center_texture:
		hide_center_texture(tween)
	
	## Hides visibility of all buttons when tween is finished
	tween.set_parallel(false)
	tween.tween_callback(_set_action_btns_visibility.bind(false))
#endregion


#region Holds show/hide methods for the attack command buttons.
## Shows attack command buttons
func show_attack_commands(attack_set: Array):
	## Sets visibility of attack buttons
	_set_attack_btns_visibility(attack_set.size(), true)
	
	## Creates tween
	var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	
	## Sets attack cound
	attack_count = attack_set.size()
	for i in attack_count:
		## Sets button's text to attack's name and shows the button
		attack_btns[i].set_text(attack_set[i]["name"])
		
		## Animates the button based on where its position should be
		match i:
			0: # Top
				tween.tween_property(
					attack_btns[i], "anchor_bottom", top_anchor, anim_dur
				).from(center_anchor)
			1: # Right
				tween.tween_property(
					attack_btns[i], "anchor_left", right_anchor, anim_dur
				).from(center_anchor)
			2: # Bottom
				tween.tween_property(
					attack_btns[i], "anchor_top", bottom_anchor, anim_dur
				).from(center_anchor)
		
		## Animates button's transparency
		tween.set_parallel(true)
		tween.tween_property(attack_btns[i], "modulate:a", 1, anim_dur).from(0)
	
	## Animates other attack-related buttons
	tween.tween_property(
		end_attack_btn, "anchor_right", left_anchor, anim_dur
	).from(center_anchor)
	tween.tween_property(end_attack_btn, "modulate:a", 1, anim_dur).from(0)
	
	tween.tween_property(
		cancel_attack_btn, "anchor_right", left_anchor, anim_dur
	).from(center_anchor)
	tween.tween_property(
		cancel_attack_btn, "anchor_bottom", top_anchor_alt, anim_dur
	).from(center_anchor)
	tween.tween_property(cancel_attack_btn, "modulate:a", 1, anim_dur).from(0)
	
	## Shows input prompt icons
	show_input_prompts(tween, attack_count)
	
	## Enables all attack buttons when tween is finished and change input state
	tween.set_parallel(false)
	tween.tween_callback(_set_attack_btns_disabled.bind(attack_count, false))
	tween.tween_callback(set_input_state.bind(INPUT_STATES.ATTACK))
	
	## End attack will be disabled first
	tween.tween_callback(end_attack_btn.set_disabled.bind(true))


## Hides attack command buttons
func hide_attack_commands(move_center_texture: bool = false):
	## Disables all attack buttons
	_set_attack_btns_disabled(attack_count, true)
	
	## Change input state
	set_input_state(INPUT_STATES.FORBIDDEN)
	
	## Creates tween for animation
	var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	
	## Animates button, only if it's visible
	for i in attack_count:
		if not attack_btns[i].is_visible():
			continue
		
		## Animates button's movement based on its position
		match i:
			0: # Top
				tween.tween_property(
					attack_btns[i], "anchor_top", center_anchor, anim_dur
				).from(top_anchor)
			1: # Right
				tween.tween_property(
					attack_btns[i], "anchor_right", center_anchor, anim_dur
				).from(right_anchor)
			2: # Bottom
				tween.tween_property(
					attack_btns[i], "anchor_bottom", center_anchor, anim_dur
				).from(bottom_anchor)
		
		## Animates button's transparency
		tween.set_parallel(true)
		tween.tween_property(attack_btns[i], "modulate:a", 0, anim_dur).from(1)
	
	## Animates other attack-related buttons
	tween.tween_property(
		end_attack_btn, "anchor_left", center_anchor, anim_dur
	).from(left_anchor)
	tween.tween_property(end_attack_btn, "modulate:a", 0, anim_dur).from(1)
	
	tween.tween_property(
		cancel_attack_btn, "anchor_left", center_anchor, anim_dur
	).from(left_anchor)
	tween.tween_property(
		cancel_attack_btn, "anchor_top", center_anchor, anim_dur
	).from(top_anchor_alt)
	tween.tween_property(cancel_attack_btn, "modulate:a", 0, anim_dur).from(1)
	
	## Hides input prompt icons
	hide_input_prompts(tween, attack_count)
	
	## Moves center texture to bottom right when needed
	if move_center_texture:
		hide_center_texture(tween)
	
	## Sets visibility of all attack command buttons when tween is finished
	tween.set_parallel(false)
	tween.tween_callback(_set_attack_btns_visibility.bind(attack_btns.size(), false))
#endregion


## Disables attack choice buttons,
## called when character has run out of energy
func disable_attack_choices():
	for btn in attack_btns:
		btn.set_disabled(true)


## Sets input state.
func set_input_state(state: int):
	input_state = state


## Ready function
func _ready():
	## Hides and disables all buttons
	_set_action_btns_visibility(false)
	_set_action_btns_disabled(true)
	_set_attack_btns_visibility(attack_btns.size(), false)
	_set_attack_btns_disabled(attack_btns.size(), true)


## Process function, to handle incoming inputs.
func _process(delta):
	## Don't accept input if input state is forbidden.
	if INPUT_STATES.FORBIDDEN:
		return
	
	## Handles incoming inputs based on the input state.
	if Input.is_action_just_pressed("action1"):
		_play_button_click_animation(prompt1)
		
		## Action1 corresponds to Attack (MAIN) and Attack1 (ATTACK)
		match input_state:
			INPUT_STATES.ACTION:
				_on_attack_button_pressed()
			INPUT_STATES.ATTACK:
				_on_attack_command_pressed(0)
	elif Input.is_action_just_pressed("action2"):
		_play_button_click_animation(prompt2)
		
		## Action2 corresponds to Core (MAIN) and Attack2 (ATTACK)
		match input_state:
			INPUT_STATES.ACTION:
				pass
			INPUT_STATES.ATTACK:
				_on_attack_command_pressed(1)
	elif Input.is_action_just_pressed("action3"):
		_play_button_click_animation(prompt3)
		
		## Action3 corresponds to Item (MAIN) and Attack3 (ATTACK)
		match input_state:
			INPUT_STATES.ACTION:
				pass
			INPUT_STATES.ATTACK:
				_on_attack_command_pressed(2)
	elif Input.is_action_just_pressed("action4"):
		_play_button_click_animation(prompt4)
		
		## Action4 corresponds to Guard (MAIN) and End Attack (ATTACK)
		match input_state:
			INPUT_STATES.ACTION:
				_on_guard_button_pressed()
			INPUT_STATES.ATTACK:
				_on_end_attack_button_pressed()
			INPUT_STATES.ATTACK_NO_ENERGY:
				_on_end_attack_button_pressed()


## Plays button click animation.
func _play_button_click_animation(button: Node):
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CIRC)
	tween.tween_property(button, "scale", Vector2(0.9,0.9), 0.2)
	tween.tween_property(button, "scale", Vector2(1,1), 0.2)


## Sets the visibility of all action buttons
func _set_action_btns_visibility(is_visible: bool):
	attack_btn.set_visible(is_visible)
	core_btn.set_visible(is_visible)
	item_btn.set_visible(is_visible)
	guard_btn.set_visible(is_visible)
	run_btn.set_visible(is_visible)
	target_btn.set_visible(is_visible)


## Sets whether all action buttons are disabled
func _set_action_btns_disabled(is_disabled: bool):
	attack_btn.set_disabled(is_disabled)
	core_btn.set_disabled(is_disabled)
	item_btn.set_disabled(is_disabled)
	guard_btn.set_disabled(is_disabled)
	run_btn.set_disabled(is_disabled)
	target_btn.set_disabled(is_disabled)


## Sets the visibility of all attack buttons,
## attack_count holds how many types of attacks a character have.
func _set_attack_btns_visibility(attack_count: int, is_visible: bool):
	for i in attack_count:
		attack_btns[i].set_visible(is_visible)
	end_attack_btn.set_visible(is_visible)
	cancel_attack_btn.set_visible(is_visible)


## Sets whether attack buttons are disabled,
## attack_count holds how many types of attacks a character have.
func _set_attack_btns_disabled(attack_count: int, is_disabled: bool):
	for i in attack_count:
		attack_btns[i].set_disabled(is_disabled)
	end_attack_btn.set_disabled(is_disabled)
	cancel_attack_btn.set_disabled(is_disabled)


func _on_target_button_pressed():
	target_pressed.emit()


func _on_attack_button_pressed():
	attack_pressed.emit()


func _on_attack_command_pressed(index: int):
	## Disables cancel attack button and enables end attack button
	cancel_attack_btn.set_disabled(true)
	end_attack_btn.set_disabled(false)
	
	## Sends signal
	attack.emit(index)


func _on_end_attack_button_pressed():
	end_attack.emit()


func _on_cancel_attack_button_pressed():
	cancel_attack.emit()


func _on_guard_button_pressed():
	guard_pressed.emit()
