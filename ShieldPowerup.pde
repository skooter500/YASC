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
    colour = color(12, 245, 209);
    mass = 10.0f;
    drawVectors = true;
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
  
  PVector calcPos(float angle, float radius)
  {
    return new PVector(radius * sin(radians(angle)), - radius * cos(radians(angle)));
  }
  
  void draw()
  {
    stroke(colour);
    noFill();
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    
    float scale = 3;
    arc(0, 0, w, h, radians(90 + halfGap), radians(270 - halfGap));
    arc(0, 0, w, h,radians(270 + halfGap), radians(450 - halfGap));
    
    PVector p = calcPos(-halfGap, radius);
    line(p.x, p.y, 0, - radius / scale);
    p = calcPos(halfGap, radius);
    line(p.x, p.y, 0, - radius / scale);
    
    p = calcPos(180-halfGap, radius);
    line(p.x, p.y, 0, radius / scale);
    p = calcPos(180 + halfGap, radius);
    line(p.x, p.y, 0, radius / scale);
    
    popMatrix();        
  }    
}
