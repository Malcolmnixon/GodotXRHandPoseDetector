class_name HandPoseActionMap
extends Resource


## Hand Pose Action Map Resource
##
## This resource defines a map of HandPoseAction used to associate hand poses
## with XR Input Actions.


## Array of hand pose actions
@export var actions : Array[HandPoseAction] = []


## Returns the associated HandPoseAction
func get_action(p_name : String) -> HandPoseAction:
	# Look for a matching action
	for a in actions:
		if a.pose.pose_name == p_name:
			return a

	# No action found
	return null
