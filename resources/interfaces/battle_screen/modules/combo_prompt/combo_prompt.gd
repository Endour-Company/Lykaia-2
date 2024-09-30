extends Control
class_name ComboPrompt

## Class for combo prompt for handling showing which button player
## uses to attack.


## Holds the container that will contain the button icons.
@onready var container: HBoxContainer = $PanelContainer/HBoxContainer

## Holds tween for animation and animation duration.
var tween: Tween
var anim_dur: float = 0.5


## Adds button icon to prompt.
## Accepts an index, 0 = triangle, 1 = circle, 2 = cross.
func add_button(index: int):
	## If container is empty, it means that combo prompt is currently hidden.
	## If this method is called while prompt is hidden, then
	## animates showing the combo prompt.
	if container.get_child_count() == 0:
		tween = create_tween()
		tween.tween_property(self, "modulate:a", 1, anim_dur)
	
	## Gets the matching icon by icon_name
	var icon_name: String
	match index:
		0:
			icon_name = "INPUT_TRIANGLE"
		1:
			icon_name = "INPUT_CIRCLE"
		2:
			icon_name = "INPUT_CROSS"
		_:
			## Cancels method if index was wrong.
			assert(false, "Wrong button index.")
	var icon: Texture2D = Utils.Resources[icon_name]
	
	## Creates a button node and adds it to container.
	container.add_child(_create_button(icon))


## Clears container
func clear():
	## Animates hiding combo prompt
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, anim_dur)
	
	## Frees button icons after tween is finished.
	await tween.finished
	for child in container.get_children():
		child.queue_free()


## Creates a button node.
func _create_button(icon: Texture2D) -> TextureRect:
	## Create a texture rect node
	var button_icon = TextureRect.new()
	
	## Sets texture and returns
	button_icon.set_texture(icon)
	return button_icon


## Clears container first at ready.
func _ready():
	## Hides combo prompt
	modulate.a = 0
	
	## Clears container
	clear()
