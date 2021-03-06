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
    
    while (tracker_.enable(controller) != Status.Tracker_CALIBRATED) {
    
      // Just wait
      
    }
    
    trigger = 0;
    isPainting = false;
    triangleButton = false;
    crossButton = false;
    
    audioLines = new ArrayList<AudioLine>();
    particles = new ArrayList<Particle>();
    pos = new PVector(0,0);
    
    colores = new color[3];
    float alpha = 255;
    colores[0] = color(26, 11, 113, alpha);
    colores[1] = color(247, 182, 0, alpha);
    colores[2] = color(255, 255, 255, alpha);
    colorIndex = 0;
    deletePath = false;
    
  }
  
 
  void update(PSMoveTracker tracker_) {
  
    if (deletePath) audioLines.clear();
    
    float[] x = new float[1];
    float[] y = new float[1];
    float[] r = new float[1];
    
    tracker_.get_position(controller, x, y, r);
    pos  = new PVector(x[0] * width / 640.0, y[0] * height / 480.0);
    
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
    
      // COMPROBAR!!
      audioLines.get(audioLines.size() - 1).addPoint(pos);
      
      float numParticles = map(trigger, 0, 255, 0, 50);
      
      for (int i = 0; i < numParticles; i++) particles.add(new Particle(pos, colorIndex));
      
    }
    
    
    else if ((!isPainting) && (trigger > 0)) {
    
      audioLines.add(new AudioLine(colorIndex));
      audioLines.get(audioLines.size() - 1).addPoint(pos);
      isPainting = true;
      
    }
    
    else if (trigger == 0) {
    
      isPainting = false;
    
    }
    
    for (int i = 0; i < particles.size(); i++) {
    
      particles.get(i).update();
      
    }
    
  }
  
  
  void display(PGraphics canvas) {
  

    canvas.fill(255, 255, 0);
    canvas.ellipse(pos.x, pos.y, 5, 5);
    
    for (int i = 0; i < audioLines.size(); i++) {
    
      audioLines.get(i).display(canvas);
    
    }
    
    for (int i = 0; i < particles.size(); i++) {
    
      particles.get(i).display(canvas);
      
    }
    
    for (int i = particles.size() - 1; i >= 0; i--) {
    
      if (particles.get(i).isDone()) particles.remove(i);
    
    }
    
  
  }
  
}