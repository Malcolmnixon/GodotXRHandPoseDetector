@tool
class_name FitnessFunction
extends Resource


## Fitness Function Resource
##
## This resource defines a fitness function which returns values in the range
## 0..1 in response to an input measurement.


## Function Type enumeration
enum Type {
	SMOOTHSTEP,		## Smoothstep response
	RANGE			## Range response
}


## Function Type
@export var type : Type = Type.SMOOTHSTEP : set = _set_type

## Min parameter
@export var min : float

## From parameter
@export var from : float

## To parameter
@export var to : float

## Max parameter
@export var max : float


# Update visibility of parameters based on function type
func _validate_property(property: Dictionary) -> void:
	match type:
		Type.SMOOTHSTEP:
			# Update controls for smoothstep
			match property.name:
				"min", "max":
					property.usage = PROPERTY_USAGE_NO_EDITOR

		Type.RANGE:
			# Nothing to hide
			pass

		_:
			# Unknown function
			match property.name:
				"min", "from", "to", "max":
					property.usage = PROPERTY_USAGE_NO_EDITOR


# Calculate the fitness function
func calculate(input : float) -> float:
	match type:
		Type.SMOOTHSTEP:
			# Handle smoothstep
			return smoothstep(from, to, input)

		Type.RANGE:
			# Handle range function
			return _calculate_range(input)

		_:
			# Unknown
			return 0.0


## Returns configuration warnings associated with this function.
func get_warnings() -> Array[String]:
	# Create the warnings array
	var warnings : Array[String] = []

	# Add warnings for the two types of functions
	match type:
		Type.SMOOTHSTEP:
			# Check smoothstep parameters
			if from == to:
				warnings.append("Smoothstep Function: from == to")

		Type.RANGE:
			# Check range parameters
			if min >= from:
				warnings.append("Range Function: min >= from")
			if from >= to:
				warnings.append("Range Function: from >= to")
			if to >= max:
				warnings.append("Range Function: to >= max")

		_:
			# Unknown function
			warnings.append("Unknown Function Type")

	# Return the warnings
	return warnings


# Calculate the range function response
func _calculate_range(input : float) -> float:
	# Process based on input
	if input < min:
		return 0.0
	if input < from:
		return smoothstep(min, from, input)
	if input < to:
		return 1.0
	if input < max:
		return smoothstep(max, to, input)
	return 0.0


# Update property visibility when function type changes
func _set_type(p_type : Type) -> void:
	type = p_type
	notify_property_list_changed()
