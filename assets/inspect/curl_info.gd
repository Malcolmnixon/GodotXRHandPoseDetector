@tool
class_name CurlInfo
extends Label3D


# Diagnostic Text Template
const _DIAGNOSTIC_TEXT = \
	"Curl (deg)\n\n" + \
	"Thumb: {thb}\n" + \
	"Index: {idx}\n" + \
	"Middle: {mid}\n" + \
	"Ring: {rng}\n" + \
	"Pinky: {pky}"


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
		"thb" : int(HandInfo.curl(tracker, HandInfo.Finger.THUMB)),
		"idx" : int(HandInfo.curl(tracker, HandInfo.Finger.INDEX)),
		"mid" : int(HandInfo.curl(tracker, HandInfo.Finger.MIDDLE)),
		"rng" : int(HandInfo.curl(tracker, HandInfo.Finger.RING)),
		"pky" : int(HandInfo.curl(tracker, HandInfo.Finger.PINKY)),
	}

	# Format the text
	text = _DIAGNOSTIC_TEXT.format(data)
