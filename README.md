# EasySLM

*All code was tested and should work on versions 2019a-2023a of Matlab.

Matlab code for easily using an SLM to create extended patterns or optical tweezers. This code is dependent on OTSLM toolbox (https://github.com/ilent2/otslm) which can be easily installed as an app in Matlab or through github. However, if installing via Git, make sure the folder is in your Matlab path and that the Matlab toolboxes OTSLM uses are installed. These include the following

    Optimization Toolbox
    Signal Processing Toolbox
    Neural Network Toolbox
    Symbolic Math Toolbox
    Image Processing Toolbox
    Instrument Control Toolbox
    Parallel Computing Toolbox
    Image Acquisition Toolbox

Additonally, you if you want to control the camera through Matlab the required Hardware Support Packages (https://www.mathworks.com/help/imaq/supported-hardware.html) must also be installed. For most cameras the generic "winvideo" adapter should be enough. This can be done in the MATLAB app through the add-ons option.

<h2> Files: </br> </h2>
<ul>
    <li> 1) Config.m : Implements a class that simply stores the parameters of an SLM setup. You can add more setups as static class methods. </li>
    <li> 2) OpticalPatterns.m : Class for containing functions for creating miscellaneous patterns to find phase masks of and class methods for calculating known phase masks.</li>
    <li> 3) OpticalTweezers.m : Class implementation of optical tweezer arrays can be easily created and moved in 3D. This class extends OpticalPatterns. </li>
    <li> 4) SLM.m : Extends OTSLM ScreenDevice & OpticalTweezers classes and acts as a superclass for calculating and displaying arbitrary phase patterns to an SLM. This is the only class that depends directly on the OTSLM package. </li>
    <li> 5) CamInterface.m : Abstract class that establishes the methods that should be implemented to link a classes functionality to a Cam object. </li>
    <li> 6) Cam.m : Camera object useful for capturing snapshots from a camera. </li>
    <li> 7) OptReservoir.m : Extends the SLM class and implements a feedback loop between SLM and camera for applications to optical reservoir computing. This class implements CamInterface. </li>
    <li> 8) RecordableSLM.m : Extends the SLM class to implement automatic display and imaging capabilities. This class implements CamInterface.
</ul>

<h2> Using SLM Class: </h2>

    config = Config(Name, Value) % Initialize a configuratoin (see Config.m for needed arguments)
    slm = SLM(config, 'f', ###) % Create an SLM class from the config and give a focal length for a virtual lens
    
    phase= slm.compute_phasemask(im, Name, Value) % Compute a phase mask for image 'im'
    slm.apply_grating(10,False) % Apply a blazed grating pattern to translate image (this is reset after being shown)
    slm.show(phase) % Display phase on SLM
    % Could also call slm.play(frames) to play a series of frames
    
  If using optical tweezer functionality
  
    slm.add( [x1,y1], phase, dz1 ) % Create an arbitrary tweezer at (x1,y2,f+dz1)
    slm.add_vortex( [x2,y2], l, dz2 ) % Create an optical vortex with angular momentum l at (x2,y2,f+dz2)
    slm.add_axicon( [x3,y3], G, dz3) % Create an axicon tweezer at (x3,y3,f+dz3)
    tweezers= slm.compute_tweezers(Name, Value) % Compute tweezer array
    slm.show(tweezers) % Display tweezers
    
    
