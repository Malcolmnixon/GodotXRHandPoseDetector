@tool
class_name HandPose
extends Resource


## Hand Pose Resource
##
## This resource defines a hand pose. It consists of the pose name, and a
## collection of rules defining the pose.


## Hand pose name
@export var pose_name : String

## Detection threshold
@export_range(0.0, 1.0) var threshold : float = 0.5

## Array of hand pose rules
@export var rules : Array[HandPoseRule] = []

## Rules validated
var _validated := false


## Returns a fitness value in the range 0..1 as to how well the [param hand]
## matches the hand pose rules.
func get_fitness(hand : XRHandTracker) -> float:
	# Fail if no rules
	if rules.size() == 0:
		return 0

	# Perform rule validation on first use
	if not _validated:
		_validated = true
		if pose_name == "":
			push_warning("Hand Pose: %s name not specified" % resource_path);
		if threshold <= 0.0:
			push_warning("Hand Pose: %s invalid threshold" % pose_name)
		for r in rules:
			var warnings = r.get_warnings()
			if warnings.size() > 0:
				push_warning("Hand Pose: %s rule issues" % pose_name)
				for w in warnings.size():
					push_warning("  Rule %d: %s" % [w, warnings[w]])

	# Process the fitness of all rules
	var fitness := 1.0
	for r in rules:
		fitness *= r.get_fitness(hand)

	# If the fitness is below the threshold then fail
	if fitness < threshold:
		return 0.0

	# Return the total fitness
	return fitness
