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

## Hold time before pose is detected
@export_range(0.01, 1.0) var hold_time : float = 0.2

## Release time before pose is lost
@export_range(0.01, 1.0) var release_time : float = 0.2

# Flexion group
@export_group("Flexion", "flexion_")

## Flexion Thumb Function
@export var flexion_thumb : FitnessFunction

## Flexion Index Function
@export var flexion_index : FitnessFunction

## Flexion Middle Function
@export var flexion_middle : FitnessFunction

## Flexion Ring Function
@export var flexion_ring : FitnessFunction

## Flexion Pinky Function
@export var flexion_pinky : FitnessFunction

# Curl group
@export_group("Curl", "curl_")

## Curl Thumb Function
@export var curl_thumb : FitnessFunction

## Curl Index Function
@export var curl_index : FitnessFunction

## Curl Middle Function
@export var curl_middle : FitnessFunction

## Curl Ring Function
@export var curl_ring : FitnessFunction

## Curl Pinky Function
@export var curl_pinky : FitnessFunction

# Abduction group
@export_group("Abduction", "abduction_")

## Abduction Thumb-Index Function
@export var abduction_thumb_index : FitnessFunction

## Abduction Index-Middle Function
@export var abduction_index_middle : FitnessFunction

## Abduction Middle-Ring Function
@export var abduction_middle_ring : FitnessFunction

## Abduction Ring-Pinky Function
@export var abduction_ring_pinky : FitnessFunction

# Tip-distance group
@export_group("Tip-Distance", "distance_")

## Tip-Distance Thumb-Index Function
@export var distance_thumb_index : FitnessFunction

## Tip-Distance Thumb-Middle Function
@export var distance_thumb_middle : FitnessFunction

## Tip-Distance Thumb-Ring Function
@export var distance_thumb_ring : FitnessFunction

## Tip-Distance Thumb-Pinky Function
@export var distance_thumb_pinky : FitnessFunction


## Returns a fitness value in the range 0..1 as to how well the [param hand]
## matches the hand pose rules.
func get_fitness(hand : HandPoseData) -> float:
	# Process the fitness of all rules
	var fitness := 1.0

	# Apply flexion rules
	if flexion_thumb:  fitness *= flexion_thumb.calculate(hand.flx_thumb)
	if flexion_index:  fitness *= flexion_index.calculate(hand.flx_index)
	if flexion_middle: fitness *= flexion_middle.calculate(hand.flx_middle)
	if flexion_ring:   fitness *= flexion_ring.calculate(hand.flx_ring)
	if flexion_pinky:  fitness *= flexion_pinky.calculate(hand.flx_pinky)

	# Apply curl rules
	if curl_thumb:  fitness *= curl_thumb.calculate(hand.crl_thumb)
	if curl_index:  fitness *= curl_index.calculate(hand.crl_index)
	if curl_middle: fitness *= curl_middle.calculate(hand.crl_middle)
	if curl_ring:   fitness *= curl_ring.calculate(hand.crl_ring)
	if curl_pinky:  fitness *= curl_pinky.calculate(hand.crl_pinky)

	# Apply abduction rules
	if abduction_thumb_index:  fitness *= abduction_thumb_index.calculate(hand.abd_thumb)
	if abduction_index_middle: fitness *= abduction_index_middle.calculate(hand.abd_index)
	if abduction_middle_ring:  fitness *= abduction_middle_ring.calculate(hand.abd_middle)
	if abduction_ring_pinky:   fitness *= abduction_ring_pinky.calculate(hand.abd_ring)

	# Apply tip-distance rules
	if distance_thumb_index:  fitness *= distance_thumb_index.calculate(hand.dst_index)
	if distance_thumb_middle: fitness *= distance_thumb_middle.calculate(hand.dst_middle)
	if distance_thumb_ring:   fitness *= distance_thumb_ring.calculate(hand.dst_ring)
	if distance_thumb_pinky:  fitness *= distance_thumb_pinky.calculate(hand.dst_pinky)

	# If the fitness is below the threshold then fail
	if fitness < threshold:
		return 0.0

	# Return the total fitness
	return fitness
