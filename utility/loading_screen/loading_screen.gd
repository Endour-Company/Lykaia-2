extends CanvasLayer
class_name LoadingScreen

## Class for loading screen.
## Used to do background loading of scenes.


## Holds loading bar node
@onready var loading_bar: ProgressBar = $VBoxContainer/LoadingBar

## Stores path to scene that is going to be loaded
var scene_to_load = null

## Stores loading percentage.
## It's an array because the ResourceLoader's requirement
var loading_percentage: Array = []

## Signals to mark loading complete
signal loading_complete(loaded_scene: PackedScene)


## Loads scene
func load_scene(path: String):
	## Shows loading screen
	self.show()
	
	## Sets scene's path
	scene_to_load = path
	
	## Send request to begin loading resource
	ResourceLoader.load_threaded_request(scene_to_load)


## Checks if scene has loaded inside process loop
func _process(delta):
	if scene_to_load != null:
		## If loading has finished, emits signal and hide
		if _is_scene_loaded():
			loading_complete.emit(ResourceLoader.load_threaded_get(scene_to_load))
			self.hide()
		
		## Sets loading percentage
		loading_bar.set_value(loading_percentage[0] * 100)

## Checks if scene has loaded
func _is_scene_loaded():
	return ResourceLoader.load_threaded_get_status(scene_to_load, loading_percentage) == ResourceLoader.THREAD_LOAD_LOADED
