///@desc

gpu_set_tex_filter(1);
surface_set_target(application_surface);
draw_clear_alpha(0,0);
gpu_set_blendmode_ext_sepalpha(bm_one,bm_zero,bm_src_alpha,bm_zero);

if (fade<1) && menu>3
{
	shader_set(shd_render);
	shader_set_uniform_f(uni_hit,max(sin(max(hit*pi*4,0)),0));
	shader_set_uniform_f(uni_time,get_timer()/1000000);
	shader_set_uniform_f(uni_danger,danger);
	shader_set_uniform_f(uni_pos,px,py,pz);
	shader_set_uniform_f(uni_cam_dir,dcos(angle),-dsin(angle),dsin(angle),dcos(angle));
	shader_set_uniform_f(uni_axis,ax,ay,az);
	draw_sprite_stretched(spr_tex,0,0,0,w,h);
	shader_reset();
}
gpu_set_tex_filter(0);
gpu_set_blendmode(bm_normal);
if !start
{
	if (menu<2)
	{
		draw_clear($110703);
		var _a = (1-fade)*min(sin(fade*9.25*pi)*2+2,1);
		
		draw_sprite_ext(spr_spud,0,w/2-256,h/2,1,1,0,-1,_a);
		draw_sprite_ext(spr_xor ,0,w/2+256,h/2,1,1,0,-1,_a);
	}
	else if (menu<4)
	{
		if mouse_check_button_pressed(mb_left) && (menu == 2)
		{
			audio_play_sound(snd_click,0,0);
			menu++;
			fade_target = 1;
		}
		draw_clear($110703);
		var _t = "Steer with the mouse! Press M to mute. Try to collect as many neon rings as possible while avoiding obstacles and whiteholes!\nTry to last as long as possible to acheive a good score!\n\nThere are safer routes and more dangerous routes so learning them can help you on your next run\n\nClick to continue"
		text_glow(128,128,_t);
		
		draw_set_halign(fa_center);
		if (points>0) text_glow(w/2,h-256,"Score: "+string(points));
		draw_set_halign(fa_left);
		
		draw_set_color(0);
		draw_set_alpha(fade);
		draw_rectangle(0,0,w,h,0);
		draw_set_alpha(1);
	}
	else if (menu==4)
	{
		if mouse_check_button_pressed(mb_left)
		{
			audio_stop_sound(snd_menu);
			audio_play_sound(snd_start,0,0);
			music = 60;
			start = 1;
			points = 0;
		}
		draw_set_color(0);
		draw_set_alpha(.7+.3*fade);
		draw_rectangle(0,0,w,h,0);
		draw_set_alpha(1);
		
		var _t = "Click to Start";
		text_glow((w-string_width(_t))/2,(h-string_height(_t))/2-64,_t);
		//_t = "Q to change quality";
		//text_glow((w-string_width(_t))/2,(h-string_height(_t))/2+64,_t);
	}
	
}
else
{
	text_glow(256,32,string(points)+(points==1?" Point":" Points"));
	draw_set_alpha(max(cos(max(hit*pi*4,0)),0));
	if (hp>=0) text_glow(256,128,string(hp)+(hp==1?" Shield":" Shields"));
	
	draw_set_alpha(max(sin(max(warning*pi*8,0)),0));
	var _t = "Warning! Particles!";
	text_glow((w-string_width(_t))/2,192,_t);
	draw_set_alpha(1);
	
	
	var _amt = clamp((az+zone1)%zone-zone+zone1,0,zone1)/zone1;
	if (_amt>0) && (_amt<.8) && (_amt*10)%1
	{
		var _t = "<=  Turn!  =>";
		text_glow((w-string_width(_t))/2,h/2,_t);
	}
	
	draw_set_color(0);
	draw_set_alpha(fade);
	draw_rectangle(0,0,w,h,0);
	draw_set_alpha(1);
}

surface_reset_target();

if !surface_exists(bloom_surf) bloom_surf = surface_create(w/4,h/4);

surface_set_target(bloom_surf);
gpu_set_tex_filter(1);
draw_clear_alpha(0,0);
shader_set(shd_bloom);
shader_set_uniform_f(uni_glow,1,3);
draw_surface_ext(application_surface,0,0,1/4,1/4,0,-1,1);
shader_reset();
shader_reset();

surface_reset_target();
gpu_set_tex_filter(0);

gpu_set_blendmode_ext_sepalpha(bm_one,bm_zero,bm_one,bm_zero);
draw_surface(application_surface,0,0);
gpu_set_blendmode(bm_normal);

var _mx,_my;
_mx = w/2;
_my = h/2;
dist = (surface_getpixel_ext(application_surface,_mx,_my) >> 24) & 255;
//draw_circle(_mx,_my,dist,1);

gpu_set_blendmode(bm_add);
shader_set(shd_bloom);
shader_set_uniform_f(uni_glow,start?.7:1,12);
draw_surface_ext(bloom_surf,0,0,4,4,0,-1,1);
shader_reset();
gpu_set_blendmode(bm_normal);


//shader_set(shd_generate);
//if keyboard_check(vk_space) draw_surface_stretched(application_surface,0,0,room_width,room_height);
//shader_reset();	
/*
if keyboard_check_pressed(vk_enter)
{
	var _w,_h,_s;
	_w = 1024
	_h = 512;
	_s = surface_create(_w,_h);
	
	surface_set_target(_s);
	draw_clear_alpha(0,0);
	shader_set(shd_generate);
	draw_surface_stretched(application_surface,0,0,_w,_h);
	shader_reset();	
	surface_reset_target();
	surface_save(_s,get_save_filename(".png|*.png","space"));
	surface_free(_s);
	
}