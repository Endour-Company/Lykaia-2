extends Control
class_name BattleWaitBar

## Class for battle wait bar

## Begin export group of indicator position
@export_group("Indicator Points")

## Holds the origin point of indicator.
@export var origin: Vector2

## Holds the destination points of indicator.
@export var dest: Vector2

## Holds the scene for battle wait indicator
var indicator: PackedScene = Utils.Resources["BATTLE_WAIT_INDICATOR"]


## Adds new indicator
func add_indicator(texture: Texture2D, time: float):
	## Creates new indicator's node
	var new_indicator: BattleWaitIndicator = indicator.instantiate()
	
	## Sets indicator's point, texture, and time
	new_indicator.set_points(origin, dest)
	new_indicator.set_indicator_texture(texture)
	new_indicator.set_time(time)
	
	## Append indicators to char_indicators and adds to scene
	add_child(new_indicator)


## Pauses all indicators
func pause_indicators():
	_set_paused(true)


## Resumes all indicators
func resume_indicators():
	_set_paused(false)


## Sets paused state of tween in battle wait indicator
func _set_paused(is_paused: bool):
	for child in get_children():
		if not child is BattleWaitIndicator:
			continue
		
		match is_paused:
			true:
				child.pause_tween()
			false:
				child.resume_tween()
