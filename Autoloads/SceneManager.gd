extends Node

## The SceneManager class is designed to enable simple one-line calls to load one scene (Node)
## and unload another. It also handles monitoring load progress, which can displayed as a loading
## bar to the user and it gives you optional transitions for swapping between them. Data can also 
## be handed off between scenes by implementing methods within the scenes being loaded/unloaded (see 
## [method _on_content_finished_loading] for more detail. The inteded use is to switch between major
## screens (like Start and Gameplay and GameOver) or between levels. SceneManager CAN be used to load
## other assets, but it's not intended to manage loading frequently used items like spawning enemies
## or bullets. This is for high-level game management. [br][br]
## This version, revised from v1.0 seen described here https://www.youtube.com/watch?v=2uYaoQj_6o0
## aims to add an often requested feature, which is to define where content is loaded (instead of simply
## replacing the SceneTree as v1.0 did. v1.0 was designed that way to make it simple to explain and use, 
## but folks ask for more control so v1.1 was born! Additionally, this updated heavily decouples
## game logic from the SceneManager to make it easier to utilize in your own game. There are no more
## class type checks within the SceneManager. Instead, I've opted to use has_method checks that
## loaded classes may optionall implement to react to the loading process without having to change
## SceneManager to suit your game's internal code. There are also now signals you can listen for to
## easily make changes to your SceneTree at different moments during the loading progress, again allowing
## classes using SceneManager to react to the process instead of having to insert that logic into the SceneManager
## iteslf. There are certainly tradeoffs to this method, but hey that's programming. You may 
## edit this to suit your needs. I tried to strike a balance between keeping the code fairly flexible
## without abstracting it so far that it would be hard to follow or asking users to pass in too many
## arugments when loading a scene. [br][br]
## [b]One Final Note[/b] Despite this leveraging the [ResourceLoader] class to monitor loading,
## SceneManager does not at this time support treaded loading. The current system will simply reject 
## loading an asset if one is already in progress. Managing multiple concurrent items was out of the
## scope of v.1.1 but may be implemented in future versions. Be mindful of how frequently a user might 
## be able to take action that triggers SceneManager to load something as it will fail silently right now
## (the previous version had this limitation). Aside from accounting for this in your logic, a workaround
## could be to check [code]_loading_in_progress == true[/code] and if so [code]await SceneManager.load_complete[/code]
## in cases where you might be at risk of using SceneManager to load scenes in rapid succession. This
## approach will have limitations as well. The way I intended SceneManager for my own use, this will rarely
## if ever, be an issue, which is why that was an acceptable limitation. Just something to be aware of. 

const LEVEL_H:int = 960	## height of levels (viewport) - only used by Zelda transition
const LEVEL_W:int = 540	## width of levels (viewport) - only used by Zelda transition

signal load_start(loading_screen)	## Triggered when an asset begins loading
signal scene_added(loaded_scene:Node,loading_screen)	## Triggered right after asset is added to SceneTree but before transition animation finishes
signal load_complete(loaded_scene:Node)	## Triggered when loading has completed

signal _content_finished_loading(content)	## internal - triggered when content is loaded and final data handoff and transition out begins
signal _content_invalid(content_path:String)	## internal - triggered when attempting to load invalid content (e.g. an asset does not exist or path is incorrect)
signal _content_failed_to_load(content_path:String)	## internal - triggered when loading has started but failed to complete

var _loading_screen_scene:PackedScene = preload("res://Menus/loading_canvass.tscn")	## reference to loading screen PackedScene, if you don't want the loading screen to ALWAYS be on top and instead want more granular control, instead preload loading_screen and then use the signals above to reposition nodes as needed
var _loading_screen:LoadingScreen	## internal - reference to loading screen instance
var _transition:String	## internal - transition being used for current load
var _zelda_transition_direction:Vector2	## internal - direction of zelda transition (should only be passed Vector2.UP/RIGHT/DOWN/LEFT) Is passed in when calling [code]swap_scenes_zelda()[/code]
var _content_path:String	## internal - stores the path to the asset SceneManager is trying to load
var _load_progress_timer:Timer	## internal - Timer used to check in on load progress
var _load_scene_into:Node	## internal - Node into which we're loading the new scene, defaults to [code]get_tree().root[/code] if left [code]null[/null] 
var _scene_to_unload:Node	## internal - Node we're unloading. In almost all cases, SceneManager will be used to swap between two scenes - after all that it the primary focus. However, passing in [code]null[/code] for the scene to unload will skip the unloading process and simply add the new scene. This isn't recommended, as it can have some adverse affects depending on how it is used, but it does work. Use with caution :)
var _loading_in_progress:bool = false	## internal - used to block SceneManager from attempting to load two things at the same time

## Currently only being used to connect to required, internal signals
func _ready() -> void:
	_content_invalid.connect(_on_content_invalid)
	_content_failed_to_load.connect(_on_content_failed_to_load)
	_content_finished_loading.connect(_on_content_finished_loading)

## internal - adds the loading screen. The loading screen is added to the [code]root[/code]. 
## To make changes to where the loading screen ends up, you can listen for the signals [code]scene_added[/code] 
## and [code]load_complete[/code] to reposition loading screen or other elements, relative to the 
## loading screen appropriately. [br][br]
## For example, the following code from Gameplay (a sample "game manager" of sorts) listens for these
## signals and and then makes adjustments to the SceneTree to keep the HUD always above the loading screen
## [codeblock]
##	func _on_load_start(_loading_screen):
##	pass
##	# keep HUD on top of loading screen
##	_loading_screen.reparent(self)
##	move_child(_loading_screen,hud.get_index())
## [/codeblock]
## This may seem an odd way to do this, but the alternative is having set properties at the SceneManager level
## before loading asset OR having yet another parameter to pass in (several if you want to options to control
## where in the scene tree or relative to which node you want to put it. By simply listening for this event,
## you can write any logic you want and handle it as needed without having to change SceneManager to suit your specific needs :)
func _add_loading_screen(transition_type:String="fade_to_black"):
	# using "no_in_transition" as the transition name when skipping a transition felt... weird
	# dunno if this solution is better, but it's only one line so I can live with this one-off
	# An alternative would be to store strating animations in a dictionary and swap them for the animation name
	# it removes this one-off, but adds a step elsewhere - all about preference.
	_transition = "no_to_transition" if transition_type == "no_transition" else transition_type
	_loading_screen = _loading_screen_scene.instantiate() as LoadingScreen
	get_tree().root.add_child(_loading_screen)
	_loading_screen.start_transition(_transition)
	
## This is likely the most common public method. It's used to change between two scenes (assets)[br][br]
## [b][color=plum]scene_to_load[/color][/b] - [String] path to the resource you'd like to load[br]	
## [b][color=plum]load_into[/color][/b] - [Node] Node you'd like to load the resource into[br]
## [b][color=plum]scene_to_unload[/color][/b] - [Node] scene you're unloading, leave null to skip unloading step thought YRMV - use with caution[br]
## [b][color=plum]transition_type[/color][/b] - [String] name of transition[br] see top of [Door] class for options
func swap_scenes(scene_to_load:String, load_into:Node=null, scene_to_unload:Node=null, transition_type:String="fade_to_black") -> void:
	
	if _loading_in_progress:
		push_warning("SceneManager is already loading something")
		return
	
	_loading_in_progress = true
	if load_into == null: load_into = get_tree().root
	_load_scene_into = load_into
	_scene_to_unload = scene_to_unload
	
	_add_loading_screen(transition_type)
	_load_content(scene_to_load)	

## Slight variation on swap_scenes that will result in a sliding, Zelda-dungeon-style transition between scenes[br][br]
## [b]Note:[/b] This version of SceneManager assumes that all levels are the same size (defined above as [code]LEVEL_H[/code] and [code]LEVEL_W[/code]
## If your game uses levels that vary in size, you will likely need to modify this method call to accept arguments
## that define the size of incoming and outgoing scenes and modify the tweens in in the Zelda block in the middle of
## [code]_on_content_finished_loading[/code] to properly set up the start/finish locations of the two scenes.
## Future versions of this SceneManager may account for this that flexibility was out of scope for this pass.
## Should you have questions about implementing this, please find me at https://www.youtube.com/@baconandgames and
## I'll do my best to assist if you get stuck :)
func swap_scenes_zelda(scene_to_load:String, load_into:Node, scene_to_unload:Node, move_dir:Vector2) -> void:
	
	if _loading_in_progress:
		push_warning("SceneManager is already loading something")
		return
	
	_transition = "zelda"
	_load_scene_into = load_into
	_scene_to_unload = scene_to_unload
	_zelda_transition_direction = move_dir
	_load_content(scene_to_load)

## internal - initailizes content. It's broken out in to its own function because this code would be repeated in
## [code]swap_scenes[/code] and [code]swap_scenes_zelda[/code]. In future versions, I'd like to find a more elegant
## solution for handing all transitions in the same fashion, but that wasn't in scope for this version. So for now,
## there is one method for the Zelda-style transition and another for the rest. All in due time. Don't bite off more thank you can chew :)
func _load_content(content_path:String) -> void:
	
	load_start.emit(_loading_screen)
	
	# zelda transition doesn't use a loading screen
	if _transition != "zelda":
		await _loading_screen.transition_in_complete
		
	_content_path = content_path
	var loader = ResourceLoader.load_threaded_request(content_path)
	if not ResourceLoader.exists(content_path) or loader == null:
		_content_invalid.emit(content_path)
		return 		
	
	_load_progress_timer = Timer.new()
	_load_progress_timer.wait_time = 0.1
	_load_progress_timer.timeout.connect(_monitor_load_status)
	
	get_tree().root.add_child(_load_progress_timer)		# NEW > insert loading bar into?
	_load_progress_timer.start()

## internal - checks in on loading status - this can also be done with a while loop, but I found that ran too fast
## and ended up skipping over the loading display. 
func _monitor_load_status() -> void:
	var load_progress = []
	var load_status = ResourceLoader.load_threaded_get_status(_content_path, load_progress)

	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_content_invalid.emit(_content_path)
			_load_progress_timer.stop()
			return
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if _loading_screen != null:
				_loading_screen.update_bar(load_progress[0] * 100) # 0.1
		ResourceLoader.THREAD_LOAD_FAILED:
			_content_failed_to_load.emit(_content_path)
			_load_progress_timer.stop()
			return
		ResourceLoader.THREAD_LOAD_LOADED:
			_load_progress_timer.stop()
			_load_progress_timer.queue_free()
			_content_finished_loading.emit(ResourceLoader.load_threaded_get(_content_path).instantiate())
			return # this last return isn't necessary but I like how the 3 dead ends stand out as similar

## internal - fires when content has begun loading but failed to complete
func _on_content_failed_to_load(path:String) -> void:
	printerr("error: Failed to load resource: '%s'" % [path])	

## internal - fires when attemption to load invalid content (e.g. content does not exist or path is incorrect)
func _on_content_invalid(path:String) -> void:
	printerr("error: Cannot load resource: '%s'" % [path])
	
## internal - fires when content is done loading. This is responsible for data transfer, adding the incoming scene
## removing the outgoing scene, hanlding the zelda transition (if of that type), halting the game until the 
## out transition finishes, and also fires off the signals you can listen for to manage the SceneTree as things
## are added. These will also be useful for initializing things before the user gains control after a transition
## as well as controlling when the user can resume control[br][br]
## [b]A Few Examples[/b][br]
## [b][color=plum]load_start[/color][/b] allows you to trigger something as soon as the loading screen is added to the tree, like for example playing a sound effect[br]	
## [b][color=plum]scene_added[/color][/b] triggers after the incoming scene is added to the tree, useful for rearraging your scene tree to make sure the loading screen stays on top of everything or perhaps keeping your HUD above the loading screen. The world is your oyster, friend! You can also initialize stuff here before passing control back to the user, because at this stage the transition hasn't finished yet[br]	
## [b][color=plum]load_complete[/color][/b] triggers at the end of _on_content_finished_loading, I use this to return control to the player[br][br]
## [b]Methods that a scene loaded through SceneManager can optionall implement[/b][br]
## [b][color=plum]get_data[/color][/b] a scene should implement this if you want a scene to expose data to pass to an incoming scene[br]	
## [b][color=plum]receive_data[/color][/b] a scene should implement this if you want that scene to be able to receive data from the outgoing scene. It is recommended that you check the data type of the incoming data to make sure it's of a type the incoming scene wants. If not, simply discard or don't set the data. This allows you to control which classes can send/receive information without having to worry about running into data mismatches. Think of it like an internal version of the "has_method" check.[br]	
## [b][color=plum]init_scene[/color][/b] implement this to be able to execute code (like initializing stuff based on what was passed in through receive_data) - this should fire before the _ready method of the scene[br]	
## [b][color=plum]start_scene[/color][/b] implement this to kick off your scene. I use it to return control to the player. But you could also trigger events with the scene or anything else you want to hold until loading and transitioning are both totally done.[br][br]
## For sample implementations, see [Level]
func _on_content_finished_loading(incoming_scene) -> void:
	var outgoing_scene = _scene_to_unload	# NEW > can't use current_scene anymore
	
	# if our outgoing_scene has data to pass, give it to our incoming_scene
	if outgoing_scene != null:	
		if outgoing_scene.has_method("get_data") and incoming_scene.has_method("receive_data"):
			incoming_scene.receive_data(outgoing_scene.get_data())
	
	# load the incoming into the designated node
	_load_scene_into.add_child(incoming_scene)
		# listen for this if you want to perform tasks on the scene immeidately after adding it to the tree
	# ex: moveing the HUD back up to the top of the stack
	scene_added.emit(incoming_scene,_loading_screen)
	
#	This block is only used by the zelda transition, which is a special case that doesn't use the loading screen
	if _transition == "zelda":
		# slide new level in
		incoming_scene.position.x = _zelda_transition_direction.x * LEVEL_W
		incoming_scene.position.y = _zelda_transition_direction.y * LEVEL_H
		var tween_in:Tween = get_tree().create_tween()
		tween_in.tween_property(incoming_scene, "position", Vector2.ZERO, 1).set_trans(Tween.TRANS_SINE)

		# slide old level out
		var tween_out:Tween = get_tree().create_tween()
		var vector_off_screen:Vector2 = Vector2.ZERO
		vector_off_screen.x = -_zelda_transition_direction.x * LEVEL_W
		vector_off_screen.y = -_zelda_transition_direction.y * LEVEL_H
		tween_out.tween_property(outgoing_scene, "position", vector_off_screen, 1).set_trans(Tween.TRANS_SINE)
	#	# once the tweens are done, do some cleanup
		await tween_in.finished
	
		# Remove the old scene
	if _scene_to_unload != null:
		if _scene_to_unload != get_tree().root: 
			_scene_to_unload.queue_free()
	
	# called right after scene is added to tree (presuming _ready has fired)
	# ex: do some setup before player gains control (I'm using it to position the player) 
	if incoming_scene.has_method("init_scene"): 
		incoming_scene.init_scene()
	
	# probably not necssary since we split our _content_finished_loading but it won't hurt to have an extra check
	if _loading_screen != null:
		_loading_screen.finish_transition()
		
		# Wait or loading animation to finish
		await _loading_screen.anim_player.animation_finished

	# if your incoming scene implements init_scene() > call it here
	# ex: I'm using it to enable control of the player (they're locked while in transition)
	if incoming_scene.has_method("start_scene"): 
		incoming_scene.start_scene()
	
	# load is complete, free up SceneManager to load something else and report load_complete signal
	_loading_in_progress = false
	load_complete.emit(incoming_scene)
