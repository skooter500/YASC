class Ship extends GameObject
{  
  float fireRate = 5.0f;
  float toPass = 1.0f / fireRate;
  float elapsed = toPass;
  
  int lives = 10;
  int hyper  = 5;
  int ammo = 100;
  
  char forward;
  char left;
  char right;
  char fire;
  char hyperDrive;
  color colour;
  boolean shield = false;
  boolean drawShield = true;
  int shieldEllapsedFrames;
  int shieldToPassFrames;
  AudioPlayer shootSound;
  AudioPlayer hyperDriveSound;
  
  int spawnIndex;

  ControlDevice device;
  
  boolean jet;

  float halfwidth, halfheight;
    
  Ship()
  {
    w = 20;
    h = 20;
    halfwidth = w / 2.0f;
    halfheight = h / 2.0f;
    shieldToPassFrames = 300;
    shieldEllapsedFrames = 0;
    position.x = width / 2;
    position.y = height / 2;

    angularVelocity = 5.0f;
    mass = 1.0f;
    
    vertices.add(new PVector(- halfwidth, halfheight));
    vertices.add(new PVector(0, - halfheight));
    vertices.add(new PVector(halfwidth, halfheight));
    vertices.add(new PVector(0, - halfheight));
    
    vertices.add(new PVector(- halfwidth, halfheight));
    vertices.add(new PVector(0, 0));
    vertices.add(new PVector(halfwidth, halfheight));
    vertices.add(new PVector(0, 0));
      
  }
  
  float angularVelocity;
  float maxSpeed = 500;
  float maxForce;
  
  Ship(ControlDevice device)
  {
    this();
    this.device = device;
  }
  
  boolean lastPressed = false;
  
  
  void update()
  {                 
      elapsed += timeDelta;
      float newtons = 800.0f;
      
      if ((device.getSlider(4).getValue() < -0.5f) || (device.getSlider(4).getValue() > 0.5f))
      {     
          force.add(PVector.mult(look, newtons));
          jet = true;
      }      
      else
      {
        jet = false;
      }     
           
      
      if (device.getSlider(1).getValue() < - 0.5f)
      {
        theta -= timeDelta * angularVelocity;
      }    
      
      if (device.getSlider(1).getValue() > 0.5f)
      {
        theta += timeDelta * angularVelocity;
      }
      
      if (device.getButton(1).pressed() && hyper > 0 && ! lastPressed)
      {
        playSound(hyperDriveSound);
          position.x = random(0, width);
          position.y = random(0, height);        
        hyper --;
        lastPressed = true;
      }
      if (! device.getButton(1).pressed())
      {
        lastPressed = false;
      }      
      
      look.x = sin(theta);
      look.y = -cos(theta);
      
      if (device.getButton(0).pressed() && elapsed > toPass && ammo > 0)
      {
        playSound(shootSound);
        Lazer lazer = new Lazer();
        lazer.position = position.get();
        PVector offset = look.get();
        offset.mult(w);
        lazer.position.add(offset);
        lazer.theta = theta;
        lazer.colour = colour;
        PVector lazerVelocity = PVector.mult(look, 400);
        lazer.velocity = lazerVelocity;
        addGameObject(lazer);
        elapsed = 0.0f;
        ammo --;
      }
      
      PVector acceleration = PVector.div(force, mass);
      velocity.add(PVector.mult(acceleration, timeDelta));   
   
     if (velocity.mag() > maxSpeed)
      {
        velocity.normalize();
        velocity.mult(maxSpeed);
      }   
      
      position.add(PVector.mult(velocity, timeDelta));
      // Apply damping
      velocity.mult(0.99f);
      
      // Reset the force
      force.setMag(0);
                  
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
      if (shield)
      {
        shieldEllapsedFrames ++;
        if (shieldEllapsedFrames % 10 == 0)
        {
          drawShield = ! drawShield;
        }
        if (shieldEllapsedFrames >= shieldToPassFrames)
        {
          shield = ! shield;
        }
        
      }      
      super.update();             
  }
  
  void pointAtSun()
  {
    PVector toCentre = new PVector(width / 2, height / 2);
    toCentre.sub(position);
    theta = toCentre.heading() + HALF_PI;     
  }
  
  void resetShield(float duration)
  {
    shield = true;
    drawShield = true;
    shieldEllapsedFrames = 0;
    this.shieldToPassFrames = (int) duration * 60;
  }
  
  void draw()
  {
    stroke(255);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    scale(scaleF);
    stroke(colour);
    noFill();
    
    if (shield && drawShield)
    {
      ellipse(0,0, w * 2, h * 2);
    }
    
    for (int i = 1 ; i < vertices.size() ; i += 2)
    {
        PVector from = vertices.get(i - 1);
        PVector to = vertices.get(i);            
        line(from.x, from.y, to.x, to.y);
    }
    
    
    if (jet)
    {
      line(-2, 5, 0, 10);
      line(+2, 5, 0, 10);
    }
    popMatrix();
    
    super.draw();    
  } 
}