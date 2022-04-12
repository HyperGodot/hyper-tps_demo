extends Spatial

export var teleportation_destination : String = "map_test"

onready var mapsNode : Node = get_tree().get_current_scene().get_node("Maps")
onready var currentMapNode : Node = get_tree().get_current_scene().get_node("Maps").get_child(0)


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _on_Teleporter_gameplay_entered():
	pass


func tryMapChange(mapChangeName : String, sendGossip : bool, playerNode):
	var mapCurrentName = currentMapNode.name
	var mapNode = null
	if(mapCurrentName != teleportation_destination):
		currentMapNode.queue_free()
		if(mapChangeName == "map_test"):
			print("")
			mapNode = get_tree().get_current_scene().map_test
		elif(mapChangeName == "map_cyber"):
			print("")
			mapNode = get_tree().get_current_scene().map_cyber
		elif(mapChangeName == "map_cyber1"):
			print("")
			mapNode = get_tree().get_current_scene().map_cyber1
		var newMap = mapNode.instance()
		mapsNode.add_child(newMap)
		# Find a Respawn Point
		playerNode.currentSpawnLocation = playerNode.getSpawnLocation()
		playerNode.playerWantsToRespawn = true
		
		if(sendGossip):
			var data : Dictionary = {
			"map": {
				"name": mapChangeName
				}
			}
			#hyperGossip.broadcast_event(EVENT_PLAYER_MAPCHANGE, data)


func _on_CollisionShape_gameplay_entered():
	pass # Replace with function body.


func _on_Hitbox_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if(body is KinematicBody):
		tryMapChange(teleportation_destination, true, body)
