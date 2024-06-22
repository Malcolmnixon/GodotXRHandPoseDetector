@tool
class_name HandPoseDetector
extends Node


## Hand Pose Detector Script
##
## This script checks for hand poses and reports them as events.


## Signal reported when a hand pose starts
signal pose_started(p_name : String)

## Signal reported when a hand pose ends
signal pose_ended(p_name : String)


## Current hand pose set
@export var hand_pose_set : HandPoseSet

## Name of the hand pose tracker
@export var tracker_name : String = "/user/hand_tracker/left"

## Current hand tracker
var tracker : XRHandTracker

# Current hand pose data
var _current_data : HandPoseData = HandPoseData.new()

# Current hand pose
var _current_pose : HandPose

# Current pose hold
var _current_hold : float = 0.0

# New hand pose
var _new_pose : HandPose

# New pose hold
var _new_hold : float = 0.0


# Customize the properties
func _validate_property(property: Dictionary) -> void:
	if property.name == "tracker_name":
		property.hint = PROPERTY_HINT_ENUM_SUGGESTION
		property.hint_string = "/user/hand_tracker/left,/user/hand_tracker/right"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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

	# Save the active pose before updates (to report changes)
	var active_pos := _current_pose

	# Find the pose
	_current_data.update(tracker)
	var pose_match := hand_pose_set.find_pose(_current_data)
	var pose : HandPose = pose_match.pose
	var fitness : float = pose_match.fitness

	# Manage current pose
	if _current_pose:
		# Test if we detect the current pose
		if pose == _current_pose:
			# Restore hold on current pose
			_current_hold = 1.0
		else:
			# Decay hold on current pose
			_current_hold -= delta / _current_pose.release_time
			if _current_hold <= 0.0:
				# Current pose lost
				_current_hold = 0.0
				_current_pose = null

	# Handle ramp of new pose
	if pose != _new_pose:
		# New pose detected
		_new_pose = pose
		_new_hold = 0.0
	elif _new_pose:
		# Ramp hold on new pose
		_new_hold += delta / _new_pose.hold_time
		if _new_hold >= 1.0:
			# New pose "ready"
			_new_hold = 1.0
			if not _current_pose:
				# No current pose, transition to new pose
				_current_pose = _new_pose
				_current_hold = 1.0

	# Detect change in active pose
	if _current_pose != active_pos:
		# Report loss of old pose
		if active_pos:
			pose_ended.emit(active_pos.pose_name)

		# Report start of new pose
		active_pos = _current_pose
		if active_pos:
			pose_started.emit(active_pos.pose_name)
