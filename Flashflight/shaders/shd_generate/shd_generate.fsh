varying vec4 v_color;
varying vec2 v_coord;
varying vec2 v_texel;

#define PI 3.1415926535897932384626433832795
#define TAU 6.283185307179586476925286766559

float smooth(float a,float b,float k)
{
	return log(exp(a*k)+exp(b*k))/k;
}
vec3 polar(vec2 u)
{
	u *= vec2(TAU,PI);
	return vec3(-cos(u.x)*sin(u.y),-sin(u.x)*sin(u.y),cos(u.y));	
}
vec2 rect(vec3 p)
{
	return vec2(.5+atan(p.y,p.x)/TAU,acos(p.z)/PI);	
}

vec3 hash(vec3 p)
{
	return fract(cos(p*mat3(78,-82,91,-86,95,-79,75,-92,89))*437.);
}
float worley(vec3 p)
{
	vec3 f = floor(p);
	float d = 1.;
	
	for(int x = -1;x<=1;x++)
	for(int y = -1;y<=1;y++)
	for(int z = -1;z<=1;z++)
	{
		vec3 h = f+vec3(x,y,z);
		d = smooth(distance(h+hash(h),p),d,-20.);//mod(h,6.)
	}
	
	return d;
}

void main()
{
	vec3 ray = polar(v_coord);
	vec2 u = rect(ray);
	float w = worley(ray*3.);//vec3(v_coord*6.,0));
	w *= w;
	
	w -= .1;
	w = smooth(w*.1,-w,40.);
	w = pow(w,.5);
	
	float s = max(1.-worley(ray*40.),0.);
	s = pow(s,3.);
	
    gl_FragColor = vec4(w,1,s,1);//v_color * texture2D(gm_BaseTexture, v_coord);
}