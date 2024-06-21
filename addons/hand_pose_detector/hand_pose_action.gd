class_name HandPoseAction
extends Resource


## Hand Pose Action Resource
##
## This resource type is used to associate a detected hand pose with an XR
## Input Action to trigger on an XRControllerTracker - and through it an
## XRController3D node.


## Action type
enum ActionType {
	BOOL,		## Boolean action [true/false]
	FLOAT		## Float action [0.0 - 1.0]
}


## Hand Pose to trigger action
@export var pose : HandPose

## Type of input action
@export var action_type : ActionType

## Name of input action
@export var action_name : String
