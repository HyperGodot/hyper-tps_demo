extends Node

onready var playerSpawnNodes : Node = find_node("PlayerSpawnNodes")

func _ready():
	randomize()
	pass

func _process(delta):
	pass
	
func getSpawnLocation() -> Vector3:
	var childCount : int = playerSpawnNodes.get_child_count()
	var spawnNode : Spatial = playerSpawnNodes.get_child( randi() % childCount )
	return spawnNode.translation
