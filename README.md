# Design of Subsystem for Environment Monitoring
[Youtube Video](https://www.youtube.com/watch?v=wWGfXN3OqWY)
## Introduction
The project involves integration of variety of sensors on a single platform for environment monitoring applications. Various sensor inputs will be processed for conversion to a standardized format which can eventually be communicated and displayed.

This work will primarily be done using a digital platform (FPGA and microcontrollers) with the capability to remote access and also for monitoring and control of the environmental and control mechanisms.

The array of sensors included are a temperature sensors, smoke detectors to detect fires, humidity sensors, light sensors, wind speed sensor, accelerometers to detect earthquakes/panic situations and finally a Total Dissolved Solids sensor to detect dissolved matter in matter, thus making a complete safety solution to a building.

The sensor data would be interfaced with the digital platform using Analog-to-Digital Converters, to be displayed in an LCD screen and also, interfaced with a Wi-Fi module or internet enabled microcontroller to host the real-time data over cloud. 

An interactive web-app can allow the user to monitor the data and remotely control his devices in case any factor moves out of optimum range of parameters. The same information can also be sent as an e-mail or SMS alert in case of changes.

We seek to ensure uniform behavior of the sensor by the way of linearization of the sensors so that the device can be utilized universally.
## Softwares
Xilinx Petalinux 2017

Xilinx Vivado-2018

Xilinx SDK-2018

Blynk Android App

Arduino IDE
## Devices 
FPGA ZYBO Z-7010

WiFi Enabled Microcontroller-NodeMCU unit

Environment Sensors

ADCs
