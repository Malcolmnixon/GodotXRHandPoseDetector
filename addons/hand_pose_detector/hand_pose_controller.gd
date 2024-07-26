@tool
class_name HandPoseController
extends HandPoseDetector


## Hand Pose Controller Node
##
## This script creates an XRControllerTracker moved by an associated
## HandPoseDetector, and capable of generating XR Input Actions in response
## to detected hand poses.
##
## The XRControllerTracker will have a "default" pose whose position is based
## on the tracked hand and the selected pose_type.


## Pose Type
enum PoseType {
	SKELETON,	## Skeleton pose (palm pose)
	AIM,		## Aim pose (aiming pose)
	GRIP		## Grip pose (gripping pose)
}

# Table of left-hand pose transforms by PoseType
const _POSE_TRANSFORMS_LEFT : Array[Transform3D] = [
	# Skeleton-pose (identity)
	Transform3D(
		Basis.IDENTITY,
		Vector3.ZERO),

	# Aim pose - see OpenXR specification
	Transform3D(
		Basis(Quaternion(0.5, -0.5, 0.5, 0.5)),
		Vector3(-0.05, 0.11, 0.035)),

	# Grip pose - see OpenXR specification
	Transform3D(
		Basis(Quaternion(0.6408564, -0.2988362, 0.6408564, 0.2988362)),
		Vector3(0.0, 0.0, 0.025))
]

# Table of right-hand pose transforms by PoseType
const _POSE_TRANSFORMS_RIGHT : Array[Transform3D] = [
	# Skeleton-pose (identity)
	Transform3D(
		Basis.IDENTITY,
		Vector3.ZERO),

	# Aim pose - see OpenXR specification
	Transform3D(
		Basis(Quaternion(0.5, 0.5, -0.5, 0.5)),
		Vector3(0.05, 0.11, 0.035)),

	# Grip pose - see OpenXR specification
	Transform3D(
		Basis(Quaternion(-0.6408564, -0.2988362, 0.6408564, -0.2988362)),
		Vector3(0.0, 0.0, 0.025))
]


@export_group("Controller", "controller_")

## Name for the virtual controller tracker
@export var controller_tracker_name : String = "/user/hand_pose_controller/left"

## Pose type
@export var controller_pose_type : PoseType = PoseType.SKELETON

## Hand poses generating boolean values
@export var controller_action_map : HandPoseActionMap


## Controller Tracker
var controller_tracker : XRControllerTracker


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Call the base
	super()

	# Skip if in editor
	if Engine.is_editor_hint():
		set_process(false)
		return

	# If the hand-pose-set is not specified then construct one dynamically
	# from the controller action map.
	if not hand_pose_set and controller_action_map:
		hand_pose_set = HandPoseSet.new()
		for action in controller_action_map.actions:
			hand_pose_set.poses.append(action.pose)

	# Subscribe to the detector events
	pose_started.connect(_pose_started)
	pose_ended.connect(_pose_ended)

	# Create the controller tracker
	controller_tracker = XRControllerTracker.new()
	controller_tracker.name = controller_tracker_name
	XRServer.add_tracker(controller_tracker)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Call the base
	super(delta)

	# Skip if no trackers
	if not hand_tracker or not controller_tracker:
		return

	# Get the hand tracker pose
	var pose := hand_tracker.get_pose(&"default")
	if not pose:
		return

	# Get the conversion transform
	var hand := hand_tracker.hand

	# Get the conversion transform
	var conv_xform : Transform3D
	if hand == XRPositionalTracker.TrackerHand.TRACKER_HAND_LEFT:
		conv_xform = _POSE_TRANSFORMS_LEFT[controller_pose_type]
	else:
		conv_xform = _POSE_TRANSFORMS_RIGHT[controller_pose_type]

	# Apply conversion to pose components
	var pose_transform := pose.transform * conv_xform
	var pose_linear := pose.linear_velocity * conv_xform.basis
	var pose_angular := _rotate_angular_velocity(pose.angular_velocity, conv_xform.basis)

	# Update the controller tracker pose
	controller_tracker.hand = hand
	controller_tracker.set_pose(
		pose.name,
		pose_transform,
		pose_linear,
		pose_angular,
		pose.tracking_confidence)


# Customize properties
func _validate_property(property: Dictionary) -> void:
	if property.name == "controller_tracker_name":
		property.hint = PROPERTY_HINT_ENUM_SUGGESTION
		property.hint_string = "/user/hand_pose_controller/left,/user/hand_pose_controller/right"
	else:
		super(property)


# Get configuration warnings
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super()

	# Verify controller tracker name is set
	if controller_tracker_name == "":
		warnings.append("Controller racker name not set")

	# Return the warnings
	return warnings


# Handle start of pose
func _pose_started(p_name : String) -> void:
	# Skip if no tracker or action map
	if not controller_tracker or not controller_action_map:
		return

	# Find the action
	var action := controller_action_map.get_action(p_name)
	if not action:
		return

	# Set the input
	if action.action_type == HandPoseAction.ActionType.BOOL:
		controller_tracker.set_input(action.action_name, true)
	else:
		controller_tracker.set_input(action.action_name, 1.0)


# Handle end of pose
func _pose_ended(p_name : String) -> void:
	# Skip if no tracker or action map
	if not controller_tracker or not controller_action_map:
		return

	# Find the action
	var action := controller_action_map.get_action(p_name)
	if not action:
		return

	# Set the input
	if action.action_type == HandPoseAction.ActionType.BOOL:
		controller_tracker.set_input(action.action_name, false)
	else:
		controller_tracker.set_input(action.action_name, 0.0)


# Returns an angular velocity rotated by the given basis matrix.
static func _rotate_angular_velocity(vel : Vector3, basis : Basis) -> Vector3:
	# Get the angular velocity length
	var len := vel.length()
	if is_zero_approx(len):
		return Vector3.ZERO

	# Normalize the angular velocity
	vel /= len

	# Rotate the angular velocity using quaternion composition
	var vel_quat := Quaternion.from_euler(vel)
	vel_quat *= basis.get_rotation_quaternion()
	vel = vel_quat.get_euler()

	# Scale the angular velocity back to the appropriate magnitude
	return vel * len
