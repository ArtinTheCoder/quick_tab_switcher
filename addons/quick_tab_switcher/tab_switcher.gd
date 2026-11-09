@tool
extends EditorPlugin

var scene_tab_bar: TabBar

func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass

func _enter_tree() -> void:
	set_process_input(true)

func _exit_tree() -> void:
	set_process_input(false)
	scene_tab_bar = null

func _input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event == null:
		return

	if not key_event.pressed or key_event.echo:
		return
		
	if not key_event.is_command_or_control_pressed() or key_event.shift_pressed or key_event.alt_pressed:
		return
	
	var number := key_to_number(key_event.keycode)
	if number == 0:
		return

	if switch_to_tab(number):
		get_viewport().set_input_as_handled()
	 
 
func key_to_number(keycode: Key) -> int:
	if keycode >= KEY_1 and keycode <= KEY_9:
		return keycode - KEY_0
	return 0

func switch_to_tab(number: int) -> bool:
	var tab_bar := get_scene_tab_bar()
	if tab_bar != null and tab_bar.tab_count > 0:
		var index: int
		if number == 9:
			index = tab_bar.tab_count - 1
		else:
			index = number - 1
	
		if index >= tab_bar.tab_count:
			return false
			
		if tab_bar.current_tab != index:
			tab_bar.current_tab = index

		return true
 
	# fallback but this only works for saved scenes.
	var scenes := EditorInterface.get_open_scenes()
	
	if scenes.is_empty():
		return false
		
	var idx: int
	
	if number == 9:
		idx = scenes.size() - 1
	else:
		idx = number - 1
		
	if idx >= scenes.size():
		return false
		
	EditorInterface.open_scene_from_path(scenes[idx])
	return true
 
func get_scene_tab_bar() -> TabBar:
	if is_instance_valid(scene_tab_bar):
		return scene_tab_bar
 
	var base := EditorInterface.get_base_control()
	var scene_tabs := find_by_class(base, "EditorSceneTabs")
	if scene_tabs == null:
		return null
 
	var bars := scene_tabs.find_children("*", "TabBar", true, false)
	if bars.is_empty():
		return null
		
	scene_tab_bar = bars[0]
	return scene_tab_bar
 
func find_by_class(node: Node, class_name_: String) -> Node:
	if node.get_class() == class_name_:
		return node
		
	for child in node.get_children():
		var found := find_by_class(child, class_name_)
		if found != null:
			return found

	return null
