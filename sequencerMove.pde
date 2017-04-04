import deadpixel.keystone.*;

import processing.sound.*;

// Import openCV package
import gab.opencv.*;

// Import the PS Move API Package
import io.thp.psmove.*;



// Tracker and controller handles
PSMoveTracker tracker;
Player [] players; // Define an array of controllers
Sequencer sequencer;

PGraphics canvas;
PGraphics brightPass;
PGraphics horizontalBlurPass;
PGraphics verticalBlurPass;

Keystone ks;
CornerPinSurface surface;

PGraphics offscreen;

PShader bloomFilter;
PShader blurFilter;

PImage outputImage;
PImage visaBanner;

ArrayList<Particle> sparks;

SoundFile baseAudio;
SoundFile roland;
ArrayList<SoundFile> pianos;
ArrayList<SoundFile> pizzicatos;



//OpenCV opencv;


// Variables for storing the camera image
PImage img;
byte [] pixels;

void setup() {
  
  // size(1024, 768, P3D);
  fullScreen(P3D, 2);
  
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(width, height, 20);
  
  // We need an offscreen buffer to draw the surface we
  // want projected
  // note that we're matching the resolution of the
  // CornerPinSurface.
  // (The offscreen buffer can be P2D or P3D)
  offscreen = createGraphics(width, height, P2D);
  
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
  
  baseAudio = new SoundFile(this, "full_bass.wav");
  roland = new SoundFile(this, "roland.aiff");
  pianos = new ArrayList<SoundFile>();
  
  for (int i = 0; i < 12; i++) {
  
    String pianoPath = "piano_" + i + ".wav";
    pianos.add(new SoundFile(this, pianoPath));
  
  }

  for (int i = 0; i < 12; i++) pianos.get(i).amp(0.2);
  

  pizzicatos = new ArrayList<SoundFile>();
  
  for (int i = 0; i < 7; i++) {
  
    String pizzicatoPath = "pizzicato_" + i + ".wav";
    pizzicatos.add(new SoundFile(this, pizzicatoPath));
  
  }

  for (int i = 0; i < 7; i++) pizzicatos.get(i).amp(0.3);

  baseAudio.amp(0.6);
  baseAudio.play();
  baseAudio.stop();
  baseAudio.loop();
  
  roland.amp(0);
  roland.play();
  roland.stop();
  roland.loop();
  
  sequencer = new Sequencer(baseAudio.duration() * 4);
  
  sparks = new ArrayList<Particle>();
  
  visaBanner = loadImage("visaBanner.png");
    
}

void draw() {
  
  PVector surfaceMouse = surface.getTransformedMouse();

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
  
  boolean crossRoland = false;

  for (int i = 0; i < players.length; i++) {
 
    players[i].display(canvas);
    
    for (int j = 0; j < players[i].audioLines.size(); j++) {
      
      for (int k = 0; k < players[i].audioLines.get(j).path.size(); k++) {
      
        PVector pointOne = players[i].audioLines.get(j).path.get(k);
        
        
        PVector crossPoint = new PVector(-1, -1);;
        
        if ((players[i].audioLines.get(j).colorIndex == 0) && (k < players[i].audioLines.get(j).path.size()-1)) { 
          
          PVector pointTwo = players[i].audioLines.get(j).path.get(k+1);
          crossPoint = intersect(pointOne.x, pointOne.y, pointTwo.x, pointTwo.y, sequencer.getPosition(), 0, sequencer.getPosition(), height);
          
        }
        
        else if (players[i].audioLines.get(j).colorIndex == 1) { 
          
          float longitud = map(0.5, 0, baseAudio.duration() * 4, 0, width);
          crossPoint = intersect(pointOne.x, pointOne.y, pointOne.x + longitud, pointOne.y, sequencer.getPosition(), 0, sequencer.getPosition(), height);
          
        }

        else if (players[i].audioLines.get(j).colorIndex == 2) { 
          
          float longitud = map(0.3, 0, baseAudio.duration() * 4, 0, width);
          crossPoint = intersect(pointOne.x, pointOne.y, pointOne.x + longitud, pointOne.y, sequencer.getPosition(), 0, sequencer.getPosition(), height);
          
        }
        
        if ((crossPoint.x >= 0) && (crossPoint.y >= 0)) {
        
          canvas.stroke(#FFE600);
          canvas.strokeWeight(1);
          canvas.noFill();
          canvas.ellipse(crossPoint.x, crossPoint.y, 16, 16);
          
          for(int l = 0; l < 5; l++) sparks.add(new Particle(crossPoint, 3));

          if (players[i].audioLines.get(j).colorIndex == 0) {
          
            roland.amp(0.9);
            roland.rate(map(crossPoint.y, 0, height, 0.25, 4.0));
            crossRoland = true;
          
          }
                    
          if ((abs(crossPoint.x - pointOne.x) < 3) && (players[i].audioLines.get(j).colorIndex == 1)) {
          
            int soundIndex = int(map(crossPoint.y, 0, height, 0, 12));
            pianos.get(soundIndex).play();
          
          }

          if ((abs(crossPoint.x - pointOne.x) < 3) && (players[i].audioLines.get(j).colorIndex == 2)) {
          
            int soundIndex = int(map(crossPoint.y, 0, height, 0, 7));
            pizzicatos.get(soundIndex).play();
          
          }
        }
        
      }
    
    }
    
  }
  
  if (!crossRoland) roland.amp(0);
  
  sequencer.update();
  sequencer.display(canvas);
  
  for (int i = 0; i < sparks.size(); i++) {
  
    sparks.get(i).update();
    sparks.get(i).display(canvas);
  
  }
  
  for (int i = sparks.size()-1; i >= 0; i--) {
  
    if (sparks.get(i).isDone()) sparks.remove(i);
  
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

  offscreen.beginDraw();

  // draw 
  offscreen.image(img, 0, 0, width, height); // Display the tracker image in the sketch window
  offscreen.blendMode(ADD);
  offscreen.image(canvas, 0, 0);
  offscreen.image(verticalBlurPass, 0, 0);
  //offscreen.blendMode(BLEND);
    
  offscreen.fill(255);
  offscreen.textSize(16);
  offscreen.text("Fullsix Innovation Dept. \nPSMove tests\n15/3/2017 \n " + frameRate + "\n Trigger: " + players[0].trigger, 40, 40);
  
  offscreen.blendMode(NORMAL);
  offscreen.image(visaBanner, 0, 0, width, height);
  
  offscreen.endDraw();
  
  background(0);
  
  surface.render(offscreen);

  
}

PVector intersect(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4){

  float a1, a2, b1, b2, c1, c2;
  float r1, r2 , r3, r4;
  float denom, offset, num;
  float x = 0;
  float y = 0;

  // Compute a1, b1, c1, where line joining points 1 and 2
  // is "a1 x + b1 y + c1 = 0".
  a1 = y2 - y1;
  b1 = x1 - x2;
  c1 = (x2 * y1) - (x1 * y2);

  // Compute r3 and r4.
  r3 = ((a1 * x3) + (b1 * y3) + c1);
  r4 = ((a1 * x4) + (b1 * y4) + c1);

  // Check signs of r3 and r4. If both point 3 and point 4 lie on
  // same side of line 1, the line segments do not intersect.
  if ((r3 != 0) && (r4 != 0) && same_sign(r3, r4)){
    return new PVector(-1, -1);
  }

  // Compute a2, b2, c2
  a2 = y4 - y3;
  b2 = x3 - x4;
  c2 = (x4 * y3) - (x3 * y4);

  // Compute r1 and r2
  r1 = (a2 * x1) + (b2 * y1) + c2;
  r2 = (a2 * x2) + (b2 * y2) + c2;

  // Check signs of r1 and r2. If both point 1 and point 2 lie
  // on same side of second line segment, the line segments do
  // not intersect.
  if ((r1 != 0) && (r2 != 0) && (same_sign(r1, r2))){
    return new PVector(-1, -1);
  }

  //Line segments intersect: compute intersection point.
  denom = (a1 * b2) - (a2 * b1);

  if (denom == 0) {
    return new PVector(-1, -1);
  }

  if (denom < 0){ 
    offset = -denom / 2; 
  } 
  else {
    offset = denom / 2 ;
  }

  // The denom/2 is to get rounding instead of truncating. It
  // is added or subtracted to the numerator, depending upon the
  // sign of the numerator.
  num = (b1 * c2) - (b2 * c1);
  if (num < 0){
    x = (num - offset) / denom;
  } 
  else {
    x = (num + offset) / denom;
  }

  num = (a2 * c1) - (a1 * c2);
  if (num < 0){
    y = ( num - offset) / denom;
  } 
  else {
    y = (num + offset) / denom;
  }

  // lines_intersect
  return new PVector(x, y);
}


boolean same_sign(float a, float b){

  return (( a * b) >= 0);
}

void mousePressed() {

  pianos.get(0).amp(map(mouseY, 0, height, 0.02, 1.0));
  pianos.get(0).play();

}

void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
  }
}