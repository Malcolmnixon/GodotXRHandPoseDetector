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
func find_pose(hand : XRHandTracker) -> Dictionary:
	# Search for the best pose
	var best_pose := ""
	var best_fitness := 0.0
	for p in poses:
		var f := p.get_fitness(hand)
		if f > best_fitness:
			best_fitness = f
			best_pose = p.pose_name

	# Return the best pose
	return {
		&"pose" : best_pose,
		&"fitness" : best_fitness
	}
