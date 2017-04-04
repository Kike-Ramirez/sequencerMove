class Sequencer {

  float xPos;
  float timeLoop;
  float time;
  
  Sequencer(float timeLoop_) {
  
    xPos = 0;
    timeLoop = timeLoop_;
    time = millis();
    
  }
  
  void update() {
    
    time = (millis() % (timeLoop * 1000.0));
  
    xPos = map(time, 0, timeLoop * 1000.0, 0, width);
    
  }

  void display(PGraphics canvas) {
  
    canvas.noFill();
    canvas.stroke(239, 132, 0);
    canvas.strokeWeight(3);
    canvas.line(xPos, 0, xPos, height);
  
  }
  
  float getPosition() {
  
    return xPos;
    
  }


}