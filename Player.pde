class Player {

  int id;
  PSMove controller;
  int trigger;
  boolean isPainting, triangleButton, crossButton;
  ArrayList<AudioLine> audioLines;
  ArrayList<Particle> particles;
  PVector pos;
  color[] colores;
  int colorIndex;
  boolean deletePath;
  
  Player(PSMoveTracker tracker_, int id_) {
  
    id = id_;
    controller = new PSMove(id);
    controller.set_leds(255, 255, 255);
    controller.update_leds();
    
    while (tracker_.enable(controller) != Status.Tracker_CALIBRATED);
    
    trigger = 0;
    isPainting = false;
    triangleButton = false;
    crossButton = false;
    
    audioLines = new ArrayList<AudioLine>();
    particles = new ArrayList<Particle>();
    pos = new PVector(0,0);
    
    colores = new color[3];
    colores[0] = color(255, 0, 0);
    colores[1] = color(0, 255, 0);
    colores[2] = color(0, 0, 255);
    colorIndex = 0;
    deletePath = false;
    
  }
  
 
  void update(PSMoveTracker tracker_) {
  
    if (deletePath) audioLines.clear();
    
    float[] x = new float[1];
    float[] y = new float[1];
    float[] r = new float[1];
    
    tracker_.get_position(controller, x, y, r);
    pos  = new PVector(x[0], y[0]);
    
    while (controller.poll() != 0) {
      int buttons = controller.get_buttons();
      if ((buttons & Button.Btn_CROSS.swigValue()) != 0) {
           crossButton = true;
      }
       
      else crossButton = false;
       
      if (((buttons & Button.Btn_TRIANGLE.swigValue()) != 0) && (triangleButton == false)) {
            triangleButton = true;
            colorIndex++;
            if (colorIndex > 2) colorIndex = 0;
      }
      
      else if (((buttons & Button.Btn_TRIANGLE.swigValue()) == 0) && (triangleButton == true)) {
            triangleButton = false;
      }
             
      trigger = controller.get_trigger();
      controller.set_rumble(trigger);
      
      if (crossButton) deletePath = true;
      else deletePath = false;

         
  }
    
    
    if ((isPainting) && (trigger > 0)) {
    
      audioLines.get(audioLines.size() - 1).addPoint(pos);
      particles.add(new Particle(pos));
      
    }
    
    else if ((isPainting) && (trigger == 0)) {
    
      isPainting = false;
    
    }
    
    else if ((!isPainting) && (trigger > 0)) {
    
      audioLines.add(new AudioLine(colores[colorIndex]));
      audioLines.get(audioLines.size() - 1).addPoint(pos);
      isPainting = true;
      
    }
    
    for (int i = 0; i < particles.size(); i++) {
    
      particles.get(i).update();
      
    }
    
  }
  
  
  void display(PGraphics canvas) {
  

    canvas.beginDraw();
    canvas.noFill();
    canvas.stroke(255);
    canvas.strokeWeight(3);
    canvas.ellipse(pos.x, pos.y, 30, 30);
    canvas.endDraw();
    
    for (int i = 0; i < audioLines.size(); i++) {
    
      audioLines.get(i).display(canvas);
    
    }
    
    for (int i = 0; i < particles.size(); i++) {
    
      particles.get(i).display(canvas);
      
    }
    
    for (int i = particles.size() - 1; i >= 0; i--) {
    
      if (particles.get(i).isDone()) particles.remove(i);
    
    }
    
    println(particles.size());
  
  }
  
}