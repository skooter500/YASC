class GameObject
{
  PVector position;
  PVector look;
  PVector right;
  PVector velocity;
  PVector force;
  float w;
  float h;
  float theta;
  float scaleF = 1.0f;
  float speed = 100.0f;
  boolean alive;
  boolean drawVectors;
  float mass;
  color colour;
  PVector basis = new PVector(0, -1);
  
  ArrayList<PVector> vertices = new ArrayList<PVector>();
  
  
  GameObject()
  {
    position = new PVector();
    look = new PVector(0, -1);    
    right = new PVector(1, 0);    
    velocity = new PVector(0,0);
    force = new PVector(0,0);
    colour = color(255,255,255);
    theta = 0.0f;
    mass = 1.0f;
    alive = true;
  }    
  
  void update()
  {
    // Calculate the vectors
    look.x = sin(theta);
    look.y = -cos(theta);  
    
    right.x = sin(theta + HALF_PI);
    right.y = -cos(theta + HALF_PI);  
    
    
    // Could also use this:
    //look = PVector.fromAngle(theta - HALF_PI);
    //right = PVector.fromAngle(theta);
  }
   
  void integrate()
  {
    PVector acceleration = PVector.div(force, mass);
    velocity.add(PVector.mult(acceleration, timeDelta));          
    position.add(PVector.mult(velocity, timeDelta));    
    force.setMag(0);      
  }
  
  PVector randomOffscreenPoint(float border)
  {
    int i = (int) random(0, 4);
    float x = 0, y = 0;
    switch(i)
    {
      case 0:
        x = random(0, width);
        y = -border;
        break;
      case 1:
        x = random(0, width);
        y = height + border;
        break;     
      case 2:        
        x = -border;
        y = random(0, height);
        break;
      case 3:
        x = width + border;
        y = random(0, height);
        break;
    }      
    return new PVector(x, y);    
  }
  
  void wrap()
  {
    if (position.x > width)
    {
      position.x = 0;
    }
    if (position.x < 0)
    {
      position.x = width;
    }
    
    if (position.y > height)
    {
      position.y = 0;
    }
    if (position.y < 0)
    {
      position.y = height;
    }
  }
  
  void draw()
  {
    if (drawVectors)
    {
      float lineLength = 50.0f;
      pushMatrix();
      translate(position.x, position.y);
      //rotate(theta);
      scale(scaleF);    
      stroke(0, 255, 0);
      line(0, 0, look.x * lineLength, look.y * lineLength);      
      stroke(255, 0, 0);
      line(0, 0, right.x * lineLength, right.y * lineLength);
      popMatrix();      
    }   
  }
  
  boolean collides(GameObject entity)
  {
    float combinedRadii = (w / 2.0f) + (entity.w / 2.0f);
    return PVector.dist(position, entity.position) < combinedRadii;
  }
  
  boolean collides(PVector point)
  {
    return PVector.dist(point, position) < w / 2.0f;
  }  
}