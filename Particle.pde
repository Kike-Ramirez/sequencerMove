class Particle {

  PVector position;
  PVector speed;
  PVector gravity;
  
  color colorParticles;
  float life;
  float maxLife;
  
  Particle(PVector pos) {
  
    position = pos.copy();
    speed = PVector.random2D().mult(random(5));
    gravity = new PVector(0, 1);
    
    colorMode(HSB, 360, 100, 100);
    colorParticles = color(random(30, 60), 255, 255); 
    colorMode(RGB, 255,255,255);    
    life = 0;
    maxLife = 100;
    
  }
  
  void update() {
  
    speed.add(gravity);
    position.add(speed);
    life++;
  
  }
  
  boolean isDone() {
    
    if ((position.y > height) || (life > maxLife)) {
    
      return true;
    }
    
    else return false;
  
  }
  
  void display(PGraphics canvas) {

    canvas.beginDraw();
    canvas.fill(colorParticles);
    canvas.noStroke();
    float radioParticle = map(life, 0, maxLife, 5, 0);
    canvas.ellipse(position.x, position.y, radioParticle, radioParticle);
    canvas.endDraw();
    
  }


}