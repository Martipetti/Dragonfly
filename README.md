# Dragonfly-extended

This system is based on [Dragonly](https://github.com/DragonflyDrone/Dragonfly) project with an extension for 2 uncertenty in the managed system (rain in the environment and obstacle detection).

The simulator is implemented in Java, uses the JavaFX technology for the Graphical User Interface, and AspectJ for aspect implementation and weaving. More information on the original project github repository.

## Development requirements
To run the code you need a version of **Java 8 in which JavaFX is packaged** (or add this dependency manually). It is also necessary to add AspectJ as a dependency.
To facilitate configuration, the following link contains the version of the dependencies used, and a video example of how to run DragonFly from the code in the Intellij IDE.

Link: https://drive.google.com/drive/folders/1Zs2ftZSutymb8AwVx3AYNbWYDZWmdn8o?usp=sharing

To correcly run the project it is possible tio watch the file in previous folder with some notes:
- Intall and use the liberica-full-1.8 sdk (it is possible to intall it throught IntelliJ and there is inside JavaFx).
- Use the Intellij ultimate edition (free with scholar licence).
- Intall the AscpectJ plug-in before the setting procedure.
- Once the configuraiton procedure is done, run the mainCOntroller class.


## Running the Simulator - Step-by-step

This section presents a step-by-step tutorial to use the artifact.

### 1) Setting up Environment

The first step of using the simulator is the environment construction. The available elements are:

- **River**, which the drone should not land on;
- **Hospital**, which can be set by the user as the Source and Target hospitals of the flight;
- **Antenna**, which emits waves that cause a bad connection in the drones located in its adjacent blocks;
- **Drone**, the main element that has its own properties, as described in the next steps.
- **Boat**, a boat that can save drones that are about to execute a safety landing and carry them to their destination.
- **House**, a graphic representation of a House. 
- **Tree**, a graphic representation of a Tree.

This simulator provides two options for setting the environment:

- to create an environment from scratch, inserting each element one by one. For inserting an element, the user needs to select the button of the respective element, and click at the desired position on the grid.
- to load the example environment used in the paper, the user can access "Menu -> SEAMS paper example".

### 2) Setting Drone Configuration

The next step consists of configuring the following drone properties:

- **Battery consumption per block**: it sets the percentage of battery consumed when the selected drone moves from a block to an adjacent block.
- **Battery consumption per second**: it sets the percentage of battery consumed per second while the selected drone is flying.
- **Initial battery**: the initial percentage value for the selected drone.
- **Wrapper dropdown**: The user selects the desired wrapper implementation, or selects the "None" option for executing with its original behavior.
- **Automatic checkbox**:  by checking this box, the user  turns the automatic pilot feature of the drone on, so it will move independently following a minimal path algorithm.  On the other hand, leaving the box unchecked implies that the user will pilot the drone manually.
- **Drone's Destination**: by clicking the gear icon, the user can select on the environment the destination's position.

Controls for piloting drones manually:
- **R** key: turn on/off the drone.
- **SPACEBAR** key: drone takes off/lands.
- **W**, **A**, **S** and **D** keys: drone moves up, left, down and right, respectively.

### 3) Starting the application

The final step consists of starting the execution of the application, by clicking the "Ready" button, which triggers the execution of each drone inserted in the environment simultaneously. The traces of each drone are printed in a text area, from which it is possible to verify the scenarios that the drones perform and the current status of their battery.

By clicking on the "Restart" button, the user restarts the execution, i.e., the initial position and initial battery of the drones are restored and the user can start a new simulation.

## License

This artifact is licensed under the BSD 2-Clause License; the artifact may not be used except in compliance with the License. Conditions to redistribute and use this artifact in source and binary forms, with or without modification, are detailed in LICENSE.md file.

## Contact
If you have any problem to use the artifact, please do not hesitate to contact us by sending an email to dragonfly.seams2019@gmail.com, pauloh.maia@uece.br, lucas.vieira@aluno.uece.br or maths.c28@gmail.com.
