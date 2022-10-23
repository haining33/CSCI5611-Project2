PImage img;
int numRows = 30;
int numCols = 30;
float l0 = 10;


/* ks, kd, weight need modification */
float kd = 1000*2;
float ks = 10000*3500;
float weight = 0.04;
float gravityVal = 40;
float angle = -PI/6;

boolean w = false;
boolean a = false;
boolean s = false;
boolean d = false;
boolean turnRight = false;
boolean turnLeft = false;
/*camera code*/
float camX = -503.0;
float camY = 100.0; //58
float camZ = 579;

float pc = 0.00000005;


float dt = 1/(frameRate*30);

Vec3 spherePos = new Vec3(-200, 100, 75);
Vec3 pos[][] = new Vec3[numRows][numCols];
Vec3 vn[][] = new Vec3[numRows][numCols];
Vec3 vel[][] = new Vec3[numRows][numCols];

public void update(float dt){
    setVel();
    updateHoriz();
    updateVerti();
    collisionDetect();
    drag();
    gravity();
    updateVel();
}

void setup(){
    size(1000, 1000, P3D);
    img = loadImage("flag.png");
    initClothNodes();
}

 

// int i = 0;
void draw(){

    background(255, 255, 255);
    lights();
    // updateSimpleCamera();
    camera(camX,camY,camZ, -200, 100, 75 ,0,1,0);
    rotateY(angle);
    update(dt);

    /*draw sphere*/
    pushMatrix();
    noStroke();
    fill(50,205,50);
    translate(spherePos.x, spherePos.y, spherePos.z);
    sphere(45);
    popMatrix();

    if(w){
        spherePos.y -= 5;
        // print("spherePos:" + spherePos.y);
    }
    if(s){
        spherePos.y += 5;
        // print("spherePos:" + spherePos.y);
    }
    if(d){
        spherePos.x += 5;
        // print(spherePos.x);
    }if(a){
        spherePos.x -= 5;
        // print(spherePos.x);
    }
    if(turnLeft){
      angle += PI/18;
    }
    if(turnRight){
      angle -= PI/18;
    }
    /*draw cloth*/
    for (int i = 0; i < numRows - 1; i++){
        for (int j = 0; j < numCols - 1; j++){
            beginShape(QUADS);
            fill(255,0,255);
            vertex(pos[i][j].x, pos[i][j].y, pos[i][j].z);
            vertex(pos[i+1][j].x, pos[i+1][j].y, pos[i+1][j].z);
            vertex(pos[i+1][j+1].x, pos[i+1][j+1].y, pos[i+1][j+1].z);
            vertex(pos[i][j+1].x, pos[i][j+1].y, pos[i][j+1].z);
            endShape();
        }
    }
}

void keyPressed(){
    // if (keyCode == UP){
    //     camX += dirX; camY += dirY; camZ += dirZ; //Move the camera in the forward direction
    //     print(camX);
    //     print(camY);
    // }
    // if (keyCode == DOWN){
    //     camX -= dirX; camY -= dirY; camZ -= dirZ; //Move the camera in the backward direction
    //     print(camX);
    //     print(camY);
    // }

    if (key == 'r'){
        print("resetting\n");
        for (int i = 0; i < numRows; i++){
            for (int j = 0; j < numCols; j++){
                vel[i][j] = new Vec3(0, 0, 0);
                vn[i][j] = new Vec3(0, 0, 0);
                pos[i][j] = new Vec3(i * -10, 0, j * 10);
            }
        }
    }

    if (key == 'w') {
        w = true;
    }
    if (key == 's') {
        s = true;
    }
    if (key == 'd') {
        d = true;
    }
    if (key == 'a') {
        a = true;
        //print("Z:"+ camZ);
    }
     if (keyCode == RIGHT) {
       turnRight = true;
     }  
     if (keyCode == LEFT) {
         turnLeft = true;
         //print(angle);
     }
   
    // dirX = sin(angle); //Compute the forward direction form the angle
    // dirZ = cos(angle);
}

void keyReleased() {
    if (key == 'w') {
        w = false;
    }
    if (key == 's') {
        s = false;
    }
    if (key == 'd') {
        d = false;
    }
    if (key == 'a') {
        a = false;
    }
    if (keyCode == LEFT) {
         turnLeft = false;
         //print(angle);
     }
     if (keyCode == RIGHT) {
       turnRight = false;
     } 
}

void initClothNodes(){
    /* initialize node pos and velocities*/
    for (int i = 0; i < numRows; i++){
        for (int j = 0; j < numCols; j++){
            pos[i][j] = new Vec3(i*-10, 0, j * 10);
            vel[i][j] = new Vec3(0, 0, 0);
            vn[i][j] = new Vec3(0, 0, 0);
    }
  }
}

void setVel(){
    /* set new velocity to old velocity*/
    for (int i = 0; i < numRows; i++){
        for (int j = 0; j < numCols; j++){
            vn[i][j] = vel[i][j];
        }
    }
}

void collisionDetect(){
    /* detect collisions*/
    for (int i = 0 ; i < numRows; i++){
        for (int j = 0 ; j < numCols; j++){
            float distance = spherePos.distanceTo(pos[i][j]);
            if (distance < 50 + 0.99 + 5){
                Vec3 n = (spherePos.minus(pos[i][j])).times(-1);
                n = n.normalized();
                Vec3 bounce = n.times(dot(vel[i][j], n));
                vel[i][j] = vel[i][j].minus(bounce.times(1.5));
                // vel[i][j].subtract(bounce.times(1.5));
                float temp = 55 - distance;
                pos[i][j] = pos[i][j].plus(n.times(temp));
                // pos[i][j].add(n.times(temp));
            }
        }
    }
}

void updateHoriz(){
    /*update horizontal velocities*/
    for (int i = 0; i < numRows - 1; i ++){
        for (int j = 0; j < numCols; j ++){    
            Vec3 e = pos[i+1][j].minus(pos[i][j]);
            float l = e.length();
            e.mul(1.0/l);
            float v1 = dot(vel[i][j],e);
            float v2 = dot(vel[i+1][j],e);
            float f = weight * (-ks*(l0-l) - kd * (v1-v2));
            Vec3 temp = e.times(f * dt);
            // vn[i][j] = vn[i][j].plus(temp);
            vn[i][j].add(temp);
            // vn[i+1][j] = vn[i+1][j].minus(temp);
            vn[i+1][j].subtract(temp);
        }
    }
}

void updateVerti(){
    /*update vertical velocities*/
    for (int i = 0; i < numRows; i++){
        for (int j = 0; j < numCols - 1; j++){      
            Vec3 e = pos[i][j+1].minus(pos[i][j]);
            float l = e.length();
            e.mul(1.0/l);
            float v1 = dot(vel[i][j],e);
            float v2 = dot(vel[i][j+1],e);
            float f = weight *(-ks*(l0-l) - kd * (v1-v2));
            Vec3 temp = e.times(f * dt);
            // vn[i][j] = vn[i][j].plus(temp);
            vn[i][j].add(temp);
            // vn[i][j+1] = vn[i][j+1].minus(temp);
            vn[i][j+1].subtract(temp);
        }
    }
}

void drag(){
    for (int i = 0; i < numRows-1; i++){
        for (int j = 0; j < numCols-1; j++){
        Vec3 c1 = pos[i][j + 1].minus(pos[i][j]);
        Vec3 c2 = pos[i+1][j].minus(pos[i][j]);
        Vec3 n = c1.cross(c2);
     
        Vec3 v = vn[i][j].plus(vn[i][j+1].plus(vn[i+1][j]));
        v = v.div(3);
        float vvn = dot(v,n) * v.mag();
        vvn /= 2;
        vvn /= n.mag();
        Vec3 van = n.times(vvn);
     
        van = van.times(-0.5);
        van = van.times(pc);
     
        vn[i][j] = vn[i][j].plus(van);
        vn[i][j+1] = vn[i][j+1].plus(van);
        vn[i+1][j] = vn[i+1][j].plus(van);
     
        }    
    }
}

void gravity(){
    /*add gravity*/
    Vec3 gravity = new Vec3(0, gravityVal, 0);
    for (int i = 0; i < numRows; i++){
        for (int j = 0; j < numCols; j++){
            vn[i][j] = vn[i][j].plus(gravity);
        }
    }
}

void updateVel(){
    for (int i = 0; i < numRows; i++){
        vn[0][i] = new Vec3(0, 0, 0);
    }
    for (int i = 0; i < numRows; i++){
        for (int j = 0; j < numCols; j++){
            pos[i][j] = pos[i][j].plus(vn[i][j].times(dt));
            vel[i][j] = vn[i][j];
        }
    }
}
