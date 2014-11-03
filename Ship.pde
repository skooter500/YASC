class Ship extends GameObject
{  
  float spin = 0.1f;
  float fireRate = 5.0f;
  float toPass = 1.0f / fireRate;
  float elapsed = toPass;
  
  int lives = 5;
  int hyper  = 5;
  
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
  boolean jet;
  
  Ship()
  {
    w = 20;
    h = 20;
    shieldToPassFrames = 300;
    shieldEllapsedFrames = 0;
    position.x = width / 2;
    position.y = height / 2;    
    drawVectors = false;
    forward = 'w';
    left = 'a';
    right = 'd';
    fire = 's';    
    hyperDrive = 'e';
  }
  
  boolean lastPressed = false;
  
  void update()
  {                 
      elapsed += timeDelta;
      float newtons = 300.0f;
      if (checkKey(forward))
      {     
          force.add(PVector.mult(look, newtons));
          jet = true;
      }      
      else
      {
        jet = false;
      }
      if (checkKey(left))
      {
        theta -= timeDelta;
      }    
      
      if (checkKey(right))
      {
        theta += timeDelta;
      }
      
      if (checkKey(hyperDrive) && hyper > 0 && ! lastPressed)
      {
        position.x = random(0, width);
        position.y = random(0, height);        
        hyper --;
        lastPressed = true;
      }
      if (! checkKey(hyperDrive))
      {
        lastPressed = false;
      }
      
      
      look.x = sin(theta);
      look.y = -cos(theta);
      
      if (checkKey(fire)  && elapsed > toPass)
      {
        shootSound.rewind();
        shootSound.play();
        Lazer lazer = new Lazer();
        lazer.position = position.get();
        PVector offset = look.get();
        offset.mult(w);
        lazer.position.add(offset);
        lazer.theta = theta;
        lazer.colour = colour;
        PVector lazerVelocity = PVector.mult(look, 300);
        lazer.velocity = lazerVelocity;
        addGameObject(lazer);
        elapsed = 0.0f;
      }
      
      PVector acceleration = PVector.div(force, mass);
      velocity.add(PVector.mult(acceleration, timeDelta));      
      
      position.add(PVector.mult(velocity, timeDelta));
      println();
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
  
  void resetShield()
  {
    shield = true;
    drawShield = true;
    theta = 0;
    shieldEllapsedFrames = 0;
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
    float halfwidth, halfheight;
    halfwidth = w / 2.0f;
    halfheight = h / 2.0f;
    
    if (shield && drawShield)
    {
      ellipse(0,0, w * 2, h * 2);
    }
    
    line(- halfwidth, halfheight, 0, - halfheight);
    line(halfwidth, halfheight, 0, - halfheight);
    
    line(- halfwidth, halfheight, 0, 0);
    line(halfwidth, halfheight, 0, 0);
    if (jet)
    {
      line(-2, 5, 0, 10);
      line(+2, 5, 0, 10);
    }
    popMatrix();
    
    super.draw();    
  } 
}
