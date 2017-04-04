class AudioLine {

  ArrayList<PVector> path;
  color colorLine;
  int maxPoints;
  int strokeLine;
  
  AudioLine(color colorLine_) {
  
    path = new ArrayList<PVector>();
    colorLine = color(colorLine_);
    maxPoints = 200;
    strokeLine = 4;
    
  }

  void addPoint(PVector point) {
  
    path.add(point);
    
    if (path.size() > maxPoints) {
    
      path.remove(0);
      
    }
    
  
  }
  
  void display(PGraphics canvas) {
  
    
    canvas.noFill();
    canvas.stroke(colorLine);
    canvas.strokeWeight(strokeLine);
    canvas.beginShape();
    if (path.size() > 1) {
    
      canvas.curveVertex(path.get(0).x, path.get(0).y);
      
      for (int i = 0; i < path.size(); i++) {
        
        canvas.curveVertex(path.get(i).x, path.get(i).y);
      
      }
    
      canvas.curveVertex(path.get(path.size() - 1).x, path.get(path.size() - 1).y);
    }
    
    canvas.endShape(); 
    
  
  }

}