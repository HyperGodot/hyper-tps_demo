extends Control

onready var playerNode = get_node("../../../Players/PlayerLocal")
onready var currentMapNode : Node = get_tree().get_current_scene().get_node("CurrentMap")
onready var actualMapNode : Spatial = get_tree().get_current_scene().get_node("CurrentMap").find_node("*", true, false)
onready var inputValue : Label = $Panel/MarginContainer/GridContainer/Input_Value
onready var velocityValue : Label = $Panel/MarginContainer/GridContainer/Velocity_Value
onready var speedValue : Label = $Panel/MarginContainer/GridContainer/Speed_Value
onready var onfloorValue : Label = $Panel/MarginContainer/GridContainer/OnFloor_Value

# var map_cyber = preload("res://assets/maps/maps_cyber/level0.tscn")


func _ready():
	inputValue.text = String(Vector3.ZERO)
	velocityValue.text = String(Vector3.ZERO)
	onfloorValue.text = "N/A"


func _process(_delta):
	inputValue.text = String(playerNode.currentDirection)
	velocityValue.text = String(playerNode.kinematicVelocity)
	speedValue.text = String(playerNode.currentSpeed)
	if( playerNode.is_on_floor() ):
		onfloorValue.text = "Yes"
	else:
		onfloorValue.text = "No"


func physicsModeToString() -> String:
	if(playerNode is KinematicBody):
		return "KinematicBody"
	elif(playerNode is RigidBody):
		if(playerNode.mode == RigidBody.MODE_RIGID):
			return "Rigid"
		elif(playerNode.mode == RigidBody.MODE_STATIC):
			return "Static"
		elif(playerNode.mode == RigidBody.MODE_CHARACTER):
			return "Character"
		elif(playerNode.mode == RigidBody.MODE_KINEMATIC):
			return "Kinematic"
		else:
			return "Unknown"
	else:
		return "Unknown"


func _on_Button_button_up():
	#actualMapNode.queue_free()
	#var newMap = map_cyber.instance()
	#currentMapNode.add_child(newMap)
	pass
