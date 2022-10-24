int numRows = 30;
int numCols = 30;
float l0 = 10;


/* ks, kd, weight need modification */
float kd = 2500;
float ks = 32000000;
float weight = 0.04;
float gravityVal = 40;
float c = 0.00000007;
float angleY = -PI/6;
float angleX = 0;

boolean w = false;
boolean a = false;
boolean s = false;
boolean d = false;
boolean turnRight = false;
boolean turnLeft = false;
boolean turnUp = false;
boolean turnDown = false;

/*camera code*/
float camX = -800.0;
float camY = 50.0;
float camZ = 100;
float dt = 1/(frameRate*30);

Vec3 spherePos = new Vec3(-175, 100, 175);
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
    initClothNodes();
}


void draw(){
    background(135, 206, 235);
    lights();
    camera(camX,camY,camZ, -200, 100, 75 , 0, 1, 0);
    rotateY(angleY);
    update(dt);

    /*draw sphere*/
    pushMatrix();
    noStroke();
    fill(50,205,50);
    translate(spherePos.x, spherePos.y, spherePos.z);
    sphere(35);
    popMatrix();
    drawCloth();

    /* control ball*/
    if(w){
        spherePos.y -= 3;
        // print("spherePos:" + spherePos.y);
    }
    if(s){
        spherePos.y += 3;
        // print("spherePos:" + spherePos.y);
    }
    if(d){
        spherePos.x += 3;
        // print(spherePos.x);
    }if(a){
        spherePos.x -= 3;
        // print(spherePos.x);
    }

    /* control camera*/
    if(turnLeft){
      angleY += PI/144;
    }
    if(turnRight){
      angleY -= PI/144;
    }
    if(turnUp){
      camX += 5;
    }
    if(turnDown){
      camX -= 5;
    }
}

void keyPressed(){
    if (key == 'r'){
        print("resetting\n");
        for (int i = 0; i < numRows; i++){
            for (int j = 0; j < numCols; j++){
                vel[i][j] = new Vec3(0, 0, 0);
                vn[i][j] = new Vec3(0, 0, 0);
                pos[i][j] = new Vec3(i*-10, 0, j*10);
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
    }
    if (keyCode == RIGHT) {
        turnRight = true;
    }  
    if (keyCode == LEFT) {
        turnLeft = true;
    }
    if (keyCode == UP) {
        turnUp = true;
    }
    if (keyCode == DOWN) {
        turnDown = true;
    }
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
     }
    if (keyCode == RIGHT) {
       turnRight = false;
    }
    if (keyCode == UP) {
        turnUp = false;
    }
    if (keyCode == DOWN) {
        turnDown = false;
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

void drawCloth(){
     /*draw cloth*/
    for (int i = 0; i < numRows - 1; i++){
        for (int j = 0; j < numCols - 1; j++){
            beginShape(TRIANGLE_FAN);
            if (j % 2 == 0){
                fill(255, 255, 0);
            }
            else{
                fill(255, 89, 143);
            }
            if (i % 2 == 0){
                fill(255, 255, 0);
            }
            else{
                fill(255, 89, 143);
            }
            vertex(pos[i][j].x, pos[i][j].y, pos[i][j].z);
            vertex(pos[i+1][j].x, pos[i+1][j].y, pos[i+1][j].z);
            vertex(pos[i+1][j+1].x, pos[i+1][j+1].y, pos[i+1][j+1].z);
            vertex(pos[i][j+1].x, pos[i][j+1].y, pos[i][j+1].z);
            endShape();
        }
    }
}

void collisionDetect(){
    /* detect collisions*/
    for (int i = 0 ; i < numRows; i++){
        for (int j = 0 ; j < numCols; j++){
            float distance = spherePos.distanceTo(pos[i][j]);
            if (distance < 45 + 0.99){
                Vec3 n = (spherePos.minus(pos[i][j])).times(-1);
                n = n.normalized();
                Vec3 bounce = n.times(dot(vel[i][j], n));
                vel[i][j] = vel[i][j].minus(bounce.times(1.5));
                float temp = 45 - distance;
                pos[i][j] = pos[i][j].plus(n.times(temp));
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
            vn[i][j].add(temp);
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
            vn[i][j].add(temp);
            vn[i][j+1].subtract(temp);
        }
    }
}

void drag(){
    /*add air drag*/
    for (int i = 0; i < numRows-1; i++){
        for (int j = 0; j < numCols-1; j++){
        Vec3 r2r1 = pos[i][j + 1].minus(pos[i][j]);
        Vec3 r3r1 = pos[i+1][j].minus(pos[i][j]);
        Vec3 n = cross(r2r1,r3r1);
        
        Vec3 v = vn[i][j].plus(vn[i][j+1].plus(vn[i+1][j]));
        v = v.divide(3);

        float v2n = dot(v,n) * v.length();
        v2n /= 2*(n.length());
        Vec3 v2an = n.times(v2n);
        v2an = (v2an.times(-0.5)).times(c);
     
        vn[i][j] = vn[i][j].plus(v2an);
        vn[i][j+1] = vn[i][j+1].plus(v2an);
        vn[i+1][j] = vn[i+1][j].plus(v2an);
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
