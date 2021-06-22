#extension GL_OES_standard_derivatives : enable

#define RES vec2(1024,512)
#define MAX 60.
#define EPS .001

#define zone 320.
#define zone1 40.

#define PI 3.1415926535897932384626433832795
#define TAU 6.283185307179586476925286766559
#define HP 1.5707963267948966192313216916398

uniform float hit;
uniform float time;
uniform float danger;
uniform vec3 pos;//x,y,z,total distance
uniform vec4 cam_dir;
uniform vec3 axis;

varying vec4 v_color;
varying vec2 v_coord;
varying vec2 v_texel;

vec3 X = normalize(vec3(1,6,8));
vec3 Y = normalize(cross(X,vec3(4,9,6)));
vec3 Z = normalize(cross(X,Y));
mat3 ROT = mat3(X,Y,Z);

vec2 path(float p)
{
	float c = ceil(p/16.);
	return cos(c*mod(c,4.31)+vec2(0,HP))*3.;
}
vec3 hash3(float p)
{
	return fract(cos(p*vec3(.613,.894,.971))*3466.);
}
vec3 color(float p)
{
	float f = floor(p);
	float s = p-f;
	s *= s*(3.-s-s);
	vec3 h1 = hash3(f);
	vec3 h2 = hash3(++f);
	vec3 h = mix(h1,h2,s);
	
	float m = min(h.x,min(h.y,h.z))-.1;
	float M = max(h.x,max(h.y,h.z))+.1;
	return smoothstep(m,M,h)*.5;
}
float smooth(float a,float b,float k)
{
	return log(exp(a*k)+exp(b*k))/k;
}
vec2 rect(vec3 p)
{
	vec2 uv = vec2(atan(p.y,p.x)/TAU,acos(p.z)/PI);
	
	#ifdef GL_OES_standard_derivatives

		//Mipmap solution by Marco Tarini: https://www.shadertoy.com/view/7sSGWG
		float phi_frac = fract(uv.x);
		float phi_fw = fwidth(uv.x);
	    float phi_frac_fw = fwidth(phi_frac);
    
	    uv = vec2(phi_fw <= phi_frac_fw ? uv.x : phi_frac, uv.y);
	#endif
	return uv;	
}
float glow(vec3 p)
{
	vec3 r = p-pos;
	r.xz = mat2(cam_dir.x,cam_dir.y,cam_dir.z,cam_dir.w)*r.xz;
	r += axis;
	
	vec3 a = r;
	a.xy += path(r.z);
	a.z = mod(a.z,16.)-8.;
	float space = zone1-abs(mod(r.z+zone/2.,zone)-zone/2.);
	float flicker = .02*cos(time*13.+cos(time*29.));
	
	vec3 origin = mod(r+zone/2.+vec3(0,0,zone1)*.7,zone)-zone/2.;
	float whitehole = min(length(origin),max(length(origin.xz)-1.,abs(origin.y)+2.5))*.3-.7+flicker;
	
	float comets = 1e5;
	if (danger>.1)
	{
		comets = length(mod(p+vec3(-4,9,6)*time,36.1)-18.)-.1;
		comets = min(comets,length(mod(p+vec3(7,-8,7)*time,29.7)-15.));
		comets = min(comets,length(mod(p+vec3(9,7,-8)*time,25.8)-13.)+.1);
		comets = min(comets,length(mod(p+vec3(6,-5,9)*time,23.7)-12.)+.2);
		comets = min(comets,length(mod(p+vec3(-5,6,5)*time,20.3)-10.)+.3);
		comets -= danger;
	}
	
	
	return min(min(max(length(vec2(abs(length(a.xy)-2.),a.z))-.1,space),whitehole),comets);//max(   ,pos.z+2.-p.z)
}
float dist(vec3 p)
{
	vec3 t = vec3(p.x*.8-p.y*.6,p.x*.6+p.y*.8,p.z);
	t -= .1*time;
	vec3 m = mod(t,8.)-4.;
	float l = length(m);

	float h = fract(dot(ceil(t/8.),vec3(.77,.23,.41)));
	float r = .7+h;
	if (l-r<1.)
	{
		float s = .1+.6*fract(dot(ceil(t/8.),vec3(.87,.38,.55)));
		vec2 cs = cos(time*s+vec2(0,1.57));
		mat3 rt = mat3(1,0,0,0,cs.x,-cs.y,0,cs.yx);
		cs = cos(ceil(t.z/8.)+vec2(0,1.57));
		rt *= mat3(cs.x,-cs.y,0,cs.yx,0,0,0,1);
		
		m *= rt;
		m /= l;
		
		//vec3 c = .7*t*rt;
		float bias = -99.;
		#ifdef GL_OES_standard_derivatives
			bias = 0.;
		#endif
		r -= texture2D(gm_BaseTexture,rect(m),bias).r*.2*r;
		//r = texture2D(gm_BaseTexture,c.xy).r*(m*m).z
		   //+texture2D(gm_BaseTexture,c.yz).r*(m*m).x
		   //+texture2D(gm_BaseTexture,c.zx).r*(m*m).y;
	}
	return min(h>.7?4.-.25*l:l-r,glow(p));
}
vec3 normal(vec3 p)
{
	vec2 n = vec2(-1,1)*EPS;
	return normalize(dist(p+n.yxx)*n.yxx+dist(p+n.xyx)*n.xyx+dist(p+n.xxy)*n.xxy+dist(p+n.y)*n.y);	
}

struct trace
{
	vec4 m_pos;
	vec3 m_glow;
};
trace march(vec3 p, vec3 d)
{
	trace t;
	vec2 l = vec2(10.);
	vec3 g = vec3(0);
	vec3 c = color(time*.1)*.7;
	vec4 m = vec4(p,0);
	for(int i = 0;i<40;i++)
	{
		float f = smoothstep(MAX,10.,m.w);
		float s = dist(m.xyz);
		float sg = glow(m.xyz);
		g += s/exp(l[0]*3.)*f*vec3(.06,.1+.1*hit,.12+.2*hit)*.5;
		g += sg/exp(l[1]*3.)*f*c;//vec3(.4,.1,.4);
		l = vec2(s,sg);
		m += vec4(d,1)*s;
		if (s<EPS || m.w>MAX) break;
	}
	
	t.m_pos = m;
	t.m_glow = g;
	return t;
}
vec3 light(vec3 col,vec3 nor,vec3 ray,vec3 dir)
{
	float total = max(dot(dir,nor),.0);
	total += exp(dot(reflect(ray,nor),dir)*3.-3.);
	return total * col/2.;
}
vec3 light(vec3 col,vec3 nor,vec3 ray,vec3 dir,float dis)
{
	float total = max(dot(dir,nor),.0);
	total += exp(dot(reflect(ray,nor),dir)*3.-3.);
	return total * col / (1.+.1*dis);
}

void main()
{
	vec3 ray = normalize(vec3((v_coord-.5)*vec2(v_texel.x/v_texel),.5));
	ray.xz *= mat2(cam_dir.x,cam_dir.y,cam_dir.z,cam_dir.w);
	trace t = march(pos.xyz,ray);
	vec4 mar = t.m_pos;
	vec3 nor = normal(mar.xyz);
	
	float rate = 4.;
	float light_seed = ceil(time/rate);
	float brightness = abs(mod(time/rate*2.+1.,2.)-1.);
	vec3 dir1 = normalize(hash3(light_seed)-.5);//sqrt(vec3(.8,.2,0));
	vec3 col1 = color(light_seed)*brightness;
	vec3 lig = vec3(.1);//light(col1,nor,ray,dir1)+.1;
	lig += light(.8+hit*vec3(.1,.5,1),nor,ray,ray);
	
	//Nearest light:
	vec3 r = mar.xyz-pos;
	r.xz = mat2(cam_dir.x,cam_dir.y,cam_dir.z,cam_dir.w)*r.xz;
	r += axis;
	vec3 d = r;
	d.xy -= path(d.z);
	d.z -= mod(d.z,16.)-8.;
	float m = mod(mar.z+zone/2.,zone)-zone/2.;
	d.z += max(zone1-abs(m),0.)*sign(m);
	vec3 dif = vec3(normalize(d.xy)*2.,d.z)-r;
	
	float len = length(dif);
	vec3 col = color(time*.1);//vec3(.4,.1,.4);
	lig += light(col,nor,ray,dif/len,len);

	//Background
	float fade = smoothstep(0.,MAX,mar.w); fade *= fade;
	vec4 samp = texture2D(gm_BaseTexture,rect(ray.xzy));
	vec3 back = mix(vec3(0,.01,.02),vec3(.1,.4,.8),samp.r)*min(fade*3.,1.);
	back += pow(samp.b,6.);
	back += (col1-back)/(1.+(1.-dot(ray,dir1))*20.);
	
	lig = mix(lig,back,fade);
	lig += (texture2D(gm_BaseTexture,gl_FragCoord.xy/RES,-9.).g-.5)/16.;
	lig *= lig;
	
	//Glow
	if (glow(mar.xyz)<EPS*9.) lig += 1.-fade;//mix(vec3(.4,.1,.4),vec3(1),nor.z*nor.z);
	lig += t.m_glow;
	
	lig += vec3(.6,.1,.05)*dot(v_coord-.5,v_coord-.5)*hit;
    gl_FragColor = vec4(lig,mar.w/MAX*2.);
}