extends KinematicBody

var hyperGossip : HyperGossip

# TODO : These probably should not be in player_core, though I am uncertain yet if they belong elsewhere
const EVENT_PLAYER_SNAPSHOT = 'player_snapshot'
const EVENT_PLAYER_WANTSTOJUMP = 'player_wantstojump'
const EVENT_PLAYER_DIRECTION = 'player_direction'
const EVENT_PLAYER_RESPAWNPLAYER = 'player_respawnplayer'

export var mouseSensitivity : float = 0.3
export var movementSpeed : float = 14
export var fallAcceleration : float = 27
export var movementAcceleration : float = 4
export var canJumpHeight : float = 10
export var jumpHeight : float = 15
export var turn_velocity : float = 15
export var cameraLerpAmount : float = 40
export var currentSpeed : float = 0

onready var meshNode : Spatial = $Model
onready var clippedCamera : Spatial = $CameraHead/CameraPivot/ClippedCamera
onready var clippedCameraHead : Spatial = $CameraHead
onready var clippedCameraPivot : Spatial = $CameraHead/CameraPivot
# onready var csgMesh : CSGMesh = $Head/CamPivot/ClippedCamera/GrappleCast/CSGMesh

onready var meshCollisionShape : CollisionShape = $CollisionShape

onready var grappleHookCast : RayCast = $CameraHead/CameraPivot/GrappleHookCast
onready var grappleVisualPoint : CSGSphere = $GrapplingHook/GrappleVisualPoint
onready var grappleLineHelper : Spatial = $GrapplingHook/LineHelper
onready var grappleVisualLine : CSGCylinder = $GrapplingHook/LineHelper/GrappleVisualLine

var grapplingHook_GrapplePosition : Vector3 = Vector3.ZERO
var grapplingHook_IsHooked : bool = false

# TODO : Make Debug UI dynamic and not hardcoded in the core Hyper scripts.
#onready var hyperdebugui : Control = $HyperGodotDebugUI
#onready var hyperdebugui_gateway_startstop_button : Button = $HyperGodotDebugUI/HypercoreDebugPanel/HypercoreDebugContainer/GatewayStartStopButton
#onready var hyperdebugui_gossipid_list : ItemList = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGateway")

var currentMap = null
var originalOrigin : Vector3 = Vector3.ZERO
var currentSpawnLocation : Vector3 = Vector3.ZERO

var currentDirection : Vector3 = Vector3.ZERO
var moveNetworkUpdateAllowed : bool = true

var playerWantsToRespawn : bool = false
var jumpFloorDirection : Vector3 = Vector3(0,1,0)
var playerCanJump : bool = false
var playerWantsToJump : bool = false

var f_input : float
var h_input : float

var snapVector : float

var kinematicVelocity : Vector3 = Vector3.ZERO

var collisions : Dictionary = {}

func _ready():
	# Get Current Map
	currentMap = get_tree().get_current_scene().get_node("CurrentMap").get_child(0)
	
	# Backup Origin
	originalOrigin = self.translation
	
	# Spawn into Map
	currentSpawnLocation = getSpawnLocation()
	playerWantsToRespawn = true
	
	# Grappling Hook Setup
	grappleHookCast.add_exception(meshCollisionShape)
	grappleHookCast.add_exception(clippedCameraPivot)
	grappleHookCast.add_exception(clippedCameraHead)
	grappleHookCast.add_exception(meshNode)
	grappleHookCast.add_exception(grappleVisualPoint)
	# grappleHookCast.set_collision_mask_bit(2, true)
	
	# Get HyperGossip
	hyperGossip = get_tree().get_current_scene().get_node("HyperGodot").get_node("HyperGossip")
	
func snapShotUpdate(_translation : Vector3, _meshDirection : Vector3, _lookingDirection : Vector3):
	self.translation = _translation
	self.meshNode.rotation = _meshDirection
	self.currentDirection = _lookingDirection
	
func translationUpdate(_translation : Vector3):
	self.translation = _translation

func directionUpdate(_direction : Vector3):
	self.currentDirection = _direction
	
func getSpawnLocation() -> Vector3:
	var spawnLocation : Vector3 = currentMap.getSpawnLocation()
	return spawnLocation


func _process(_delta):
	if(currentDirection != Vector3.ZERO):
		meshNode.rotation.y = lerp_angle(meshNode.rotation.y, atan2(-currentDirection.x, -currentDirection.z), turn_velocity * _delta)
	pass
	var meshSkel : Skeleton
	meshSkel = meshNode.find_node("Skeleton", true)
	var bone = meshSkel.find_bone("DEF-hand.R")
	var bonePos = meshSkel.get_bone_pose(bone)
	bonePos = bonePos.scaled( Vector3(0, 0, 0) )
	meshSkel.set_bone_pose(bone, bonePos)
	#meshSkel.add_child(boneAttachment)
	
func grapplingHook_Process():
	grapplingHook_CheckActivation()
	var length : float = grapplingHook_UpdatePlayerVelocityAndReturnHookLength()
	grapplingHook_UpdateVisualLine(length)
	grapplingHook_UpdateVisualPoint()
	
func grapplingHook_CheckActivation():
	# Activate hook
	if( Input.is_action_just_pressed("shoot") and grappleHookCast.is_colliding() ):
		grapplingHook_IsHooked = true
		grapplingHook_GrapplePosition = grappleHookCast.get_collision_point()
		grappleVisualLine.show()
		$Model/Sound_Shoot.play()
	# Stop grappling
	elif( Input.is_action_just_released("shoot") ):
		grapplingHook_IsHooked = false
		grappleVisualLine.hide()
	
func grapplingHook_UpdateVisualPoint():
	if grappleHookCast.is_colliding():
		grappleVisualPoint.visible = true
		grappleVisualPoint.translation = grappleHookCast.get_collision_point()
	else:
		grappleVisualPoint.visible = false
		
func grapplingHook_UpdateVisualLine(length : float):
	grappleLineHelper.look_at(grapplingHook_GrapplePosition, Vector3.UP)
	grappleVisualLine.height = length
	grappleVisualLine.translation.z = length / -2
		
func grapplingHook_UpdatePlayerVelocityAndReturnHookLength() -> float:
	var grapple_speed : float = 0.5
	var rest_length : float = 1
	var max_grapple_speed : float = 2.75
	
	var player2hook := grapplingHook_GrapplePosition - translation # vector from player to hook
	var length := player2hook.length()
	if(grapplingHook_IsHooked):
		# if we more than 4 away from line, don't dampen speed as much
		if(length > 4):
			kinematicVelocity *= .999
		# Otherwise dampen speed more
		else:
			kinematicVelocity *= .9
		
		# Hook's law equation
		var force := grapple_speed * (length - rest_length)
		
		# Clamp force to be less than max_grapple_speed
		if abs(force) > max_grapple_speed:
			force = max_grapple_speed
		
		# Preserve direction, but scale by force
		kinematicVelocity += player2hook.normalized() * force
	
	return length

var jumpingUp : bool
func _physics_process(_delta):
	# Respawn Player here first
	if(playerWantsToRespawn):
		playerWantsToRespawn = false
		respawnPlayer()
		return
	
	# Moving the character
	var y_cache : float = kinematicVelocity.y
	kinematicVelocity = kinematicVelocity.linear_interpolate(currentDirection * movementSpeed, movementAcceleration * _delta)
	kinematicVelocity.y = y_cache
	# Vertical velocity
	kinematicVelocity.y -= fallAcceleration * _delta
	if(playerWantsToJump):
		playerWantsToJump = false
		if( playerCanJump() ):
			kinematicVelocity.y = jumpHeight
			jumpingUp = true
			$Model/Sound_Jump.play()
	kinematicVelocity = move_and_slide(kinematicVelocity, Vector3.UP)
	
	# Calculate Potential Jumping Animation
	if( !is_on_floor() ):
		if(kinematicVelocity.y > 0.1):
			$AnimationTree.set("parameters/air_transition/current", 0)
			$AnimationTree.set("parameters/air_blend/blend_amount", -1)
		elif(kinematicVelocity.y < -0.1):
			$AnimationTree.set("parameters/air_transition/current", 0)
			$AnimationTree.set("parameters/air_blend/blend_amount", 0)
	else:
		$AnimationTree.set("parameters/air_transition/current", 1)
	
	# Calculate Running Animation
	currentSpeed = ( (abs(kinematicVelocity.x) + abs(kinematicVelocity.z) - 7) / 7)
	$AnimationTree.set("parameters/iwr_blend/blend_amount", currentSpeed)
	
	# Update Grappling Hook
	grapplingHook_Process()
		
	
	#	self.linear_velocity.y += jumpHeight
	#	playerWantsToJump = false
		
	#var y_cache = linear_velocity.y
	#linear_velocity = linear_velocity.linear_interpolate(currentDirection * movementSpeed, movementAcceleration * _delta)
	#linear_velocity.y = y_cache
	#linear_velocity = Vector3(currentDirection.x, 0, currentDirection.z).normalized() * movementSpeed * _delta
	#linear_velocity.y = y_cache
	
	#linear_velocity.x += currentDirection.x * movementSpeed * _delta
	#linear_velocity.x = clamp(linear_velocity.x, -3, 3)
	#linear_velocity.z += currentDirection.z * movementSpeed * _delta
	#linear_velocity.z = clamp(linear_velocity.z, -3, 3)
	
	# Handle Jumping / Gravity
	#if is_on_floor():
	#if true:
	#	snapVector = -get_floor_normal()
	#	gravity_vec = Vector3.ZERO
	#else:
	#	snap = Vector3.DOWN
	#	accel = ACCEL_AIR
	#	gravity_vec += Vector3.DOWN * gravity * delta
		
	#if Input.is_action_just_pressed("jump") and is_on_floor():
	#	snap = Vector3.ZERO
	#	gravity_vec = Vector3.UP * jump
	
	# Actually Movement
	#velocityAmount = velocityAmount.linear_interpolate(currentDirection * movementSpeed, accelerationDefault * delta)
	# finalMovement = velocityAmount + finalgravityVelociy
	
func respawnPlayer():
	kinematicVelocity = Vector3.ZERO
	self.translation = currentSpawnLocation

func playerCanJump() -> bool:
	if( self.is_on_floor() ):
		return true
	else:
		return false

func canJump(state : PhysicsDirectBodyState):
	# Raycast from state to ground based on canJumpHeight and straight down (use self to exclude raycast from intersecting itself)
	var hitDictionary : Dictionary = state.get_space_state().intersect_ray(global_transform.origin, canJumpHeight * jumpFloorDirection, [self])
	# If the dictionary is empty, nothing was hit, so we can't jump
	if hitDictionary.size() == 0:
		return false
	else:
		var collider : StaticBody = hitDictionary.collider

		var parent = collider.get_parent()
		if(parent is MeshInstance):
			if(true):
				var material : SpatialMaterial = SpatialMaterial.new()
				material.albedo_color = Color(0, 188, 0)
				parent.material_override = material
			else:
				parent.material_override = null
		return true

func _on_Input_player_mousemotion_event(event):
	clippedCameraHead.rotate_y(deg2rad(-event.relative.x * mouseSensitivity))
	clippedCameraPivot.rotate_x(deg2rad(-event.relative.y * mouseSensitivity))
	clippedCameraPivot.rotation.x = clamp(clippedCameraPivot.rotation.x, deg2rad(-89), deg2rad(89))


func _on_Input_player_move(direction : Vector3):
	currentDirection = direction
	
	if(moveNetworkUpdateAllowed):
		var data : Dictionary = {
		"direction": {
			"x": currentDirection.x,
			"y": currentDirection.y,
			"z": currentDirection.z
			},
		"translation": {
			"x": self.translation.x,
			"y": self.translation.y,
			"z": self.translation.z
			}
		}
		hyperGossip.broadcast_event(EVENT_PLAYER_DIRECTION, data)
		moveNetworkUpdateAllowed = false
	#var h_rot = clippedCameraHead.global_transform.basis.get_euler().y
	# Adjust Current Direction based on Mouse Direction
	#currentDirection = Vector3(direction.x, 0, direction.z).rotated(Vector3.UP, h_rot).normalized()


func _on_Input_player_restore_origin() -> void:
	playerWantsToRespawn = true
	var spawnLocation : Vector3 = getSpawnLocation()
	currentSpawnLocation = spawnLocation
	
	var data : Dictionary = {
	#"profile": profile,
	"spawnLocation": {
		"x": spawnLocation.x,
		"y": spawnLocation.y,
		"z": spawnLocation.z
		}
	}
	
	hyperGossip.broadcast_event(EVENT_PLAYER_RESPAWNPLAYER, data)

func _on_Input_player_change_physics_mode() -> void:
	self.mode += 1
	if(self.mode > RigidBody.MODE_KINEMATIC):
		self.mode = RigidBody.MODE_RIGID


func _on_Input_player_jump():
	playerWantsToJump = true
	hyperGossip.broadcast_event(EVENT_PLAYER_WANTSTOJUMP, getPlayerLocalPositionData() )
	

func _on_Input_player_shoot():
	pass
	
	
func _checkPlayerCanJump(newBody : PhysicsBody, addedBody : bool) -> void:
	# Check if this is a new body added
	if(addedBody):
		# If we are adding a collision, check if we already can jump
		if(playerCanJump):
			return
			
	var hit = newBody.get_space_state().intersect_ray(Vector3(), canJumpHeight * -jumpFloorDirection, [self])
	
	# Check if any surfaces intersected
	if hit.size() == 0:
		playerCanJump = false
	else:
		playerCanJump = true

func _on_Player_body_entered(body : Node) -> void:
	if(!collisions.has(body.get_instance_id()) ):
		collisions[body.get_instance_id()] = body.name
		$CollisionUI.onNewollision(body, collisions)
		

func _on_Player_body_exited(body : Node) -> void:
	if(collisions.has(body.get_instance_id()) ):
		collisions.erase(body.get_instance_id())
		$CollisionUI.onRemovedCollision(body, collisions)

func _on_MoveNetworkTimer_timeout():
	moveNetworkUpdateAllowed = true
	
func getPlayerLocalPositionData() -> Dictionary:
	# TODO : Fix finding the local player, and get it out of player_core into player_core_local
	var localPlayer : KinematicBody = get_tree().get_current_scene().get_node("Players").get_node("PlayerLocal")
	var translation : Vector3 = localPlayer.translation
	var direction : Vector3 = localPlayer.currentDirection

	var data : Dictionary = {
	#"profile": profile,
	"translation": {
		"x": translation.x,
		"y": translation.y,
		"z": translation.z
		},
	"direction": {
		"x": direction.x,
		"y": direction.y,
		"z": direction.z
		}
	}

	return data
