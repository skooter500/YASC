class LivesPowerup extends GameObject implements Powerup
{
  LivesPowerup()
  {
    w = 20;
    h = 20;
    position = randomOffscreenPoint(w);        
    theta = 0.0f;
    colour = color(255, 0, 0);
    mass = 10.0f;
  }  
  
  void applyTo(Ship ship)
  {
    ship.lives += (int) random(1, 5);
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
    float radius = w / 2.0f;
    line(0, - radius, 0, radius);
    line(-radius, 0, radius, 0);    
    ellipse(0,0,w,w);
    popMatrix();
  }  
}
