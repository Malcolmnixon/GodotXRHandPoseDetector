@tool
class_name FlexInfo
extends Label3D


# Diagnostic Text Template
const _DIAGNOSTIC_TEXT = \
	"Flex (deg)\n\n" + \
	"Thumb: {flx_thumb}\n" + \
	"Index: {flx_index}\n" + \
	"Middle: {flx_middle}\n" + \
	"Ring: {flx_ring}\n" + \
	"Pinky: {flx_pinky}"


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
		"flx_thumb" : int(data.flx_thumb),
		"flx_index" : int(data.flx_index),
		"flx_middle" : int(data.flx_middle),
		"flx_ring" : int(data.flx_ring),
		"flx_pinky" : int(data.flx_pinky),
	}

	# Format the text
	text = _DIAGNOSTIC_TEXT.format(text_data)
