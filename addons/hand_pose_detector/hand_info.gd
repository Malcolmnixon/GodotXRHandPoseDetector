@tool
class_name HandInfo


## Hand Information Script
##
## This script provides types and methods to assist in processing tracked
## hand information.


## Enumeration of fingers
enum Finger {
	THUMB = 0,		## Thumb
	INDEX = 1,		## Index Finger
	MIDDLE = 2,		## Middle Finger
	RING = 3,		## Ring Finger
	PINKY = 4		## Pinky Finger
}


## Returns the flexion in degrees of the specified [param finger] on the
## [param hand] tracker.
static func flexion(
		hand : XRHandTracker,
		finger : Finger) -> float:
	# Get the palm and proximal joints
	var palm := hand.get_hand_joint_transform(XRHandTracker.HAND_JOINT_PALM)
	var proximal := get_proximal(hand, finger)

	# Handle special thumb flexion calculation
	if finger == Finger.THUMB:
		# Calculation depends on which hand
		match hand.hand:
			XRPositionalTracker.TRACKER_HAND_LEFT:
				return angle_to(
					proximal.basis.y,
					-palm.basis.x,
					-palm.basis.y)

			XRPositionalTracker.TRACKER_HAND_RIGHT:
				return angle_to(
					proximal.basis.y,
					palm.basis.x,
					palm.basis.y)

			_:
				return 0.0

	# Calculate finger flexion
	return angle_to(
		proximal.basis.y,
		palm.basis.y,
		-palm.basis.x)


## Returns the curl in degrees of the specified [param finger] on the
## [param hand] tracker.
static func curl(
		hand : XRHandTracker,
		finger : Finger) -> float:
	# Get the proximal and distal joints
	var proximal := get_proximal(hand, finger)
	var distal := get_distal(hand, finger)

	# Calculate the curl of the finger
	return angle_to(
		proximal.basis.y,
		distal.basis.y,
		proximal.basis.x)


## Returns the abduction in degrees between [param finger1] and [param finger2]
## on the [param hand] tracker.
static func abduction(
		hand : XRHandTracker,
		finger1 : Finger,
		finger2 : Finger) -> float:
	# Get the finger proximal joints
	var proximal_a := get_proximal(hand, min(finger1, finger2))
	var proximal_b := get_proximal(hand, max(finger1, finger2))

	# Calculate the abduction angle
	match hand.hand:
		XRPositionalTracker.TRACKER_HAND_LEFT:
			return angle_to(
				proximal_a.basis.y,
				proximal_b.basis.y,
				-proximal_a.basis.z - proximal_b.basis.z)

		XRPositionalTracker.TRACKER_HAND_RIGHT:
			return angle_to(
				proximal_a.basis.y,
				proximal_b.basis.y,
				proximal_a.basis.z + proximal_b.basis.z)

		_:
			return 0.0


## Returns the distance in millimeters between [param finger1] tip and
## [param finger2] tip on the [param hand] tracker.
static func tip_distance(
		hand : XRHandTracker,
		finger1 : Finger,
		finger2 : Finger) -> float:
	# Get the finger tips
	var tip_1 := get_tip(hand, finger1)
	var tip_2 := get_tip(hand, finger2)

	# Return the distance
	return tip_1.origin.distance_to(tip_2.origin) * 1000


## Returns the Transform3D of the proximal [param finger] joint from the
## [param hand] tracker.
static func get_proximal(hand : XRHandTracker, finger : Finger) -> Transform3D:
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

## Returns the Transform3D of the distal [param finger] joint from the
## [param hand] tracker.
static func get_distal(hand : XRHandTracker, finger : Finger) -> Transform3D:
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


## Returns the Transform3D of the [param finger] tip from the
## [param hand] tracker.
static func get_tip(hand : XRHandTracker, finger : Finger) -> Transform3D:
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


## Returns the signed angle between [param from] and [param to] in degrees as
## observed from the [param axis] vector.
static func angle_to(from: Vector3, to: Vector3, axis : Vector3) -> float:
	# Ensure the axis is normalized
	axis = axis.normalized()

	# Project and normalize the from and to into the axis plane
	var from2 = from.slide(axis).normalized()
	var to2 = to.slide(axis).normalized()

	# Calculate the angle in degrees
	return rad_to_deg(from2.signed_angle_to(to2, axis))


## Returns the angle between [param from] and [param to] in degrees.
static func angle_between(from: Vector3, to: Vector3) -> float:
	# Ensure the two vectors are normalized
	var from2 = from.normalized()
	var to2 = to.normalized();

	# Calculate the angle in degrees
	return rad_to_deg(from2.angle_to(to2))
