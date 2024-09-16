extends Control
class_name CommandButtons

## Class for command buttons in-battle

## Holds all button scenes
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

## Holds some anchor point values
@export_group("Anchor Points")
@export_range(0,1) var center_anchor: float = 0.5
@export_range(0,1) var top_anchor: float = 0.15
@export_range(0,1) var top_anchor_alt: float = 0.1
@export_range(0,1) var right_anchor: float = 0.85
@export_range(0,1) var right_anchor_alt: float = 0.8
@export_range(0,1) var bottom_anchor: float = 0.85
@export_range(0,1) var bottom_anchor_alt: float = 0.8
@export_range(0,1) var left_anchor: float = 0.15
@export_range(0,1) var left_anchor_alt: float = 0.1

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
	
	## Enables all buttons when tween is finished
	tween.set_parallel(false)
	tween.tween_callback(_set_action_btns_disabled.bind(false))


## Hide action buttons with tween animation
func hide_actions(move_center_texture: bool = true):
	## Disables all buttons
	_set_action_btns_disabled(true)
	
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
	
	## Moves center texture to bottom right
	if move_center_texture:
		hide_center_texture(tween)
	
	## Hides visibility of all buttons when tween is finished
	tween.set_parallel(false)
	tween.tween_callback(_set_action_btns_visibility.bind(false))


## Shows attack command buttons
func show_attack_commands(attack_set: Array):
	## Sets visibility of attack buttons
	_set_attack_btns_visibility(attack_set.size(), true)
	
	## Creates tween
	var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	
	for i in attack_set.size():
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
	
	## Enables all attack buttons when tween is finished
	tween.set_parallel(false)
	tween.tween_callback(_set_attack_btns_disabled.bind(attack_btns.size(), false))
	
	## End attack will be disabled first
	tween.tween_callback(end_attack_btn.set_disabled.bind(true))


## Hides attack command buttons
func hide_attack_commands(move_center_texture: bool = false):
	## Disables all attack buttons
	_set_attack_btns_disabled(attack_btns.size(), true)
	
	## Creates tween for animation
	var tween = create_tween().set_trans(Tween.TRANS_CIRC)
	
	## Animates button, only if it's visible
	for i in attack_btns.size():
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
	
	## Moves center texture to bottom right when needed
	if move_center_texture:
		hide_center_texture(tween)
	
	## Sets visibility of all attack command buttons when tween is finished
	tween.set_parallel(false)
	tween.tween_callback(_set_attack_btns_visibility.bind(attack_btns.size(), false))


## Disables attack choice buttons,
## called when character has run out of energy
func disable_attack_choices():
	for btn in attack_btns:
		btn.set_disabled(true)


## Ready function
func _ready():
	## Hides and disables all buttons
	_set_action_btns_visibility(false)
	_set_action_btns_disabled(true)
	_set_attack_btns_visibility(attack_btns.size(), false)
	_set_attack_btns_disabled(attack_btns.size(), true)


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
