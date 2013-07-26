---
published: false
---

Shadowmapping_iOS
=================
This is sample OpenGL application written for the iPad which implements three shadowmapping algorithms: hard, soft, and variable penumbra shadows. It is of interesting to any iOS developers who wish to implement shadowmapping in iOS.  
## Hard Shadows
Hard shadowing is a very standard computer graphics algorithm. The implementation in this app has no mystery. For more info see both:   
http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/
http://www.fabiensanglard.net/shadowmapping/index.php

## PCF (Soft) Shadows
PCF Shadow filter the shadow edge by sampling the surrounding pixels to create a filter. The problem on the iPad(and iPhone) is that multiple texture lookups on the come at a great cost, due to the Tile Based Renderer. Even simple 3x3 PCF reducesthe framerate to single figures for the simple test scene in this app. My solution is to filter the shadowmap with an edge detection filter, and then use mipmapping on that edgemap to restrict the application of the PCF filter only to the edges.o








