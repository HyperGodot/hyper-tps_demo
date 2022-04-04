extends Control

onready var playerNode = get_node("../../../Players/PlayerLocal")
onready var currentMapNode : Node = get_tree().get_current_scene().get_node("CurrentMap")
onready var actualMapNode : Spatial = get_tree().get_current_scene().get_node("CurrentMap").find_node("*", true, false)
onready var inputValue : Label = $Panel/MarginContainer/GridContainer/Input_Value
onready var velocityValue : Label = $Panel/MarginContainer/GridContainer/Velocity_Value
onready var angularVelocity : Label = $Panel/MarginContainer/GridContainer/AngularVelocity
onready var angularVelocityValue : Label = $Panel/MarginContainer/GridContainer/AngularVelocity_Value

var map_cyber = preload("res://assets/maps/maps_cyber/level0.tscn")


func _ready():
	inputValue.text = String(Vector3.ZERO)
	velocityValue.text = String(Vector3.ZERO)
	if(playerNode is KinematicBody):
		angularVelocity.text = "On Floor :"
		angularVelocityValue.text = "N/A"
	else:
		angularVelocityValue.text = "N/A"


func _process(_delta):
	inputValue.text = String(playerNode.currentDirection)
	if(playerNode is KinematicBody):
		velocityValue.text = String(playerNode.kinematicVelocity)
		if( playerNode.is_on_floor() ):
			angularVelocityValue.text = "Yes"
		else:
			angularVelocityValue.text = "No"
	elif(playerNode is RigidBody):
		velocityValue.text = String(playerNode.linear_velocity)
		angularVelocityValue.text = String(playerNode.angular_velocity)


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
	actualMapNode.queue_free()
	var newMap = map_cyber.instance()
	currentMapNode.add_child(newMap)
