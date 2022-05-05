extends Node

var bDebugPaused : bool = false
var mouseModeBackup
var UINode = null

func _ready():
	bDebugPaused = false
	get_tree().paused = false
	mouseModeBackup = Input.get_mouse_mode()
	
func CheckAndUpdateUINode():
	if(UINode == null):
		UINode = get_tree().get_current_scene().find_node("Menu_Main")
		
func HandleMouseToggle():
	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		mouseModeBackup = Input.get_mouse_mode()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(mouseModeBackup)
	
func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		# Toggle UI
		CheckAndUpdateUINode()
		if(UINode._getIsMenuShowing() ):
			UINode.hideUI()
		else:
			UINode.resetUI()
			UINode.showUI()
	if Input.is_action_just_pressed("toggleMouse"):
		# HandleMouseToggle()
		return
	if Input.is_action_just_pressed("toggle_slowmo"):
		if Engine.get_time_scale() < 1.0:
			Engine.set_time_scale(1.0)
		else:
			Engine.set_time_scale(0.1)
	if Input.is_action_just_pressed("superDEBUG"):
		# OS.create_process("Witchy_World.exe", [])
		OS.execute(OS.get_executable_path(), ["--main-pack", "witchy-world.pck"], false)
		get_tree().quit()
		
func _process(_delta):
	pass
