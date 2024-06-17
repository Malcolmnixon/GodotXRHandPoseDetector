@tool
class_name AbductionInfo
extends Label3D


# Diagnostic Text Template
const _DIAGNOSTIC_TEXT = \
	"Abduction (deg)\n\n" + \
	"Thumb/Index: {thb_idx}\n" + \
	"Index/Middle: {idx_mid}\n" + \
	"Middle/Ring: {mid_rng}\n" + \
	"Ring/Pinky: {rng_pky}"


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
		"thb_idx" : int(HandInfo.abduction(tracker, HandInfo.Finger.THUMB, HandInfo.Finger.INDEX)),
		"idx_mid" : int(HandInfo.abduction(tracker, HandInfo.Finger.INDEX, HandInfo.Finger.MIDDLE)),
		"mid_rng" : int(HandInfo.abduction(tracker, HandInfo.Finger.MIDDLE, HandInfo.Finger.RING)),
		"rng_pky" : int(HandInfo.abduction(tracker, HandInfo.Finger.RING, HandInfo.Finger.PINKY))
	}

	# Format the text
	text = _DIAGNOSTIC_TEXT.format(data)
