@tool
class_name HandPoseController
extends Node


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
		Basis(Quaternion(0.4304593, -0.5609855, 0.4304593, 0.5609855)),
		Vector3(-0.03, 0.08, 0.025)),

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
		Basis(Quaternion(0.4304593, 0.5609855, -0.4304593, 0.5609855)),
		Vector3(0.03, 0.08, 0.025)),

	# Grip pose - see OpenXR specification
	Transform3D(
		Basis(Quaternion(-0.6408564, -0.2988362, 0.6408564, -0.2988362)),
		Vector3(0.0, 0.0, 0.025))
]


## Name for the virtual controller tracker
@export var tracker_name : String = "/user/hand_pose_controller/left"

## Pose type
@export var pose_type : PoseType = PoseType.SKELETON

## Hand poses generating boolean values
@export var action_set : HandPoseActionSet


## Hand Pose Detector
var pose_detector : HandPoseDetector

## Controller Tracker
var tracker : XRControllerTracker


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Skip if in editor
	if Engine.is_editor_hint():
		set_process(false)
		return

	# Get the pose detector
	pose_detector = get_parent() as HandPoseDetector
	if not pose_detector:
		set_process(false)
		return

	# Subscribe to the detector events
	pose_detector.pose_started.connect(_pose_started)
	pose_detector.pose_ended.connect(_pose_ended)

	# Create the controller tracker
	tracker = XRControllerTracker.new()
	tracker.name = tracker_name
	XRServer.add_tracker(tracker)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Skip if no trackers
	if not pose_detector.tracker or not tracker:
		return

	# Get the hand tracker pose
	var pose := pose_detector.tracker.get_pose(&"default")
	if not pose:
		return

	# Get the conversion transform
	var hand := pose_detector.tracker.hand

	# Get the conversion transform
	var conv_xform : Transform3D
	if hand == XRPositionalTracker.TrackerHand.TRACKER_HAND_LEFT:
		conv_xform = _POSE_TRANSFORMS_LEFT[pose_type]
	else:
		conv_xform = _POSE_TRANSFORMS_RIGHT[pose_type]

	# Apply conversion to pose components
	var pose_transform := pose.transform * conv_xform
	var pose_linear := pose.linear_velocity * conv_xform.basis
	var pose_angular := _rotate_angular_velocity(pose.angular_velocity, conv_xform.basis)

	# Update the controller tracker pose
	tracker.hand = hand
	tracker.set_pose(
		pose.name,
		pose_transform,
		pose_linear,
		pose_angular,
		pose.tracking_confidence)


# Customize properties
func _validate_property(property: Dictionary) -> void:
	if property.name == "tracker_name":
		property.hint = PROPERTY_HINT_ENUM_SUGGESTION
		property.hint_string = "/user/hand_pose_controller/left,/user/hand_pose_controller/right"


# Get configuration warnings
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	# Verify tracker name is set
	if tracker_name == "":
		warnings.append("Tracker name not set")

	# Verify parent pose
	var parent_pose_detector := get_parent() as HandPoseDetector
	if not parent_pose_detector:
		warnings.append("Must be child of HandPoseDetector node")

	# Return the warnings
	return warnings


# Handle start of pose
func _pose_started(p_name : String) -> void:
	# Skip if no tracker or action set
	if not tracker or not action_set:
		return

	# Find the action
	var action := action_set.get_action(p_name)
	if not action:
		return

	# Set the input
	if action.action_type == HandPoseAction.ActionType.BOOL:
		tracker.set_input(action.action_name, true)
	else:
		tracker.set_input(action.action_name, 1.0)


# Handle end of pose
func _pose_ended(p_name : String) -> void:
	# Skip if no tracker or action set
	if not tracker or not action_set:
		return

	# Find the action
	var action := action_set.get_action(p_name)
	if not action:
		return

	# Set the input
	if action.action_type == HandPoseAction.ActionType.BOOL:
		tracker.set_input(action.action_name, false)
	else:
		tracker.set_input(action.action_name, 0.0)


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
