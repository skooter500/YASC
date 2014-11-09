class Lazer extends GameObject
{
  float aliveFor = 0;
  float toLive;
  
  Lazer()
  {
    w = 5.0f;
    h = 5.0f;
    mass = 0.2f;
    speed = 300.0f;
    toLive = 5.0f;
  }
  
  void update()
  {
    
    aliveFor += timeDelta;    
    if (aliveFor > toLive)
    {
      alive = false;
    }
    integrate();
    wrap();    
    
    theta = velocity.heading() + HALF_PI;
    force.setMag(0);
    look.x = sin(theta);
    look.y = -cos(theta);
  }
  
  void draw()
  {
    stroke(colour);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    scale(scaleF);
    
    line(0, - h / 2.0f, 0, h / 2.0f);
      
    popMatrix();        
  }
}
