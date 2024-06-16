extends Node3D


func _ready() -> void:
	var xr_interface := XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true


func _on_left_hand_pose_started(p_name: String, p_fitness: float) -> void:
	$LeftHandLabel.text = "Left\n\n%s\n%0.2f" % [p_name, p_fitness]

func _on_left_hand_pose_update(p_name: String, p_fitness: float) -> void:
	$LeftHandLabel.text = "Left\n\n%s\n%0.2f" % [p_name, p_fitness]

func _on_left_hand_pose_ended(_p_name: String) -> void:
	$LeftHandLabel.text = "Left"

func _on_right_hand_pose_started(p_name: String, p_fitness: float) -> void:
	$RightHandLabel.text = "Right\n\n%s\n%0.2f" % [p_name, p_fitness]

func _on_right_hand_pose_update(p_name: String, p_fitness: float) -> void:
	$RightHandLabel.text = "Right\n\n%s\n%0.2f" % [p_name, p_fitness]

func _on_right_hand_pose_ended(_p_name: String) -> void:
	$RightHandLabel.text = "Right"
