extends Node

var hyperGateway : HyperGateway
var hyperGossip : HyperGossip
var hyperDebugUI : Control
var localSnapshotTimer : Timer

const knownPlayers = {}

# TODO : Move these out of here and share with Gossip / game-level constants
const EVENT_PLAYER_SNAPSHOT = 'player_snapshot'
const EVENT_PLAYER_WANTSTOJUMP = 'player_wantstojump'
const EVENT_PLAYER_DIRECTION = 'player_direction'
const EVENT_PLAYER_RESPAWNPLAYER = 'player_respawnplayer'

var PlayerCoreLocal = preload("res://game/player/player_core_local.tscn")
var PlayerCoreRemote = preload("res://game/player/player_core_remote.tscn")

func _ready():
	hyperGateway = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGateway")
	hyperGossip = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGossip")
	hyperDebugUI = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperDebugUI")
	localSnapshotTimer = get_tree().get_current_scene().get_node("HyperGodot").get_node("LocalSnapshotTimer")

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


func _on_HyperDebugUI_gossip_update_rate_changed(seconds: float):
	localSnapshotTimer.wait_time = seconds
	localSnapshotTimer.start(seconds)


func _on_LocalSnapshotTimer_timeout():
	var snapShotData : Dictionary
	if hyperGateway.getIsGatewayRunning():
		snapShotData = getPlayerLocalSnapshotData()
		
		hyperGossip.broadcast_event(EVENT_PLAYER_SNAPSHOT, snapShotData)
		
func _on_HyperGossip_listening(extension_name):
	var snapShotData : Dictionary = getPlayerLocalSnapshotData()
	hyperGossip.broadcast_event(EVENT_PLAYER_SNAPSHOT, snapShotData)

# TODO : Get these out of here and into player_core or player_core_remote
func _on_HyperGossip_event(type, data, from):
	if type == EVENT_PLAYER_SNAPSHOT:
		updatePlayerWithSnapshot(data, from)
	elif type == EVENT_PLAYER_WANTSTOJUMP:
		updatePlayer_wantstojump(data, from)
	elif type == EVENT_PLAYER_DIRECTION:
		updatePlayer_direction(data, from)
	elif type == EVENT_PLAYER_RESPAWNPLAYER:
		updatePlayer_respawnPlayer(data, from)
	
func get_player_object(id):
	if knownPlayers.has(id):
		return knownPlayers[id]

	var remotePlayer = PlayerCoreRemote.instance()
	knownPlayers[id] = remotePlayer
	
	hyperDebugUI.addGossipIDToList(id)

	add_child(remotePlayer)

	return remotePlayer
	
func updatePlayerWithSnapshot(snapShotData, id):
	var remotePlayer = get_player_object(id)

	var translation : Vector3 = Vector3(snapShotData.translation.x, snapShotData.translation.y, snapShotData.translation.z)
	var meshDirection : Vector3 = Vector3(snapShotData.meshDirection.x, snapShotData.meshDirection.y, snapShotData.meshDirection.z)
	var lookingDirection : Vector3 = Vector3(snapShotData.lookingDirection.x, snapShotData.lookingDirection.y, snapShotData.lookingDirection.z)
	
	remotePlayer.snapShotUpdate(
		translation,
		meshDirection,
		lookingDirection
	)
	
func updatePlayer_wantstojump(data, id):
	var remotePlayer = get_player_object(id)
	
	remotePlayer.translationUpdate( Vector3(data.translation.x, data.translation.y, data.translation.z) )
	remotePlayer.directionUpdate( Vector3(data.direction.x, data.direction.y, data.direction.z) )
	remotePlayer.playerWantsToJump = true
	
func updatePlayer_respawnPlayer(data, id):
	var remotePlayer = get_player_object(id)
	
	remotePlayer.currentSpawnLocation = Vector3(data.spawnLocation.x, data.spawnLocation.y, data.spawnLocation.z)
	remotePlayer.respawnPlayer()
	
func updatePlayer_direction(data, id):
	var remotePlayer = get_player_object(id)
	
	remotePlayer.translationUpdate( Vector3(data.translation.x, data.translation.y, data.translation.z) )
	remotePlayer.directionUpdate( Vector3(data.direction.x, data.direction.y, data.direction.z) )

func getPlayerLocalSnapshotData() -> Dictionary:
	var snapshotPlayer : KinematicBody = get_tree().get_current_scene().get_node("Players").get_node("PlayerLocal")
	var translation : Vector3 = snapshotPlayer.translation
	var meshDirection : Vector3 = Vector3(0, snapshotPlayer.meshNode.rotation.y, 0)
	var lookingDirection : Vector3 = snapshotPlayer.currentDirection
	
	var data : Dictionary = {
		#"profile": profile,
		"translation": {
			"x": translation.x,
			"y": translation.y,
			"z": translation.z
		},
		"meshDirection": {
			"x": meshDirection.x,
			"y": meshDirection.y,
			"z": meshDirection.z
		},
		"lookingDirection": {
			"x": lookingDirection.x,
			"y": lookingDirection.y,
			"z": lookingDirection.z
		}
	}

	return data
