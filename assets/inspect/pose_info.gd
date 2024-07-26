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
	var data := HandPoseData.new()
	data.update(tracker)
	var text_data := "%s - %0.2f\n\n" % [pose.pose_name, pose.get_fitness(data)]
	if pose.flexion_thumb:
		text_data += "Flexion Thumb: %0.2f\n" % pose.flexion_thumb.calculate(data.flx_thumb)
	if pose.flexion_index:
		text_data += "Flexion Index: %0.2f\n" % pose.flexion_index.calculate(data.flx_index)
	if pose.flexion_middle:
		text_data += "Flexion Middle: %0.2f\n" % pose.flexion_middle.calculate(data.flx_middle)
	if pose.flexion_ring:
		text_data += "Flexion Ring: %0.2f\n" % pose.flexion_ring.calculate(data.flx_ring)
	if pose.flexion_pinky:
		text_data += "Flexion Pinky: %0.2f\n" % pose.flexion_pinky.calculate(data.flx_pinky)
	if pose.curl_thumb:
		text_data += "Curl Thumb: %0.2f\n" % pose.curl_thumb.calculate(data.crl_thumb)
	if pose.curl_index:
		text_data += "Curl Index: %0.2f\n" % pose.curl_index.calculate(data.crl_index)
	if pose.curl_middle:
		text_data += "Curl Middle: %0.2f\n" % pose.curl_middle.calculate(data.crl_middle)
	if pose.curl_ring:
		text_data += "Curl Ring: %0.2f\n" % pose.curl_ring.calculate(data.crl_ring)
	if pose.curl_pinky:
		text_data += "Curl Pinky: %0.2f\n" % pose.curl_pinky.calculate(data.crl_pinky)
	if pose.abduction_thumb_index:
		text_data += "Abduction Thumb Index: %0.2f\n" % pose.abduction_thumb_index.calculate(data.abd_thumb)
	if pose.abduction_index_middle:
		text_data += "Abduction Index Middle: %0.2f\n" % pose.abduction_index_middle.calculate(data.abd_index)
	if pose.abduction_middle_ring:
		text_data += "Abduction Middle Ring: %0.2f\n" % pose.abduction_middle_ring.calculate(data.abd_middle)
	if pose.abduction_ring_pinky:
		text_data += "Abduction Ring Pinky: %0.2f\n" % pose.abduction_ring_pinky.calculate(data.abd_ring)
	if pose.distance_thumb_index:
		text_data += "Distance Thumb Index: %0.2f\n" % pose.distance_thumb_index.calculate(data.dst_index)
	if pose.distance_thumb_middle:
		text_data += "Distance Thumb Middle: %0.2f\n" % pose.distance_thumb_middle.calculate(data.dst_middle)
	if pose.distance_thumb_ring:
		text_data += "Distance Thumb Ring: %0.2f\n" % pose.distance_thumb_ring.calculate(data.dst_ring)
	if pose.distance_thumb_pinky:
		text_data += "Distance Thumb Pinky: %0.2f\n" % pose.distance_thumb_pinky.calculate(data.dst_pinky)

	# Update the text
	text = text_data
