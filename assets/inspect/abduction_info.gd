@tool
class_name AbductionInfo
extends Label3D


# Diagnostic Text Template
const _DIAGNOSTIC_TEXT = \
	"Abduction (deg)\n\n" + \
	"Thumb/Index: {abd_thumb}\n" + \
	"Index/Middle: {abd_index}\n" + \
	"Middle/Ring: {abd_middle}\n" + \
	"Ring/Pinky: {abd_ring}"


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
	var data := HandPoseData.new()
	data.update(tracker)
	var text_data := {
		"abd_thumb"  : int(data.abd_thumb),
		"abd_index"  : int(data.abd_index),
		"abd_middle" : int(data.abd_middle),
		"abd_ring"   : int(data.abd_ring)
	}

	# Format the text
	text = _DIAGNOSTIC_TEXT.format(text_data)
