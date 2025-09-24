---
layout: page
title: Learning dynamics of an autonomous vehicle
description: "<span style='color:#6c757d'>Work done at </span><a href='https://dcsl.gatech.edu/'>DCSL Lab in Georgia Tech</a><span style='color:#6c757d'></span>"
img: /assets/img/Trajectory_Prediction.gif
importance: 4
category: work
---

To drive a car autonomously, we need to understand how a vehicle reacts to control in given context. In other words, we have to figure out the vehicle’s response to a force determined by the throttle and the steering angle. To do that, I implemented a neural network architecture that can predict a car’s future directory more accurately than kinematics-only, non-trainable model. The process began by validating the model’s performance with simulated data, and subsequently progressed to enhancing the model to effectively handle defective real-world data with defect from various issues such as sensor error. By doing this, I could get closer to robust physical AI.

1. Design of a GRU-based vehicle dynamics model and training on simulated date<br>
In this study, a GRU(Gated Recurrent Unit) based model was selected & implemented to learn the dynamic characteristics of a vehicle. The model was designed to predict the next timestep’s state(forward velocity, sideways velocity, angular velocity) from the past five timesteps of the vehicle’s state and control inputs(throttle, steering).
During the initial development phase, while experimenting with various model architectures, I found that using only single GRU layer was more robust to noise and overfitting, and learned faster than using multiple GRU layer. Consequently, I implemented single GRU layer architecture. To validate its foundational performance, the model was first trained using data generated from a simulator. The initial results were promising, with the learning curve showing a steady decrease in both training and test loss, confirming that the model successfully learned the dynamics of the simulated environment. Moreover, when I visualized the predicted trajectory and compared it with ground truth trajectory, predicted one seems very smooth and accurate.

2. The challenge of real world data noise and its solution using filter method.<br>
When applying the model to real-world driving data, a significant issue arose. Due to position sensor noise, calculating accurate velocity was unavailable, and this made calculated velocity data(v_x, v_y) extremely noisy and jitters a lot. This noisy data severely compromised reliability and led to a very unstable and inaccurate prediction of the future trajectory. To resolve this issue, a Savitzky-Golay filter was introduced during the data preprocessing stage to denoise the calculated velocity values. Applying the filter effectively removed the erratic noise while preserving
the underlying trends, yielding much smoother and more consistent velocity data for training.

3. Training on filtered real world data and performance validation<br>
After retraining the model with filtered real world data, the learning curve stabilized significantly, and the prediction performance improved dramatically. When I visualized it, I could confirm it became very consistent. To precisely evaluate the model’s final performance, a quantitative metric (weighted mean squared error) was used in addition to visualization of the predicted trajectory. The developed neural network model achieved an error value of 0.006864, which represents a nearly tenfold improvement in accuracy compared to a conventional kinematic model, which scored an error of 0.06659.