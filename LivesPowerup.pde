class LivesPowerup extends GameObject implements Powerup
{
  LivesPowerup()
  {
    w = 20;
    h = 20;
    float radius = w / 2;
    position = randomOffscreenPoint(w);        
    theta = 0.0f;
    colour = color(255);
    mass = 10.0f;
    
    vertices.add(new PVector(- radius, - radius));
    vertices.add(new PVector(radius, -radius));
    
    vertices.add(new PVector(radius, - radius));
    vertices.add(new PVector(radius, radius));
    
    vertices.add(new PVector(radius, radius));
    vertices.add(new PVector(-radius, radius));
    
    vertices.add(new PVector(- radius, radius));
    vertices.add(new PVector(-radius, -radius));
    
    vertices.add(new PVector(0, - radius));
    vertices.add(new PVector(0, radius));
    
    vertices.add(new PVector(-radius, 0));
    vertices.add(new PVector(radius, 0));    
  }  
  
  void applyTo(Ship ship)
  {
    ship.lives += 1;
  }
  
  void update()
  { 
   theta += timeDelta;   
   integrate();
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
