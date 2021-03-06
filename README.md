# Tumble HyperGodot Demo
![tumble demo](tumble.jpg)

This is a very basic demo with a few bugs. It's main goal is to showcase a third person game that uses the [hypercore protocol](https://hypercore-protocol.org/) for multiplayer. We hope this can serve as a resource for others who may wish to use hypercore for p2p 3d multiplayer games.

# Controls
* wsad for movement 
* left mouse click for grappling hook 
* "x" for light toggle
* space bar for jump
* "r" to respawn

# Credits
* Dresk - programming 
* Mauve - programming 
* Fleeky - Modelling / Animation 
* Ashes - Art Direction / Sounds 

# More information
* Download both the PCK file and the binary 
* Linux : chmod +x binary in order to run it
* hypercore-gateway uses a slightly older version of hypercore. while hole punching is good , some router configurations do require you to open port 4973.
* collision detection can be sticky , if you get stuck you can always press r to respawn. 
* loading in different world environments can cause momentary lag while it updates, the more you go through the teleporters the less this happens. 
* step height is still an issue with our player controller, jump a lot and use the grappling hook!
* to start multiplayer
  * press esc to bring up main menu , select multiplayer
  * click start to start gateway 
  * you can enter any qualified hyper:// url such as hyper://c7fd48cd4c89dc041ac66a414c07e1d4553dc3f734833c4663f9cea94ccbb680 or one with a dns record that points to a hyper url.
