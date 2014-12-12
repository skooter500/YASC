class Explosion extends GameObject
{
  ArrayList<PVector> directions = new ArrayList<PVector>();
  float speed = 1.5f;
  
  float ellapsed = 0;
  float liveFor = 5.0f;
  
  Explosion(ArrayList<PVector> vertices, PVector pos, color colour)
  {
    this.position = pos;
    this.colour = colour;
    for(PVector vertex:vertices)
    {
      this.vertices.add(vertex.get());
    }
    for (int i = 0 ;  i < vertices.size() ; i +=2)
    {
        PVector dir = new PVector(random(-1, 1), random(-1, 1));
        dir.normalize();
        dir.mult(speed);
        directions.add(dir);
    }
  }

  void update()
  {    
    for (int i = 0 ; i < vertices.size() ; i ++)
    {
      PVector velocity = directions.get(i / 2);
      vertices.get(i).add(velocity);
    }
    ellapsed += timeDelta;
    if (ellapsed > liveFor)
    {
      alive = false;
    }
  }

  void draw()
  {
   stroke(255);
   pushMatrix(); 
   translate(position.x, position.y);
   rotate(theta);
   float alpha = (1.0f - ellapsed / liveFor) * 255.0f;
   stroke(red(colour), green(colour), blue(colour), (int)alpha);
   for (int i = 1 ; i < vertices.size() ; i += 2)
    {        
        PVector from = vertices.get(i - 1);
        PVector to = vertices.get(i);            
        line(from.x, from.y, to.x, to.y);
    }   
    popMatrix();  
  }
  
}
