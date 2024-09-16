extends Control
class_name BattleHealthBar

## Class for battle health bar.
## Holds logic for changing the UI aspects of health bar.


## Holds any character-related data that affects the healthbar
var is_enemy: bool


## Holds any important nodes that is shown on screen
@onready var char_name_node: Label = $PanelContainer/VBoxContainer/HBoxContainer/Name
@onready var cur_health_node: Label = $PanelContainer/VBoxContainer/HBoxContainer/Health/RemainingHealth
@onready var max_health_node: Label = $PanelContainer/VBoxContainer/HBoxContainer/Health/MaxHealth
@onready var health_bar_node: ProgressBar = $PanelContainer/VBoxContainer/HealthBar
@onready var energy_bar_node: ProgressBar = $PanelContainer/VBoxContainer/EnergyBar


## Sets initial values
func setup(char_name: String, cur_health: int, max_health: int, cur_energy: int, position: Vector2, is_enemy: bool):
	set_char_name(char_name)
	set_max_health(max_health)
	set_health(cur_health)
	set_energy(cur_energy)
	
	## Sets node's position
	set_position(position)
	
	## If enemy, then hide energy bar
	if is_enemy:
		energy_bar_node.hide()


## Sets character's name
func set_char_name(char_name: String):
	char_name_node.set_text(char_name)


## Sets new health value
func set_health(health: int):
	cur_health_node.set_text(str(health))
	health_bar_node.set_value_no_signal(health)


## Sets max health
func set_max_health(max_health: int):
	max_health_node.set_text(str(max_health))
	health_bar_node.set_max(max_health)


## Sets new energy value
func set_energy(energy: int):
	energy_bar_node.set_value_no_signal(energy)
