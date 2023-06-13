# EasySLM/Scripts/ReservoirComputing

Scripts for collected scattered MNIST digits. 

<h2> Files: </br> </h2>
<ul>
    <li> MNIST.m : Use to compute and display the phase pattern for a single MNIST digit. </li>
    <li> MNIST_precompute.m : Use to precompute a large number of phase patterns for the training and testing sets. </li>
    <li> MNIST_labels.m : Use to extract the labels for the precomputed phases you will use. </li>
    <li> MNIST_display.m : Use to image all of the digits. </li>
</ul>

<h2> Running System on Multiscale Microscope: </h2>

There are two options:
    1) Use the free space path.
    2) Utilize the full multiscale microscope.
    
For option 1, ensure that the camera is attached to the flip mount before the mirrors that direct the light into the microscope. Flip both the camera and the preceding f=300mm lens into the beam bath. Into the first post holder after the SLM, one can add a slide with a scattering sample on it a post with clips attached. Placing the slide in the post will put the scattering medium in the focal plane of the SLM (assuming a f=200mm virtual lens is being used and the system is aligned). Turning on the SLM and laser and connecting the camera will allow you to then image the MNIST digits using MNIST_display.m

For option 2, put the 10x objective before the stage on the multiscale microscope (make sure the free space imaging lens and camera are out of the beam path). Bring the system into focus with the 10x objective on the widefield or rescan cameras. Put the 40x objective on the swivel mount above the stage. While the objective should be at the correct height to be in focus (assuming the 10x objective is in focus), the X-Y position of the stage and swivel will need to be adjusted until the light is centered. Then place a camera in the right swivel mount and center it above the imaging objective. Check to make sure the camera is in focus as well. Then carefully place a scattering medium on the multiscale stage. It will need to be thin enough to fit between the objectives. Execute the code just as previously mentioned.
