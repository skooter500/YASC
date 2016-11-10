class ShieldPowerup extends GameObject implements Powerup
{
  float halfGap = 30.0f;
  float radius;
  
  ShieldPowerup()
  {
    w = 20;
    h = 20;    
    position = randomOffscreenPoint(w);      
    theta = 0.0f;
    radius = w / 2.0f;
    colour = color(195, 79,226);
    mass = 10.0f;
    drawVectors = true;
    
    float scale = 0.4f;

    float interval = 20; 
    float angle = 60;
    for(float theta = -angle ; theta < angle ; theta += interval)
    {     
      PVector start = new PVector();
      start.x = sin(radians(theta)) * radius;
      start.y = - cos(radians(theta)) * radius;
      
      PVector end = new PVector();
      end.x = sin(radians(theta + interval)) * radius;
      end.y = - cos(radians(theta + interval)) * radius;
      
      vertices.add(start);
      vertices.add(end);      
    } 
    
    vertices.add(new PVector(sin(radians(-angle)) * radius, - cos(radians(-angle)) * radius));
    vertices.add(new PVector(sin(radians(-angle)) * radius * scale, 0));
    
    vertices.add(new PVector(sin(radians(angle)) * radius, - cos(radians(angle)) * radius));    
    vertices.add(new PVector(sin(radians(angle)) * radius * scale, 0));
   
    //vertices.add(new PVector(sin(angle) * radius, - cos(angle) * radius));
    //vertices.add(new PVector(sin(angle) * radius * scale, - cos(angle) * radius * scale));
   
   
    for(float theta = 180 - angle ; theta <180 + angle ; theta += interval)
    {
      PVector start = new PVector();
      start.x = sin(radians(theta)) * radius;
      start.y = - cos(radians(theta)) * radius;

      PVector end = new PVector();
      end.x = sin(radians(theta + interval)) * radius;
      end.y = - cos(radians(theta + interval)) * radius;
      
      vertices.add(start);
      vertices.add(end);      
    }  
   
    
    vertices.add(new PVector(sin(radians(180-angle)) * radius, - cos(radians(180-angle)) * radius));
   vertices.add(new PVector(sin(radians(180-angle)) * radius * scale, 0));
    
    vertices.add(new PVector(sin(radians(180 + angle)) * radius, - cos(radians(180  + angle)) * radius));    
    vertices.add(new PVector(sin(radians(180 + angle)) * radius * scale, 0));
    
  }
  
  PVector calcPos(float angle, float radius)
  {
    return new PVector(radius * sin(radians(angle)), - radius * cos(radians(angle)));
  }
  
  
  void update()
  {
   theta -= timeDelta;   
   integrate();
  }
  
  void applyTo(Ship ship)
  {
    ship.resetShield(10);
  }
  
  void draw()
  {
    stroke(colour);
    noFill();
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    
    for (int i = 1 ; i < vertices.size() ; i += 2)
    {
        PVector from = vertices.get(i - 1);
        PVector to = vertices.get(i);            
        line(from.x, from.y, to.x, to.y);
    }
    
    
    popMatrix();        
  }    
}
