class AudioLine {

  ArrayList<PVector> path;
  int maxPoints;
  int strokeLine;
  int colorIndex;
  color[] colores;
  
  AudioLine(int colorIndex_) {
  
    path = new ArrayList<PVector>();
    maxPoints = 200;
    strokeLine = 4;
    
    colores = new color[3];
    float alpha = 255;
    colores[0] = color(26, 11, 113, alpha);
    colores[1] = color(247, 182, 0, alpha);
    colores[2] = color(255, 255, 255, alpha);
    colorIndex = colorIndex_;
    
  }

  void addPoint(PVector point) {
  
    if (colorIndex == 0) {
      path.add(point);
      
      if (path.size() > maxPoints) {
      
        path.remove(0);
        
      }
    }
    
    else if (colorIndex == 1) {
    
      float longitud = map(0.5, 0, baseAudio.duration() * 4, 0, width);
      
      float resto = point.x % int(longitud);
      
      PVector modifiedPoint = new PVector(point.x-resto, point.y);
      
      path.add(modifiedPoint);
        
      if (path.size() > maxPoints) {
        
        path.remove(0);
          
      }       
      
    }

    else if (colorIndex == 2) {
    
      float longitud = map(0.3, 0, baseAudio.duration() * 4, 0, width);
      
      float resto = point.x % int(longitud);
      
      PVector modifiedPoint = new PVector(point.x-resto, point.y);
      
      path.add(modifiedPoint);
        
      if (path.size() > maxPoints) {
        
        path.remove(0);
          
      }       
      
    }
  
  }
  
  void display(PGraphics canvas) {
  
    
    canvas.noFill();
    canvas.stroke(colores[colorIndex]);
    canvas.strokeWeight(strokeLine);
    
    if (colorIndex == 0) {
      
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
    
    else if (colorIndex == 1) {
    
      float longitud = map(0.5, 0, baseAudio.duration() * 4, 0, width);
      
      for (int i = 0; i < path.size(); i++) {
      
        canvas.line(path.get(i).x, path.get(i).y, path.get(i).x + longitud, path.get(i).y);
      
      }
    
    
    }
    
    else {
      
      float longitud = map(0.3, 0, baseAudio.duration() * 4, 0, width);
      
      for (int i = 0; i < path.size(); i++) {
      
        canvas.line(path.get(i).x, path.get(i).y, path.get(i).x + longitud, path.get(i).y);
      
      }    
    
    
    }
    
    
  
  }

}