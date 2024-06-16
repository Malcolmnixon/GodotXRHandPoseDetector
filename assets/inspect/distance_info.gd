@tool
class_name DistanceInfo
extends Label3D


# Diagnostic Text Template
const _DIAGNOSTIC_TEXT = \
	"Distance (mm)\n\n" + \
	"Thumb/Index: {thb_idx}\n" + \
	"Thumb/Middle: {thb_mid}\n" + \
	"Thumb/Ring: {thb_rng}\n" + \
	"Thumb/Pinky: {thb_pky}"


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

	# Try to find the requested tracker
	if not tracker or tracker.name != tracker_name:
		tracker = XRServer.get_tracker(tracker_name) as XRHandTracker
		if not tracker:
			return

	# Gather the data
	var data := {
		"thb_idx" : int(HandInfo.tip_distance(
			tracker, HandInfo.Finger.THUMB, HandInfo.Finger.INDEX)),
		"thb_mid" : int(HandInfo.tip_distance(
			tracker, HandInfo.Finger.THUMB, HandInfo.Finger.MIDDLE)),
		"thb_rng" : int(HandInfo.tip_distance(
			tracker, HandInfo.Finger.THUMB, HandInfo.Finger.RING)),
		"thb_pky" : int(HandInfo.tip_distance(
			tracker, HandInfo.Finger.THUMB, HandInfo.Finger.PINKY))
	}

	# Format the text
	text = _DIAGNOSTIC_TEXT.format(data)
