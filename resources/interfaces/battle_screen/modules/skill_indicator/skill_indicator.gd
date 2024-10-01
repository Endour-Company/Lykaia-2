extends Control
class_name SkillIndicator

## Class for skill indicator. Shown when a character's skill is activated.


## Holds scenes
@onready var indicator_background: PanelContainer = $IndicatorBackground
@onready var indicator_text: Label = $IndicatorBackground/IndicatorText


## Stores tween animation's durations.
var anim_dur: float = 0.5
var anim_dur_alt: float = 1.0


## Sets indicator text.
func set_indicator_text(text: String):
	indicator_text.set_text(text)


## Ready function. Plays fade in animation
func _ready():
	## Creates animation using tween.
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	
	## Plays fade in animation
	tween.tween_property(
		self, "anchor_left", 0, anim_dur
	)
	tween.tween_property(
		self, "anchor_right", 1, anim_dur
	)
	tween.tween_property(
		indicator_background, "modulate:a", 1, anim_dur
	).from(0)
	tween.tween_property(
		indicator_text, "modulate:a", 1, anim_dur
	).from(0)
	
	## Waits for 1 sec
	tween.set_parallel(false)
	tween.tween_interval(1)
	
	## Plays fadeout animation
	tween.tween_property(
		self, "anchor_left", 1, anim_dur
	)
	tween.set_parallel(true)
	tween.tween_property(
		self, "anchor_right", 2, anim_dur
	)
	tween.tween_property(
		indicator_background, "modulate:a", 0, anim_dur
	)
	tween.tween_property(
		indicator_text, "modulate:a", 0, anim_dur
	)
	
	## Frees when tween is done
	tween.set_parallel(false)
	tween.tween_callback(queue_free)
