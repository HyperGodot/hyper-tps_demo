extends Node

onready var map_test = preload("res://game/maps/map_test/map_test.tscn")
onready var map_cyber = preload("res://game/maps/map_cyber/map_cyber.tscn")
onready var map_cyber1 = preload("res://game/maps/map_cyber1/map_cyber1.scn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func fartPussy():
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func getSpawnLocation() -> Vector3:
	# Get Number of Maps
	var childCount : int = self.get_child(0).get_child_count()
	# Get Random Map
	var mapNode = self.get_child(0).get_child( randi() % childCount )
	
	# Get Random Spawn Location from Map
	var playerSpawnNodes = mapNode.find_node("PlayerSpawnNodes", true, false)
	# Get Number of Spawn Nodes
	childCount = playerSpawnNodes.get_child_count()
	# Get Random Spawn Node
	var spawnNode : Spatial = playerSpawnNodes.get_child( randi() % childCount )
	# Get Global Space
	var globalCoord = spawnNode.global_transform.origin
	
	# Return!
	return spawnNode.global_transform.origin
