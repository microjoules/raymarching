
// https://www.youtube.com/watch?v=PGtv-dBi2wE&ab_channel=TheArtofCode 

uniform vec3 resolution;   
uniform float time;   

int maxSteps = 100;
float maxDist = 100.0;
float hitDistance = 0.01;
vec3 implicitPlane = vec3(0);
float scale = 8.0;
float speed = 0.0;
float modValue = 4.0;
float startPos = 10.0;

//sdf for stomach
float getDistSphere(vec3 p){
    float wrappedTime = mod(time,modValue);
    //p then radius
   float y = -0.5 * scale*wrappedTime;
    vec4 sphere = vec4(0,startPos+1.5+y,6,1);
    float distToPlane = p.y;
    float distToSphere = length(p - sphere.xyz) - sphere.w;
    //take smaller of two values bc rayMarching doesn't know diretion
    float distance = min(distToPlane,distToSphere);
    return distance;
}

//sdf for head
float getDistSphere2(vec3 p){
    float wrappedTime = mod(time,modValue);
    //p then radius
   float y = -0.5 * scale*wrappedTime;
    vec4 sphere = vec4(0,startPos+3.0+y,6,0.75);
    float distToPlane = p.y;
    float distToSphere = length(p - sphere.xyz) - sphere.w;
    //take smaller of two values bc rayMarching doesn't know diretion
    float distance = min(distToPlane,distToSphere);
    return distance;
}

//sdf for left ear
float getDistEye1(vec3 p){
    float wrappedTime = mod(time,modValue);
    //p then radius
   float y = -0.5 * scale*wrappedTime;
    vec4 sphere = vec4(0.7,startPos+3.4+y,6,0.35);
    float distToPlane = p.y;
    float distToSphere = length(p - sphere.xyz) - sphere.w;
    //take smaller of two values bc rayMarching doesn't know diretion
    float distance = min(distToPlane,distToSphere);
    return distance;
}

//sdf for right ear
float getDistEye2(vec3 p){
    float wrappedTime = mod(time,modValue);
    //p then radius
   float y = -0.5 * scale*wrappedTime;
    vec4 sphere = vec4(-0.7,startPos+3.4+y,6,0.35);
    float distToPlane = p.y;
    float distToSphere = length(p - sphere.xyz) - sphere.w;
    //take smaller of two values bc rayMarching doesn't know diretion
    float distance = min(distToPlane,distToSphere);
    return distance;
}

//sdf for left leg
float leftFoot(vec3 p) {
    float wrappedTime = mod(time,modValue);
   float y = -0.5 * scale*wrappedTime;
    vec3 center = vec3(-0.5,startPos+0.8+y,6);
    float radius = 0.35;
    float height = 0.7;
    // Subtract the cylinder's central axis from the point
    vec2 d = vec2(length(p.xz - center.xz) - radius, abs(p.y - center.y) - height * 0.5);

    // The SDF combines the distance outside and inside
    return min(max(d.x, d.y), 0.0) + length(max(d, vec2(0.0)));
}

//sdf for right foot
float rightFoot(vec3 p) {
    float wrappedTime = mod(time,modValue);
   float y = -0.5 * scale*wrappedTime;
    vec3 center = vec3(0.5,startPos+0.8+y,6);
    float radius = 0.35;
    float height = 0.7;
    // Subtract the cylinder's central axis from the point
    vec2 d = vec2(length(p.xz - center.xz) - radius, abs(p.y - center.y) - height * 0.5);

    // The SDF combines the distance outside and inside
    return min(max(d.x, d.y), 0.0) + length(max(d, vec2(0.0)));
}

//sdf for floor stage
float getDistRect(vec3 p) {
    vec3 center = vec3(0.0, 0.0, 6.0);
    vec3 halfSize = vec3(3.0, 0.5, 3.0); 
    // Compute the absolute difference from the center and subtract the box half sizes
    vec3 d = abs(p - center) - halfSize;

    // Compute distance to the rectangle
    float outsideDist = length(max(d, vec3(0.0))); // Distance to the outside of the rectangle
    float insideDist = min(max(d.x, max(d.y, d.z)), 0.0); // Distance inside the rectangle

    return outsideDist + insideDist; // Signed distance
}

//sdf for left foot
float leftToe(vec3 p){
    float wrappedTime = mod(time,modValue);
    //p then radius
   float y = -0.5 * scale*wrappedTime;
    vec4 sphere = vec4(-0.5,startPos+0.5+y,6,0.35);
    float distToPlane = p.y;
    float distToSphere = length(p - sphere.xyz) - sphere.w;
    //take smaller of two values bc rayMarching doesn't know diretion
    float distance = min(distToPlane,distToSphere);
    return distance;
}

//sdf for right toe
float rightToe(vec3 p){
    float wrappedTime = mod(time,modValue);
    //p then radius
   float y = -0.5 * scale*wrappedTime;
    vec4 sphere = vec4(0.5,startPos+0.5+y,6,0.35);
    float distToPlane = p.y;
    float distToSphere = length(p - sphere.xyz) - sphere.w;
    //take smaller of two values bc rayMarching doesn't know diretion
    float distance = min(distToPlane,distToSphere);
    return distance;
}

//smoothing function, higher k = more smooth
vec2 smin( float a, float b, float k )
{
    k *= 3.0;
    float h = max( k-abs(a-b), 0.0 )/k;
    float m = h*h*h*0.5;
    float s = m*k*(1.0/3.0); 
    return (a<b) ? vec2(a-s,m) : vec2(b-s,1.0-m);
}

//combine head to body
vec2 getSpheresDist(vec3 p){
    float dist1 = getDistSphere(p);
    float dist2 = getDistSphere2(p);
    float k = 0.4;

    // Smooth minimum blending
    float smoothedDist = smin(dist1,dist2,k).x;

    // Determine the object ID based on which distance is closer
    float objectID = (dist1 < dist2) ? 1.0 : 2.0;

    return vec2(smoothedDist, objectID);
}

//combine ears
float getEyesDist(vec3 p){
    float dist1 = getDistEye1(p);
    float dist2 = getDistEye2(p);
    float k = 0.4;

    // // Smooth minimum blending
    // float smoothedDist = smin(dist1,dist2,k).x;

    // // Determine the object ID based on which distance is closer
    // float objectID = (dist1 < dist2) ? 1.0 : 2.0;

    return min(dist1,dist2);
}

//combine ears and body
vec2 attachEars(vec3 p){
    float dist1 = getSpheresDist(p).x;
    float dist2 = getEyesDist(p);
    float k = 0.1;

    // Smooth minimum blending
    float smoothedDist = smin(dist1,dist2,k).x;

    // Determine the object ID based on which distance is closer
    float objectID = (dist1 < dist2) ? 1.0 : 2.0;

    return vec2(smoothedDist, objectID);
}

//combine feet 
vec2 combineFeet(vec3 p){
    float dist1 = rightFoot(p);
    float dist2 = leftFoot(p);
    float k = 0.1;

    // Smooth minimum blending
    float smoothedDist = smin(dist1,dist2,k).x;

    // Determine the object ID based on which distance is closer
    float objectID = (dist1 < dist2) ? 1.0 : 2.0;

    return vec2(smoothedDist, objectID);
}

//combine toes
vec2 combineToes(vec3 p){
    float dist1 = rightToe(p);
    float dist2 = leftToe(p);
    float k = 0.1;

    // Smooth minimum blending
    float smoothedDist = smin(dist1,dist2,k).x;

    // Determine the object ID based on which distance is closer
    float objectID = (dist1 < dist2) ? 1.0 : 2.0;

    return vec2(smoothedDist, objectID);
}

//combine legs with toes
vec2 combineLegs(vec3 p){
    float dist1 = combineToes(p).x;
    float dist2 = combineFeet(p).x;
    float k = 0.3;

    // Smooth minimum blending
    float smoothedDist = smin(dist1,dist2,k).x;

    // Determine the object ID based on which distance is closer
    float objectID = (dist1 < dist2) ? 1.0 : 2.0;

    return vec2(smoothedDist, objectID);
}

//add legs with toes to body with head and ears
vec2 attachFeet(vec3 p){
    float dist1 = attachEars(p).x;
    float dist2 = combineLegs(p).x;
    float k = 0.1;

    // Smooth minimum blending
    float smoothedDist = smin(dist1,dist2,k).x;

    // Determine the object ID based on which distance is closer
    float objectID = (dist1 < dist2) ? 1.0 : 2.0;

    return vec2(smoothedDist, objectID);
}

//combine whole body with floor
vec2 getSceneDist(vec3 p){
    float dist1 = attachFeet(p).x;
    float dist2 = getDistRect(p);
    float k = 0.4;

    // Smooth minimum blending
    float smoothedDist = smin(dist1,dist2,k).x;

    // Determine the object ID based on which distance is closer
    float objectID = (dist1 < dist2) ? 1.0 : 2.0;

    return vec2(smoothedDist, objectID);
}


//general raymarching
vec2 rayMarching(vec3 rayOrigin, vec3 rayDirection){
    float distanceMarched = 0.0;
    float objectID = 0.0;

    for (int i=0; i< maxSteps;i++) {
        vec3 p = rayOrigin + rayDirection * distanceMarched;
        vec2 sceneDist = getSceneDist(p);
        distanceMarched += sceneDist.x;
        objectID = sceneDist.y;

        //has exit condition been met?
        if (distanceMarched > maxDist || sceneDist.x < hitDistance){
            break;
        }
    }

     return vec2(distanceMarched, objectID);
}

vec3 getNormal(vec3 position){
    vec2 e = vec2(1.0,-1.0)*0.5773*0.005;
    return normalize( e.xyy*getSceneDist( position + e.xyy ).x + 
					  e.yyx*getSceneDist( position + e.yyx ).x + 
					  e.yxy*getSceneDist( position + e.yxy ).x + 
					  e.xxx*getSceneDist( position + e.xxx ).x );
}

float getLight(vec3 position){
    vec3 lightPosition = vec3(0,5,6);
    vec3 lightvec = normalize(lightPosition - position);
    vec3 normal = getNormal(position);
    float diffuse = dot(normal, lightvec);

    return diffuse;
}



void main() {

    vec2 fragCoord = gl_FragCoord.xy;
    vec2 uv = (fragCoord - 0.5 *resolution.xy)/resolution.y;

    vec3 rayDirection = normalize(vec3(uv.x, uv.y, 1.0));
    vec3 rayOrigin = vec3(0.0,3.0,-5.0);
    // Raymarch and get distance + object ID
    vec2 result = rayMarching(rayOrigin, rayDirection);
    float distance = result.x;
    float objectID = result.y;

    float ambientIntensity = 0.8;

    vec3 position = rayOrigin + rayDirection * distance;
    float diffuse = getLight(position) + ambientIntensity;

    vec3 pink = vec3(0.9, 0.6, 0.9); 

    gl_FragColor = vec4(vec3(pink*diffuse), 1.0); 
}
