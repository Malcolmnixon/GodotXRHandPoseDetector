@tool
class_name HandPoseDetector
extends Node


## Hand Pose Detector Script
##
## This script checks for hand poses and reports them as events.


## Signal reported when a hand pose starts
signal pose_started(p_name : String, p_fitness : float)

## Signal reported while a hand pose is in effect
signal pose_update(p_name : String, p_fitness : float)

## Signal reported when a hand pose ends
signal pose_ended(p_name : String)


## Current hand pose set
@export var hand_pose_set : HandPoseSet

## Name of the hand pose tracker
@export var tracker_name : String = "/user/hand_tracker/left"

# Current hand tracker
var tracker : XRHandTracker

# Current hand pose
var _current_pose : String = ""


# Customize the properties
func _validate_property(property: Dictionary) -> void:
	if property.name == "tracker_name":
		property.hint = PROPERTY_HINT_ENUM_SUGGESTION
		property.hint_string = "/user/hand_tracker/left,/user/hand_tracker/right"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Skip when running in the engine
	if Engine.is_editor_hint():
		return

	# Skip if no hand pose set
	if not hand_pose_set:
		return

	# Try to find the requested tracker
	if not tracker or tracker.name != tracker_name:
		tracker = XRServer.get_tracker(tracker_name) as XRHandTracker
		if not tracker:
			return

	# Find the pose
	var pose_match := hand_pose_set.find_pose(tracker)
	var pose : String = pose_match.pose
	var fitness : float = pose_match.fitness

	# Handle pose changing
	if pose != _current_pose:
		# Report end of the current pose
		if _current_pose != "":
			pose_ended.emit(_current_pose)

		# Report start of the new pose
		if pose != "":
			pose_started.emit(pose, fitness)

		# Save the updated pose
		_current_pose = pose
	elif _current_pose != "":
		# Report update of existing pose
		pose_update.emit(_current_pose, fitness)
