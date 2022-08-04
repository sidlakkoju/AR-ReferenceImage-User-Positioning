# AR-ReferenceImage-User-Positioning
Get information regarding a users position (heading and distance) from a reference image. Continuously update reference image location using ARKit and computer vision.

# Functionality
* This application uses ARKit and reference image detection to calcuate the distance and heading (with respect to the detected reference image) of the phone. 
  * When the phone is right in front of the image, the heading angle is 0
  * Proceed in the clockwise direction around the reference image to increase the heading angle. 
  * Proceed in the counterclockwise direction around the reference image to decrease the heading angle. 

# Use Case
* The primary use is indoor positioning for AR Indoor Navigation. 
* If you know the geographic coordinates of the reference image and the cardinal direction the reference image is facing you can use the user heading and distance (with respect to the reference image) to find the user coordinates. 
  * This is done using the reverse haversine formula: https://stackoverflow.com/questions/7222382/get-lat-long-given-current-point-distance-and-bearing
  
