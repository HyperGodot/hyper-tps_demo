extends Spatial

onready var playerSpawnNodes : Node = find_node("PlayerSpawnNodes")

func _ready():
	randomize()
	addGrapplingHookCollisionMaskToMap()

func _process(_delta):
	pass
	
func getSpawnLocation() -> Vector3:
	var childCount : int = playerSpawnNodes.get_child_count()
	var spawnNode : Spatial = playerSpawnNodes.get_child( randi() % childCount )
	return spawnNode.translation

func addGrapplingHookCollisionMaskToMap():
	var _name = self.name
	# var currentMap : Node = get_tree().get_current_scene().get_node("Maps").find_node(_name, true, false)
	# var assetMap : Spatial = currentMap.find_node("asset_" + currentMap.name)
	checkAndSetChildrenGrapplingHookMask(self, 0)
				
func checkAndSetChildrenGrapplingHookMask(var _Node, indentLevel : int):
	var _strIndents : String = ""
	for _i in range(indentLevel):
		_strIndents += "\t"
		
	if(_Node is StaticBody):
		_Node.collision_layer += 2
		
	var childCount = _Node.get_child_count()
	for i in range(childCount):
		checkAndSetChildrenGrapplingHookMask(_Node.get_child(i), indentLevel + 1)
