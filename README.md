#biapDEMO - iPad Application
**biapDEMO** is a demonstration system built for EndoU, Imperial College London as part of 3rd Year Group Project. It showcases the abilities of the world's first [Biologically-inspired Artificial Pancreas **(BiAP)**](http://www3.imperial.ac.uk/bioinspiredtechnology/research/bionicpancreas).

![alt text](https://raw.githubusercontent.com/aaronsheah/BiAp-Demo/master/misc/screenshot.png "Screenshot of iPad App")

This repository contains the code for the iPad app interface for the biapDEMO.

## Table of Contents
* [**Project Details**](#project-details)
	* [**Requirements**](#requirements)
	* [**Installation**](#installation)

* [**Code Structure**](#code-structure)

	* [**External Libraries**](#external-libraries)
		* [**BEMSimpleLineGraphView**](#bemsimplelinegraphview)
		* [**JBChartView**](#jbchartview)
		* [**nRF UART**](#nrf-uart)
	* [**Views**](#views)

## Project Details
Learn more about the **biapDEMO** project requirements and installation. This project is written in Swift 1.2

### Requirements
- Requires iOS 8 or later.
- Current target SDK : iOS 8.0

### Installation
Notes : This project requires Xcode, which is only available on Mac OS X.

1. Download the folder **"BiAp Demo"**

2. Open the Xcode Project

3. Choose the device you would like to compile to on the top left.

![alt text](https://raw.githubusercontent.com/aaronsheah/BiAp-Demo/master/misc/device.png "Screenshot of How to Choose Device")


4. Click "Play" button on top left

5. Done!

## External Libraries
In this section, the external libraries used in this project are detailed.

### BEMSimpleLineGraphView
This library is used to plot the Glucose Levels. Visit the [BEMSimpleLineGraphView repository](https://github.com/Boris-Em/BEMSimpleLineGraph) to learn how to customise the Glucose Line Graph.

### JBChartView
This library is used to plot the Insulin Dose Levels. Visit the [JBChartView repository](https://github.com/Jawbone/JBChartView) to learn how to customise the Insulin Bar Chart.

### nRF UART
This library is used for Bluetooth LE communication with MATLAB. Click this [link](https://developer.mbed.org/media/uploads/nemovn/nrf_uart_1.0.1.zip) to download the source code for the nRF UART app.

## Code Structure
The app's basic skeleton is based on [this sample project](http://www.raywenderlich.com/78568/create-slide-out-navigation-panel-swift).

Note : To include Objective-C code, you can do so in the bridging header `"BiAp Demo-Bridging-Header.h"`, which 'bridges' Objective-C code into Swift code.

### Views
##### 1. Container
The main container view. This allows for sliding side navigation between a _'Center'_ view and a _'Side Panel'_ view.

**WARNING** : Modifying this view will not change content. Main view is 'Center' view.

##### 2. Center
This is the view that holds the main screen. 3 main things that in this view are the Meal Library Table View, Glucose Line Graph and Insulin Bar Graph.

###### i. Meal Library
###### ii. Graphs
###### 	a. Glucose Line Graph
###### 	b. Insulin Bar Graph
###### iii. Bluetooth 

##### 3. Side Panel
This view holds the hidden settings panel which can be access through a pan gesture.

It is a static table view, therefore adding more settings/tips can be done in the Storyboard.



