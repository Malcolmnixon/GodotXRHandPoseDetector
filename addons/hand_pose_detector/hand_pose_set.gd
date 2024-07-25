@tool
class_name HandPoseSet
extends Resource


## Hand Pose Set Resource
##
## This resource defines a set of hand poses. The hand pose detector takes
## a pose set and searches for poses within the set.


## Array of hand poses
@export var poses : Array[HandPose] = []


## Returns the best pose for the specified [param hand].
func find_pose(hand : HandPoseData) -> HandPose:
	# Search for the best pose
	var best_pose : HandPose = null
	var best_fitness : float = 0.0
	for p in poses:
		var f := p.get_fitness(hand)
		if f > best_fitness:
			best_pose = p
			best_fitness = f

	# Return the best pose
	return best_pose
