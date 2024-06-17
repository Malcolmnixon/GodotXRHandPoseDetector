@tool
class_name HandPoseRule
extends Resource


## Hand Pose Rule Resource
##
## This resource defines a rule for hand pose matching. A hand pose is
## defined as a set of hand pose rules.


## Pose Rule Type
enum RuleType {
	FLEXION,		## Finger Flexion (in degrees)
	CURL,			## Finger Curl (in degrees)
	ABDUCTION,		## Finger Abduction (in degrees)
	TIP_DISTANCE	## Finger Distance (in millimeters)
}


@export_group("Rule")

## Rule name
@export var name : String

## Hand Pose Rule
@export var rule : RuleType : set = _set_rule

## Hand Pose Finger
@export var finger : HandInfo.Finger

## Hand Pose Other Finger (for abduction / tip-distance)
@export_storage var other_finger : HandInfo.Finger

## Fitness Function
@export var function : FitnessFunction = FitnessFunction.new()


# Customize the property lists
func _get_property_list() -> Array[Dictionary]:
	# Construct the properties
	var props : Array[Dictionary] = []

	# Add other finger if required by the rule
	if rule == RuleType.ABDUCTION or rule == RuleType.TIP_DISTANCE:
		props.append({
			"name" : "other_finger",
			"type" : TYPE_INT,
			"usage" : PROPERTY_USAGE_DEFAULT,
			"hint" : PROPERTY_HINT_ENUM,
			"hint_string" : "Thumb,Index,Middle,Ring,Pinky"
		})

	# Return the properties
	return props


## Returns a fitness value in the range 0..1 as to how well the [param hand]
## matches the hand pose rule. A value of 0 indicates the rule is being
## violated, and a value of 1 indicates the rule is being followed perfectly.
func get_fitness(hand : XRHandTracker) -> float:
	# Get the measurement
	var measure : float
	match rule:
		RuleType.FLEXION:
			measure = HandInfo.flexion(hand, finger)
		RuleType.CURL:
			measure = HandInfo.curl(hand, finger)
		RuleType.ABDUCTION:
			measure = HandInfo.abduction(hand, finger, other_finger)
		RuleType.TIP_DISTANCE:
			measure = HandInfo.tip_distance(hand, finger, other_finger)
		_:
			return 0

	return function.calculate(measure)


## Returns configuration warnings associated with this rule.
func get_warnings() -> Array[String]:
	# Create the warnings array
	var warnings : Array[String] = []

	# Add warnings for the rule
	if rule == RuleType.ABDUCTION and finger == other_finger:
		warnings.append("Abduction must specify different fingers")
	if rule == RuleType.TIP_DISTANCE and finger == other_finger:
		warnings.append("Tip-Distance must specify different fingers")
	warnings.append_array(function.get_warnings())

	# Return the warnings
	return warnings


# Trigger updating property list on rule change
func _set_rule(p_rule : RuleType) -> void:
	rule = p_rule
	notify_property_list_changed()
