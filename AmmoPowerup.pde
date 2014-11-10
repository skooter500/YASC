class AmmoPowerup extends GameObject implements Powerup
{
  AmmoPowerup()
  {
    w = 20;
    h = 20;
    position = randomOffscreenPoint(w);        
    theta = 0.0f;
    colour = color(245, 160, 12);
    mass = 10.0f;
  }  
  
  void applyTo(Ship ship)
  {
    ship.ammo += (int) random(50, 100);
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
    
    int sides = 5;
    float radius = w / 2.0f;
    float thetaInc = TWO_PI / (float) sides;
    float lastX = 0, lastY = - radius;
    float x, y;
    for (int i = 1 ; i <= sides ; i ++)
    {
      float theta1 = (float) i  * thetaInc;
      x = sin(theta1) * radius;
      y = -cos(theta1) * radius;
      line(lastX, lastY, x, y);  
      lastX = x;
      lastY = y; 
    }       
    popMatrix();
  }  
}
