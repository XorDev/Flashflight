///@desc

quality = 0;
window_set_cursor(cr_none);
danger = 0;
danger_target = 0;
warning = 0;
zone = 320;
zone1 = 40;
zone_num = 0;
music = 0;

menu = 0;
fade = 1;
fade_target = 0;

angle_target = 0;
angle = 0;

audio_play_sound(snd_menu,0,1);
//audio_sound_get_track_position(snd_game_song);

hit = 0;
hp = 3;
z = 0;
px = 0;
py = 0;
pz = 0;
ax = 0;
ay = 0;
az = 0;
passed = 0;
points = 0;

function path(c)
{
	var a = c*(c-floor(c/4.31)*4.31);
	
	return [-cos(a)*3,-cos(a+pi/2)*3];	
}

function text_glow(x,y,string)
{
	draw_set_color($994411);
	draw_text_ext(x+2,y,string,54,w-256);
	draw_text_ext(x-2,y,string,54,w-256);
	draw_text_ext(x,y+2,string,54,w-256);
	draw_text_ext(x,y-2,string,54,w-256);
	draw_set_color($DDAA66);
	draw_text_ext(x,y,string,54,w-256)
	draw_set_color(-1);
}

start = 0;
time = 0;
spd = 0;
dist = 1;
bloom_surf = -1;

w = display_get_width();//room_width;
h = display_get_height();//room_height;

window_set_fullscreen(1);
surface_resize(application_surface,w,h);

gpu_set_tex_repeat(1);
gpu_set_tex_mip_enable(1);
gpu_set_tex_filter(1);
application_surface_draw_enable(0);

draw_set_font(fnt_main);
uni_hit = shader_get_uniform(shd_render,"hit");
uni_time = shader_get_uniform(shd_render,"time");
uni_danger = shader_get_uniform(shd_render,"danger");
uni_pos = shader_get_uniform(shd_render,"pos");
uni_cam_dir = shader_get_uniform(shd_render,"cam_dir");
uni_axis = shader_get_uniform(shd_render,"axis");
uni_glow = shader_get_uniform(shd_bloom,"glow");

