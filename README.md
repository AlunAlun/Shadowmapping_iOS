---
published: true
---

Shadowmapping_iOS
=================
This is sample OpenGL application written for the iPad which implements three shadowmapping algorithms: hard, soft, and variable penumbra shadows. It is of interesting to any iOS developers who wish to implement shadowmapping in iOS.  
## Hard Shadows
Hard shadowing is a very standard computer graphics algorithm. The implementation in this app has no mystery. For more info see both:   
http://www.opengl-tutorial.org/intermediate-tutorials/tutorial-16-shadow-mapping/
http://www.fabiensanglard.net/shadowmapping/index.php
## PCF (Soft) Shadows
PCF Shadow filter the shadow edge by sampling the surrounding pixels to create a filter. The problem on the iPad(and iPhone) is that multiple texture lookups on the come at a great cost, due to the Tile Based Renderer. Even simple 3x3 PCF reducesthe framerate to single figures for the simple test scene in this app. My solution is to filter the shadowmap with an edge detection filter, and then use mipmapping on that edgemap to restrict the application of the PCF filter only to the edges. The rest of the scene is tested with the hard shadow algorithm. This solution raises the framerate to something respectable (in the 20s).
## Variable Penumbra Shadows
Variable penumbra shadows mean essentially that the width of the shadow is greater if the distances are greater. In this app I use the pixel intensity of the detected edge of the shadow map as an estimate of distance between occluder and shading surface, and use this distance to vary the width of the penumbra
More info and paper published at GRAPP 2014 here:
http://alunevans.info/grapp2014



