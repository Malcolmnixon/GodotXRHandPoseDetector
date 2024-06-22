@tool
class_name HandPoseController
extends Node


## Hand Pose Controller Node
##
## This script creates an XRControllerTracker moved by an associated
## HandPoseDetector, and capable of generating XR Input Actions in response
## to detected hand poses.


## Name for the virtual controller tracker
@export var tracker_name : String = "/user/hand_pose_controller/left"

## Pose name
@export var pose_name : String = &"default"

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

	# Get the tracker pose
	var pose := pose_detector.tracker.get_pose(pose_name)
	if not pose:
		return

	# Update the controller tracker pose
	tracker.set_pose(
		pose.name,
		pose.transform,
		pose.linear_velocity,
		pose.angular_velocity,
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

	# Verify pose name is set
	if pose_name == "":
		warnings.append("Pose name not set")

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
