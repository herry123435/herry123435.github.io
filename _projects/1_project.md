---
layout: page
title: CRAIP
description: Creating Robot Artificial Intelligence Project - Enabling robots to perform various tasks based on natural language instructions.
img: /assets/img/CRAIP.gif
importance: 1
category: work
---

In this project, we gave an ability to comprehend and execute complex tasks specified through natural language to robotic agent. The robot(Unitree Go1) determines its next action by integrating real-time visual input from its cameras with the natural language commands it received.

The CRAIP system is an integrated pipeline where each component handles a distinct stage of the instruction-to-action process. The workflow begins with human input and culminates in precise robotic motion, all orchestrated within the ROS (Robot Operating System) framework.

    ---
    Gazebo Indoor Simulation Environment: Provides a simulated indoor environment for robot operation.
    LLM-Based Goal Selector: Parses language instructions into landmarks for the robot to navigate to.
    Subgoal Coordinate Filter: Extracts landmark poses in world coordinates for accurate navigation.
    D-star Path Planner: Generates optimal paths to the designated goal.
    MPPI Controller: Handles low-level control to execute smooth navigation along the planned path.
    ---

The following video shows an egocentric view of a robot, from the moment it receives the natural language command 'Score a goal' until it successfully kicks a soccer ball into the goalpost.

<div class="row justify-content-center my-4">
  <div class="col-lg-10">
    <video
      class="w-100 rounded shadow-sm"
      controls
      preload="metadata"
      poster="{{ '/assets/img/CRAIP_cropped-0001.png' | relative_url }}"
    >
      <source src="{{ '/assets/img/CRAIP_cropped.mp4' | relative_url }}" type="video/mp4" />
      브라우저가 MP4 재생을 지원하지 않는 경우입니다.
    </video>
  </div>
</div>

