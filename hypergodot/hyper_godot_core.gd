extends Node

var hyperGateway : HyperGateway
var hyperGossip : HyperGossip
var hyperDebugUI : Control

func _ready():
	hyperGateway = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGateway")
	hyperGossip = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGossip")
	hyperDebugUI = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperDebugUI")

func _process(_delta):
	pass

func _perform_setup():
	hyperGossip.start_listening()
	
func _on_HyperGateway_started_gateway(_pid : int):
	if !hyperGateway:
		hyperGateway = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGateway")
	if !hyperGossip:
		hyperGossip = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGossip")
	#if !debugui:
	#	debugui = get_tree().get_current_scene().get_node("HyperGodotDebugUI")
	if(hyperDebugUI):
		hyperDebugUI.updateGatewayStatus()
	_perform_setup()

func _on_HyperGateway_stopped_gateway():
	if(hyperDebugUI):
		hyperDebugUI.updateGatewayStatus()
