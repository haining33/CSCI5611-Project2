//PDEs and Integration
//CSCI 5611 Swinging Rope [Exercise]
//Stephen J. Guy <sjguy@umn.edu>

//NOTE: The simulation starts paused, press "space" to unpause

//TODO:
//  1. The rope moves very slowly now, this is because the timestep is 1/20 of realtime
//      a. Make the timestep realtime (20 times faster than the inital code), what happens?
//      b. Call the small 1/20th timestep update, 20 times each frame (in a for loop) -- why is it different?
//  2. When the rope hanging down fully the spacing between the links is not equal, even though they
//     where initalized with an even spacing between each node. What is this?
//      - If this is a bug, fix the corisponding code
//      - If this why is not a bug, explain why this is the expected behavior
//  3. By default, the rope starts vertically. Change initScene() so it starts at an angle. The rope should
//     then swing backc and forth.
//  4. Try changing the mass and the k value. How do they interact wich each other?
//  5. Set the kv value very low, does the rope bounce a lot? What about a high kv (not too high)?
//     Why doesn't the rope stop swinging at high values of kv?
//  6. Add friction/drag so that the rope eventually stops. An easy friction model is a scaled force 
//     in the opposite direction of a nodes current velocity. 

//Challenge:
//  - Set the top of the rope to be wherever the user's mouse is, and allow the user to drag the rope around the scene.
//  - Keep the top of the rope fixed, but allow the user to click and drag one of the balls of the rope to move it around.
//  - Place a medium-sized, static 2D ball in the scene, have the nodes on the rope experience a "bounce" force if they collide with this ball.


//Create Window
String windowTitle = "Swinging Rope";
void setup() {
  size(400, 500, P3D);
  surface.setTitle(windowTitle);
  initClothNodes()
  //initScene();
}

//Simulation Parameters
int numRows = 40;
int numCols = 40;
float k = 10; //spring constant
float kv = 12; //damping factor
float l0 = 10; //rest length


Vec3 spherePos = new Vec3(50, -200, -150)
float sphereR = 100;
float clothX = 100; 
float clothY = -50; 
float clothZ = -200;
float dt = 1/frameRate;
float gravity = 0.02

//Initial positions and velocities of masses
static int maxNodes = 40;
Vec3 pos[][] = new Vec3[maxNodes][maxNodes];
Vec3 vel[][] = new Vec3[maxNodes][maxNodes];
// Vec2 acc[] = new Vec2[maxNodes];


// void initScene(){
//   for (int i = 0; i < numNodes; i++){
//     pos[i] = new Vec2(0,0);
//     pos[i].x = stringTop.x + 8*i;
//     pos[i].y = stringTop.y + 8*i; //Make each node a little lower
//     vel[i] = new Vec2(0,0);
//   }
// }
boolean mouse  = false;

void initClothNodes(){
  for (int j=0; j< numCols; j++){
    for (int i=0; i<numRows; i++){
      pos[i][j]= new Vec3(clothX + l0 * j + clothZ, clothY, clothZ + l0 * i);
      vel[i][j] = new Vec3(0,0,0);
    }
  }
}
void update(float dt){

  //Reset accelerations each timestep (momenum only applies to velocity)
  // for (int i = 0; i < numNodes; i++){
  //   acc[i] = new Vec2(0,0);
  //   acc[i].add(gravity);
  // }
  

  //horizontal 
  Vec3[][] vn = new Vec3[numRows][numCols]; //new velocity buffer
  arrayCopy(vel, vn);
  for (int i = 0; i < numRows-1; i++){
    for (int j = 0; j < numCols; j++){
      Vec3 e = pos[i+1][j].minus(pos[i][j]);
      float l = e.length();
      e.mul(1.0/l);
      float v1 = dot(vel[i][j],e);
      float v2 = dot(vel[i+1][j],e);
      float f_down = -ks*(l0-l)-kd*(v1-v2);
      temp = e.times(f_down*dt);
      vn[i][j].add(temp);
      vn[i+1][j].subtract(temp);
    }
  }
  //vertical force
  for (int i = 0; i < numRows; i++){
    for (int j = 0; j < numCols-1; j++){
      //Compute string length
      Vec3 e = pos[i][j+1].minus(pos[i][j]);
      float l = e.length();
      e.mul(1.0/l);
      float v1 = dot(vel[i][j],e);
      float v2 = dot(vel[i][j+1],e);
      float f_side = -ks*(l0-l)-kd*(v1-v2);
      Vec3 temp = e.times(f_side*dt);
      vn[i][j].add(temp);
      vn[i][j+1].subtract(temp);
    }
  }

//gravity
  for (int i = 0; i < numRows; i++){
    for (int j = 0; j < numCols; j++){
      vn[i][j].y += gravity;
    }
  }
  //collision detection
  for (int i = 0; i < numRows; i++){
    for (int j = 0; j < numCols; j++){
      d = spherePos.distanceTo(pos[i][j])
      if(d < sphereR + 0.09){
        Vec3 n = (spherePos.minus(pos[i][j])).times(-1);
        n.normalize();
        Vec3 bounce = v[i][j]
      }
  
  
  //Compute (damped) Hooke's law for each spring
  // for (int i = 0; i < numNodes-1; i++){
  //   Vec2 diff = pos[i+1].minus(pos[i]);
  //   float stringF = -k*(diff.length() - restLen);
  //   //println(stringF,diff.length(),restLen);
    
  //   Vec2 stringDir = diff.normalized();
  //   float projVbot = dot(vel[i], stringDir);
  //   float projVtop = dot(vel[i+1], stringDir);
  //   float dampF = -kv*(projVtop - projVbot);
  //   //float dampFx = kfric*(vel[i].x - 0);
  //   //float dampFy = kfric*(vel[i].y - 0);
    
  //   float forceX = stringDir.x*(stringF+ dampF);
  //   float forceY = stringDir.y*(stringF+ dampF);
  //   Vec2 force = new Vec2(forceX, forceY);
  //   acc[i].add(force.times(-1.0/mass));
  //   acc[i+1].add(force.times(1.0/mass));
    
  // }
  // if(mouse){
  //   Vec2 mousePos = new Vec2(mouseX, mouseY);
  //   pos[numNodes-1] = mousePos;
  // }

  // //Eulerian integration
  // for (int i = 1; i < numNodes; i++){
  //   vel[i].add(acc[i].times(dt));
  //   pos[i].add(vel[i].times(dt));
  // }
  
  // //Collision detection and response
  // for (int i = 0; i < numNodes; i++){
  //   if (pos[i].y+radius > floor){
  //     vel[i].y *= -.9;
  //     pos[i].y = floor - radius;
  //   }
  // }
  
}



//Draw the scene: one sphere per mass, one line connecting each pair
boolean paused = true;

void draw() {
//   background(255,255,255);
//   if (!paused) update(1/frameRate);
//   fill(0,0,0);
  
//   for (int i = 0; i < numNodes-1; i++){
//     pushMatrix();
//     line(pos[i].x,pos[i].y,pos[i+1].x,pos[i+1].y);
//     translate(pos[i+1].x,pos[i+1].y);
//     sphere(radius);
//     popMatrix();
//   }
  
//   if (paused)
//     surface.setTitle(windowTitle + " [PAUSED]");
//   else
//     surface.setTitle(windowTitle + " "+ nf(frameRate,0,2) + "FPS");
// }

// void keyPressed(){
//   if (key == ' ')
//     paused = !paused;
//   if (key == 'r')
//     mouse = !mouse;
}


///////////////////
// Vec2D Library
///////////////////

public class Vec2 {
  public float x, y;
  
  public Vec2(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public String toString(){
    return "(" + x+ ", " + y +")";
  }
  
  public float length(){
    return sqrt(x*x+y*y);
  }
  
  public float lengthSqr(){
    return x*x+y*y;
  }
  
  public Vec2 plus(Vec2 rhs){
    return new Vec2(x+rhs.x, y+rhs.y);
  }
  
  public void add(Vec2 rhs){
    x += rhs.x;
    y += rhs.y;
  }
  
  public Vec2 minus(Vec2 rhs){
    return new Vec2(x-rhs.x, y-rhs.y);
  }
  
  public void subtract(Vec2 rhs){
    x -= rhs.x;
    y -= rhs.y;
  }
  
  public Vec2 times(float rhs){
    return new Vec2(x*rhs, y*rhs);
  }
  
  public void mul(float rhs){
    x *= rhs;
    y *= rhs;
  }
  
  public void normalize(){
    float magnitude = sqrt(x*x + y*y);
    x /= magnitude;
    y /= magnitude;
  }
  
  public Vec2 normalized(){
    float magnitude = sqrt(x*x + y*y);
    return new Vec2(x/magnitude, y/magnitude);
  }
  
  public void clampToLength(float maxL){
    float magnitude = sqrt(x*x + y*y);
    if (magnitude > maxL){
      x *= maxL/magnitude;
      y *= maxL/magnitude;
    }
  }
  
  public void setToLength(float newL){
    float magnitude = sqrt(x*x + y*y);
    x *= newL/magnitude;
    y *= newL/magnitude;
  }
  
  public float distanceTo(Vec2 rhs){
    float dx = rhs.x - x;
    float dy = rhs.y - y;
    return sqrt(dx*dx + dy*dy);
  }
  
}

Vec2 interpolate(Vec2 a, Vec2 b, float t){
  return a.plus((b.minus(a)).times(t));
}

float interpolate(float a, float b, float t){
  return a + ((b-a)*t);
}

float dot(Vec2 a, Vec2 b){
  return a.x*b.x + a.y*b.y;
}

Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(a.x*b.x + a.y*b.y);
}
