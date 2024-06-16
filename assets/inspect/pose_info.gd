@tool
class_name PoseInfo
extends Label3D


## Hand pose to diagnose
@export var pose : HandPose 

## Name of the hand pose tracker
@export var tracker_name : String = "/user/hand_tracker/left"

# Hand tracker instance
var tracker : XRHandTracker


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

	# Skip if no pose to diagnose
	if not pose:
		return

	# Try to find the requested tracker
	if not tracker or tracker.name != tracker_name:
		tracker = XRServer.get_tracker(tracker_name) as XRHandTracker
		if not tracker:
			return

	# Construct the text data
	var text_data := "%s - %0.2f\n\n" % [pose.pose_name, pose.get_fitness(tracker)]
	for r in pose.rules:
		text_data += "%s: %0.2f\n" % [r.name, r.get_fitness(tracker)]

	# Update the text
	text = text_data
