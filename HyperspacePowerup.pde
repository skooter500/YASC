class HyperspacePowerup extends GameObject implements Powerup
{
  HyperspacePowerup()
  {
    w = 20;
    h = 20;
    position = randomOffscreenPoint(w);        
    theta = 0.0f;
    colour = color(255, 51, 51);
    mass = 10.0f;
    toPass = random(10, 20);
    
    vertices.add(new PVector(- w * 0.3f, -h * 0.4));
    vertices.add(new PVector(w * 0.3f, -h * 0.4));
    vertices.add(new PVector(- w * 0.1f, -h * 0.2));
    vertices.add(new PVector( w * 0.1f, -h * 0.2));
    vertices.add(new PVector(- w * 0.3f, -h * 0.4));
    vertices.add(new PVector( - w * 0.1f, -h * 0.2));
    vertices.add(new PVector(w * 0.3f, -h * 0.4));
    vertices.add(new PVector( w * 0.1f, -h * 0.2));
      //ellipse(0, 0, w * 0.1f, h * 0.1f)
      //stroke(colour);
    vertices.add(new PVector(- w * 0.3f, h * 0.4));
    vertices.add(new PVector( w * 0.3f, h * 0.4));
    vertices.add(new PVector(- w * 0.1f, h * 0.2));
    vertices.add(new PVector( w * 0.1f, h * 0.2));
    vertices.add(new PVector(- w * 0.3f, h * 0.4));
    vertices.add(new PVector( - w * 0.1f, h * 0.2));
    vertices.add(new PVector(w * 0.3f, h * 0.4));
    vertices.add(new PVector( w * 0.1f, h * 0.2));
      

  }  
  
  float lastJumped;
  float toPass;
  
  void applyTo(Ship ship)
  {
    ship.hyper += 1;
  }
  
  void update()
  { 
   theta -= timeDelta * 2;   
   integrate();
   
   /*
   if (lastJumped > toPass)
   {
      toPass = random(5, 20);
      lastJumped = 0;
      position.x = random(0, width);
      position.y = random(0, height);
   }  
    lastJumped += timeDelta;
  */  
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
