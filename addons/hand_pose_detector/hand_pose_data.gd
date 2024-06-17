@tool
class_name HandPoseData
extends RefCounted


## Hand Pose Data Object
##
## This object contains hand pose data converted from a raw XRHandTracker
## into a form more suitable for hand-pose analysis.


## Enumeration of fingers
enum Finger {
	THUMB = 0,		## Thumb
	INDEX = 1,		## Index Finger
	MIDDLE = 2,		## Middle Finger
	RING = 3,		## Ring Finger
	PINKY = 4		## Pinky Finger
}


# Hand pose measurements
var flx_thumb  := 0.0		## Flexion of thumb
var flx_index  := 0.0		## Flexion of index finger
var flx_middle := 0.0		## Flexion of middle finger
var flx_ring   := 0.0		## Flexion of ring finger
var flx_pinky  := 0.0		## Flexion of pinky finger
var crl_thumb  := 0.0		## Curl of thumb
var crl_index  := 0.0		## Curl of index finger
var crl_middle := 0.0		## Curl of middle finger
var crl_ring   := 0.0		## Curl of ring finger
var crl_pinky  := 0.0		## Curl of pinky finger
var abd_thumb  := 0.0		## Abduction from thumb to index finger
var abd_index  := 0.0		## Abduction from index to middle fingers
var abd_middle := 0.0		## Abduction from middle to ring fingers
var abd_ring   := 0.0		## Abduction from ring to pinky fingers
var dst_index  := 0.0		## Distance from thumb to index finger tips
var dst_middle := 0.0		## Distance from thumb to middle finger tips
var dst_ring   := 0.0		## Distance from thumb to ring finger tips
var dst_pinky  := 0.0		## Distance from thumb to pinky finger tips


## Update the hand pose data from an XRHandTracker
func update(hand : XRHandTracker) -> void:
	flx_thumb  = _flexion(hand, Finger.THUMB)
	flx_index  = _flexion(hand, Finger.INDEX)
	flx_middle = _flexion(hand, Finger.MIDDLE)
	flx_ring   = _flexion(hand, Finger.RING)
	flx_pinky  = _flexion(hand, Finger.PINKY)
	crl_thumb  = _curl(hand, Finger.THUMB)
	crl_index  = _curl(hand, Finger.INDEX)
	crl_middle = _curl(hand, Finger.MIDDLE)
	crl_ring   = _curl(hand, Finger.RING)
	crl_pinky  = _curl(hand, Finger.PINKY)
	abd_thumb  = _abduction(hand, Finger.THUMB, Finger.INDEX)
	abd_index  = _abduction(hand, Finger.INDEX, Finger.MIDDLE)
	abd_middle = _abduction(hand, Finger.MIDDLE, Finger.RING)
	abd_ring   = _abduction(hand, Finger.RING, Finger.PINKY)
	dst_index  = _tip_distance(hand, Finger.THUMB, Finger.INDEX)
	dst_middle = _tip_distance(hand, Finger.THUMB, Finger.MIDDLE)
	dst_ring   = _tip_distance(hand, Finger.THUMB, Finger.RING)
	dst_pinky  = _tip_distance(hand, Finger.THUMB, Finger.PINKY)


# Returns the flexion in degrees of the specified [param finger] on the
# [param hand] tracker.
static func _flexion(
		hand : XRHandTracker,
		finger : Finger) -> float:
	# Get the palm and proximal joints
	var palm := hand.get_hand_joint_transform(XRHandTracker.HAND_JOINT_PALM)
	var proximal := _get_proximal(hand, finger)

	# Handle special thumb flexion calculation
	if finger == Finger.THUMB:
		# Calculation depends on which hand
		match hand.hand:
			XRPositionalTracker.TRACKER_HAND_LEFT:
				return _angle_to(
					proximal.basis.y,
					-palm.basis.x,
					-palm.basis.y)

			XRPositionalTracker.TRACKER_HAND_RIGHT:
				return _angle_to(
					proximal.basis.y,
					palm.basis.x,
					palm.basis.y)

			_:
				return 0.0

	# Calculate finger flexion
	return _angle_to(
		proximal.basis.y,
		palm.basis.y,
		-palm.basis.x)


# Returns the curl in degrees of the specified [param finger] on the
# [param hand] tracker.
static func _curl(
		hand : XRHandTracker,
		finger : Finger) -> float:
	# Get the proximal and distal joints
	var proximal := _get_proximal(hand, finger)
	var distal := _get_distal(hand, finger)

	# Calculate the curl of the finger
	return _angle_to(
		proximal.basis.y,
		distal.basis.y,
		proximal.basis.x)


# Returns the abduction in degrees between [param finger1] and [param finger2]
# on the [param hand] tracker.
static func _abduction(
		hand : XRHandTracker,
		finger1 : Finger,
		finger2 : Finger) -> float:
	# Get the finger proximal joints
	var proximal_a := _get_proximal(hand, min(finger1, finger2))
	var proximal_b := _get_proximal(hand, max(finger1, finger2))

	# Calculate the abduction angle
	match hand.hand:
		XRPositionalTracker.TRACKER_HAND_LEFT:
			return _angle_to(
				proximal_a.basis.y,
				proximal_b.basis.y,
				-proximal_a.basis.z - proximal_b.basis.z)

		XRPositionalTracker.TRACKER_HAND_RIGHT:
			return _angle_to(
				proximal_a.basis.y,
				proximal_b.basis.y,
				proximal_a.basis.z + proximal_b.basis.z)

		_:
			return 0.0


# Returns the distance in millimeters between [param finger1] tip and
# [param finger2] tip on the [param hand] tracker.
static func _tip_distance(
		hand : XRHandTracker,
		finger1 : Finger,
		finger2 : Finger) -> float:
	# Get the finger tips
	var tip_1 := _get_tip(hand, finger1)
	var tip_2 := _get_tip(hand, finger2)

	# Return the distance
	return tip_1.origin.distance_to(tip_2.origin) * 1000


# Returns the Transform3D of the proximal [param finger] joint from the
# [param hand] tracker.
static func _get_proximal(hand : XRHandTracker, finger : Finger) -> Transform3D:
	# Get the proximal joint
	var joint : XRHandTracker.HandJoint
	match finger:
		Finger.THUMB: joint = XRHandTracker.HAND_JOINT_THUMB_PHALANX_PROXIMAL
		Finger.INDEX: joint = XRHandTracker.HAND_JOINT_INDEX_FINGER_PHALANX_PROXIMAL
		Finger.MIDDLE: joint = XRHandTracker.HAND_JOINT_MIDDLE_FINGER_PHALANX_PROXIMAL
		Finger.RING: joint = XRHandTracker.HAND_JOINT_RING_FINGER_PHALANX_PROXIMAL
		Finger.PINKY: joint = XRHandTracker.HAND_JOINT_PINKY_FINGER_PHALANX_PROXIMAL

	# Return the transform
	return hand.get_hand_joint_transform(joint)


# Returns the Transform3D of the distal [param finger] joint from the
# [param hand] tracker.
static func _get_distal(hand : XRHandTracker, finger : Finger) -> Transform3D:
	# Get the distal joint
	var joint : XRHandTracker.HandJoint
	match finger:
		Finger.THUMB: joint = XRHandTracker.HAND_JOINT_THUMB_PHALANX_DISTAL
		Finger.INDEX: joint = XRHandTracker.HAND_JOINT_INDEX_FINGER_PHALANX_DISTAL
		Finger.MIDDLE: joint = XRHandTracker.HAND_JOINT_MIDDLE_FINGER_PHALANX_DISTAL
		Finger.RING: joint = XRHandTracker.HAND_JOINT_RING_FINGER_PHALANX_DISTAL
		Finger.PINKY: joint = XRHandTracker.HAND_JOINT_PINKY_FINGER_PHALANX_DISTAL

	# Return the transform
	return hand.get_hand_joint_transform(joint)


# Returns the Transform3D of the [param finger] tip from the
# [param hand] tracker.
static func _get_tip(hand : XRHandTracker, finger : Finger) -> Transform3D:
	# Get the tip joint
	var joint : XRHandTracker.HandJoint
	match finger:
		Finger.THUMB: joint = XRHandTracker.HAND_JOINT_THUMB_TIP
		Finger.INDEX: joint = XRHandTracker.HAND_JOINT_INDEX_FINGER_TIP
		Finger.MIDDLE: joint = XRHandTracker.HAND_JOINT_MIDDLE_FINGER_TIP
		Finger.RING: joint = XRHandTracker.HAND_JOINT_RING_FINGER_TIP
		Finger.PINKY: joint = XRHandTracker.HAND_JOINT_PINKY_FINGER_TIP

	# Return the transform
	return hand.get_hand_joint_transform(joint)


# Returns the signed angle between [param from] and [param to] in degrees as
# observed from the [param axis] vector.
static func _angle_to(from: Vector3, to: Vector3, axis : Vector3) -> float:
	# Ensure the axis is normalized
	axis = axis.normalized()

	# Project and normalize the from and to into the axis plane
	var from2 = from.slide(axis).normalized()
	var to2 = to.slide(axis).normalized()

	# Calculate the angle in degrees
	return rad_to_deg(from2.signed_angle_to(to2, axis))
