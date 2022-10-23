static int n = 60; //number of cells
float dx = 800.0/n; //500 pixels long
//  
// float dt = 0.01; //update rate

float g = 10;
float h[] = new float[n]; //Height
float hu[] = new float[n]; //Momentum
float dhdt[] = new float[n]; //Height
float dhudt[] = new float [n]; //Momentum
//Midpoint helpers
float h_mid[] = new float[n]; //Height
float hu_mid[] = new float[n]; //Momentum
float dhdt_mid[] = new float[n]; //Height
float dhudt_mid[] = new float [n]; //Momentum

boolean periodic = true;
boolean free = false;
boolean reflective = false;

void initHeight(){
                                                                                                                                            
  for (int i=0; i<n; i++){
    h[i]= 200;
    //h[i]=random(200,280);
    hu[i] = 0;
  }
}
void update(float dt){
    //Compute midpoint heights and momentums
    for (int i = 0; i < n-1; i++){ 
      h_mid[i] = (h[i+1]+h[i])/2;
      hu_mid[i] = (hu[i+1]+hu[i])/2;
    }
    for (int i = 0; i < n-1; i++){
        //Compute dh/dt (mid)
      float dhudx_mid = (hu[i+1] - hu[i])/dx;
      dhdt_mid[i] = -dhudx_mid;
      //Compute dhu/dt (mid)
      float dhu2dx_mid = (sq(hu[i+1])/h[i+1] - sq(hu[i])/h[i])/dx;
      float dgh2dx_mid = g*(sq(h[i+1]) - sq(h[i]))/dx;
      dhudt_mid[i] = -(dhu2dx_mid + .5*dgh2dx_mid);
    }
    //Integrate midpoint
    for (int i = 0; i < n-1; i++){
        h_mid[i] += dhdt_mid[i]*dt/2;
        hu_mid[i] += dhudt_mid[i]*dt/2;
    }
    for (int i = 1; i < n-1; i++){
        //Compute dh/dt
        float dhudx = (hu_mid[i] - hu_mid[i-1])/dx;
        dhdt[i] = -dhudx;
        //Compute dhu/dt
        float dhu2dx = (sq(hu_mid[i])/h_mid[i] - sq(hu_mid[i-1])/h_mid[i-1])/dx;
        float dgh2dx = g*(sq(h_mid[i]) - sq(h_mid[i-1]))/dx;
        dhudt[i] = -(dhu2dx + .5*dgh2dx);
    }

    //Integrate heights and momentum
    float damp = 0.9;
    for (int i = 0; i < n-1; i++){
        h[i] += damp*dhdt[i]*dt;
        hu[i] += damp*dhudt[i]*dt;
    }
    //Periodic Boundary
    h[0] = h[n-2];
    h[n-1] = h[1];
    hu[0] = hu[n-2];
    hu[n-1] = hu[1];
}

void setup(){
    size(800,400);
    background(255);
    initHeight();
}
void draw(){
  background(255);
  noStroke();
  fill(105,206,235);  
  update(1/frameRate);
  // float a = h[0]+(h[0]-h[1])/2;
  for (int i=0; i<n-1; i++){
    // float b = (h[i]+h[i+1])/2;
    //update(dt);
    beginShape(QUADS);
    vertex(dx*i,height-h[i]);
    vertex(dx*(i+1)+1,height-h[i+1]);
    vertex(dx*(i+1)+1,height);
    vertex(dx*i,height);
    endShape(CLOSE); 
    // a = b;
  }

}
void keyReleased()
{
  if (key == 'r'){
    println("Reseting the System.");
    initHeight();
    //periodic = true; free = false; reflective = false;
  }
  if(keyCode == UP){
    h[n/2] = 500;
  }
}