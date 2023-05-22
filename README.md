# EasySLM

*All code was tested and should work on versions 2019a-2022a of Matlab.

Matlab code for easily using an SLM to create extended patterns or optical tweezers. This code is dependent on OTSLM toolbox (https://github.com/ilent2/otslm) which can be easily installed as an app in Matlab. However, if installing via Git, make sure the folder is in your Matlab path and that the Matlab toolboxes OTSLM uses are installed. These include the following

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
    <li> Config.m : Implements a class that simply stores the parameters of an SLM setup. You can add more setups as static class methods. </li>
    <li> OpticalPatterns.m : Class for containing functions for creating miscellaneous patterns to find phase masks of and class methods for calculating known phase masks.</li>
    <li> OpticalTweezers.m : Abstract class implementation of optical tweezer arrays can be easily created and moved in 3D. The SLM class inherits from this class such that all types of light modulation can be done through a single SLM class object. </li>
    <li> SLM.m : Extends OTSLM ScreenDevice, OpticalTweezers & Optical Patterns class and acts as a superclass for calculating and displaying arbitrary phase patterns to an SLM. </li>
    <li> CamInterface.m : Abstract class that establishes the methods that should be implemented to link a classes functionality to a Cam object. </li>
    <li> Cam.m : Camera object useful for capturing snapshots from a camera. </li>
    <li> OptReservoir.m : Extends the SLM class and implements a feedback loop between SLM and camera for applications to optical reservoir computing. </li>
</ul>
