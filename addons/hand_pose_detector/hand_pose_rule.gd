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

## Minimum valid angle/position
@export_storage var range_min : float

## Lower angle/position
@export_storage var range_lower : float

## Upper angle/position
@export_storage var range_upper : float

## Maximum valid angle/position
@export_storage var range_max : float


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

	# Add the four range values
	props.append({
		"name" : "Range",
		"type" : TYPE_NIL,
		"usage" : PROPERTY_USAGE_GROUP
	})
	props.append({
		"name" : "range_min",
		"type" : TYPE_FLOAT,
		"usage" : PROPERTY_USAGE_DEFAULT
	})
	props.append({
		"name" : "range_lower",
		"type" : TYPE_FLOAT,
		"usage" : PROPERTY_USAGE_DEFAULT
	})
	props.append({
		"name" : "range_upper",
		"type" : TYPE_FLOAT,
		"usage" : PROPERTY_USAGE_DEFAULT
	})
	props.append({
		"name" : "range_max",
		"type" : TYPE_FLOAT,
		"usage" : PROPERTY_USAGE_DEFAULT
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

	# Convert measurement to fitness over the 5 segments
	if measure < range_min:		# Below Min
		return 0.0
	if measure < range_lower:	# Min to Lower S-curve
		return smoothstep(range_min, range_lower, measure)
	if measure < range_upper:	# Lower to Upper
		return 1.0
	if measure < range_max:		# Upper to Max S-curve
		return smoothstep(range_max, range_upper, measure)
	return 0.0					# Above Max


## Returns configuration warnings associated with this rule.
func get_warnings() -> Array[String]:
	var warnings : Array[String] = []

	if rule == RuleType.ABDUCTION and finger == other_finger:
		warnings.append("Abduction must specify different fingers")
	if rule == RuleType.TIP_DISTANCE and finger == other_finger:
		warnings.append("Tip-Distance must specify different fingers")
	if range_min > range_lower:
		warnings.append("Range order error: range_min > range_lower")
	if range_lower > range_upper:
		warnings.append("Range order error: range_lower > range_upper")
	if range_upper > range_max:
		warnings.append("Range order error: range_upper > range_max")
	if range_min == range_max:
		warnings.append("Zero range specified")
	return warnings


# Trigger updating property list on rule change
func _set_rule(p_rule : RuleType) -> void:
	rule = p_rule
	notify_property_list_changed()
