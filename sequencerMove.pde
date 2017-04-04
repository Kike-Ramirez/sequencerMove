// Import openCV package
import gab.opencv.*;

// Import the PS Move API Package
import io.thp.psmove.*;



// Tracker and controller handles
PSMoveTracker tracker;
Player [] players; // Define an array of controllers

PGraphics canvas;
PGraphics brightPass;
PGraphics horizontalBlurPass;
PGraphics verticalBlurPass;

PShader bloomFilter;
PShader blurFilter;

PImage outputImage;



//OpenCV opencv;


// Variables for storing the camera image
PImage img;
byte [] pixels;

void setup() {
  size(640, 480, P2D);
  
  int connected = psmoveapi.count_connected();

  // This is only fun if we actually have controllers
  if (connected == 0) {
    print("WARNING: No controllers connected.");
  }


  
  tracker = new PSMoveTracker(); // Create a tracker object

  tracker.set_mirror(1); // Mirror the tracker image horizontally

 
  players = new Player[connected];

  for (int i = 0; i < connected; i++) {
  
    players[i] = new Player(tracker, i);
    
  }
  
  canvas = createGraphics(width, height);
  
  //opencv = new OpenCV(this, canvas);
  //outputImage = createImage(width, height, RGB);
  
  brightPass = createGraphics(width, height, P2D);
  brightPass.noSmooth();

  horizontalBlurPass = createGraphics(width, height, P2D);
  horizontalBlurPass.noSmooth(); 

  verticalBlurPass = createGraphics(width, height, P2D);
  verticalBlurPass.noSmooth(); 

  bloomFilter = loadShader("bloomFrag.glsl");
  blurFilter = loadShader("blurFrag.glsl");
    
}

void draw() {
  tracker.update_image();
  tracker.update();

  bloomFilter.set("brightPassThreshold", 0.0);

  blurFilter.set("blurSize", 50);
  blurFilter.set("sigma", 12.0); 
  
  // Get the pixels from the tracker image and load them into a PImage
  PSMoveTrackerRGBImage image = tracker.get_image();
  if (pixels == null) {
    pixels = new byte[image.getSize()];
  }
  image.get_bytes(pixels);
  if (img == null) {
    img = createImage(image.getWidth(), image.getHeight(), RGB);
  }
  img.loadPixels();
  for (int i=0; i<img.pixels.length; i++) {
    // We need to AND the values with 0xFF to convert them to unsigned values
    img.pixels[i] = color(pixels[i*3] & 0xFF, pixels[i*3+1] & 0xFF, pixels[i*3+2] & 0xFF);
  }

  img.updatePixels();

  for (int i = 0; i<players.length; i++) {
     
    players[i].update(tracker);
    
  }
  
  canvas.beginDraw();
  canvas.background(0);
  
  for (int i = 0; i<players.length; i++) {
 
    players[i].display(canvas);
    
  }

  canvas.endDraw();
  
    // bright pass
  brightPass.beginDraw();
  brightPass.shader(bloomFilter);
  brightPass.image(canvas, 0, 0);
  brightPass.endDraw();

  // blur horizontal pass
  horizontalBlurPass.beginDraw();
  blurFilter.set("horizontalPass", 1);
  horizontalBlurPass.shader(blurFilter);
  horizontalBlurPass.image(brightPass, 0, 0);
  horizontalBlurPass.endDraw();

  // blur vertical pass
  verticalBlurPass.beginDraw();
  blurFilter.set("horizontalPass", 0);
  verticalBlurPass.shader(blurFilter);
  verticalBlurPass.image(horizontalBlurPass, 0, 0);
  verticalBlurPass.endDraw();

  // draw 
  image(img, 0, 0, width, height); // Display the tracker image in the sketch window
  blendMode(ADD);
  image(canvas, 0, 0);
  image(verticalBlurPass, 0, 0);
  blendMode(BLEND);

    
  fill(255);
  textSize(16);
  text("Fullsix Innovation Dept. \nPSMove tests\n15/3/2017 \n " + frameRate, 40, 40);
  
  
}