# Godot XR Hand Pose Detector

![GitHub forks](https://img.shields.io/github/forks/Malcolmnixon/GodotXRHandPoseDetector?style=plastic)
![GitHub Repo stars](https://img.shields.io/github/stars/Malcolmnixon/GodotXRHandPoseDetector?style=plastic)
![GitHub contributors](https://img.shields.io/github/contributors/Malcolmnixon/GodotXRHandPoseDetector?style=plastic)
![GitHub](https://img.shields.io/github/license/Malcolmnixon/GodotXRHandPoseDetector?style=plastic)

This repository contains a hand pose detector for Godot that detects poses on XRHandTracker sources.
![Demo Screen Shot](/docs/demo_screen_shot.png)


## Versions

Official releases are tagged and can be found [here](https://github.com/Malcolmnixon/GodotXRAxisStudioTracker/releases).

The following branches are in active development:
|  Branch   |  Description                  |  Godot version   |
|-----------|-------------------------------|------------------|
|  master   | Current development branch    |  Godot 4.3-beta1+ |


## Overview

Godot [XRHandTracker](https://docs.godotengine.org/en/latest/classes/class_xrhandtracker.html) data is generated by some XR systems such as OpenXR. This project contains assets capable of detecting standard and user-defined hand poses and firing signals when the user poses their hands in those configurations.


## Usage

The following steps show how to add the Godot XR Hand Pose Detector to a project.


### XR Hand Tracking Project

Ensure the existing project is configured with XR hand tracking. The demo project and main scene shows how to do this for OpenXR.

![OpenXR Hand Tracking Scene](/docs/basic_hand_tracking_scene.png)


### Install Addon

The addon files need to be copied to the `/addons/hand_pose_detector` folder of the Godot project.


### Add Hand Pose Detectors

Add Hand Pose Detector nodes into the scene - one for each hand.

![Add Hand Pose Detectors](/docs/add_hand_pose_detectors.png)

Configure the hand pose detectors with the pose-set to detect, and the hand tracker to monitor.

![Hand Pose Detector Settings](/docs/hand_pose_detector_settings.png)

Connect the hand pose detector signals as desired.

![Hand Pose Detector Signals](/docs/hand_pose_detector_signals.png)


## Custom Hand Poses

This section describes the process of creatnig custom hand poses. Additionally the [Creating Custom Hand Poses](https://youtu.be/xB1TJXy77fI) video walks through the process.

New hand poses can be made by creating new Hand Pose Resource instances.

![Hand Pose Resource](/docs/hand_pose_resource.png)

Hand Pose Resources consist of:
* A Pose Name (reported in the pose detector signals)
* A Threshold (a minimal fitness threshold to report the pose)
* A Hold Time (a debounce time necessary to register the pose)
* A Release Time (a debounce time necessary to release the pose)
* A set of fitness functions to apply to each pose component


### Pose Components

| Type | Description |
| :--- | :---------- |
| Flexion | The angle (in degrees) of a fingers proximal joint curving into the palm to make a fist. |
| Curl | The curl (in degrees) of a finger from the proximal to the distal joints. |
| Abduction | The spread (in degrees) between two selected fingers. |
| Tip Distance | The distance (in millimeters) between the tips of two selected fingers. |


### Fitness Function

The fitness function converts a measurement (degrees or milimeters) into a fitness in the range 0..1 with 0 being a bad match, and 1 being a perfect match. Two types of fitness function are supported:
* Smoothstep
* Range

The fitness of a Hand Pose is the product of the fitness of all the components.


#### Smooth-Step Function

The Smooth-Step function transitions from 0 to 1 over the specified range. The paramerters may be reversed to reverse the function.

![SmoothStep Positive](/docs/smootstep_positive.png)
![SmoothStep Negative](/docs/smootstep_negative.png)


#### Range Function

The Range function provides non-zero values in a finite range.

![Fitness Transform](/docs/range_function.png)


## Designing and Tuning

The inspect scene provided in the demo project can be used to inspect the flexion, curl, abduction, and tip-distance of a hand, and can also inspect a selected hand pose to diagnose the fitness of each component.

![Inspect Scene](/docs/inspect_scene.png)


## Pose Driven XR Controllers

The Hand Pose Detector addon includes a HandPoseController node which creates an XRControllerTracker capable of generating XR Input Actions in response to hand poses.



## Licensing

Code in this repository is licensed under the MIT license.


## About this repository

This repository was created by Malcolm Nixon

It is primarily maintained by:
- [Malcolm Nixon](https://github.com/Malcolmnixon/)

For further contributors please see `CONTRIBUTORS.md`
