class Particle {

  PVector position;
  PVector speed;
  PVector gravity;
  
  color colorParticles;
  float life;
  float maxLife;
  int clase;
  
  Particle(PVector pos, int clase) {
  
    position = pos.copy();
    //speed = PVector.random2D().mult(random(10));
    speed = new PVector(random(-1, 1), 1).mult(random(10));
    gravity = new PVector(0, 1);
        
    if (clase == 0) colorParticles = color(26, 11, 113); 
    if (clase == 1) colorParticles = color(247, 182, 0); 
    if (clase == 2) colorParticles = color(255, 255, 255); 
    if (clase == 3) colorParticles = color(239, 132, 0); 

    life = 0;
    maxLife = 50;
    
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

    canvas.noStroke();
    float radioParticle = map(life, 0, maxLife, 3, 0);
    float alpha = map(life, 0, maxLife, 255, 0);
    canvas.fill(colorParticles, alpha);
    canvas.ellipse(position.x, position.y, radioParticle, radioParticle);
    
  }


}