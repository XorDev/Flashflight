///@desc Update
music--;
if (music==0)
{
	if !audio_is_playing(snd_game_song) audio_play_sound(snd_game_song,0,1);
	
	audio_sound_gain(snd_game_song,1,500);
}

fade = lerp(fade,fade_target,.05);

if (abs(fade-fade_target)<.001)
{
	if (hp<0)
	{
		if (fade_target == 0)
		{
			fade_target = 1;
		}
		else //Reset
		{
			//audio_stop_all();
			audio_sound_gain(snd_game_song,0,0);
			audio_play_sound(snd_lose,0,0);
			audio_play_sound(snd_menu,0,1);
			audio_sound_gain(snd_menu,0,0)
			audio_sound_gain(snd_menu,2,1000)
			random_set_seed(0);
			fade_target = 0;
			angle = 0;
			angle_target = 0;
			zone_num = 0;
			music = 0;
			hp = 3;
			menu = 2;
			start = 0;
			hit = 0;
			hp = 3;
			hspeed = 0;
			vspeed = 0;
			x = 0;
			y = 0;
			z = 0;
			px = 0;
			py = 0;
			pz = 0;
			ax = 0;
			ay = 0;
			az = 0;
			time = 0;
			spd = 0;
			dist = 1;
			passed = 0;
			danger = 0;
			danger_target = 0;
			warning = 0;
		}
	}
	else if (menu<2) || (menu==3)
	{
		menu++;
		fade_target = !fade_target;
	}
}
if start
{
	var _amt = clamp((az%zone)-zone+zone1,0,zone1)/zone1;
	angle = lerp(angle,angle_target,_amt);

	danger = lerp(danger,danger_target,.005);
	if (az/zone>zone_num)
	{
		danger_target = choose(0,1)^(x>0);
		warning = danger_target*2;
		zone_num++
		angle_target = angle-30*(x>0?1:-1);
	}

	spd = lerp(spd,start,.1);
	var _delta = delta_time/100000*spd*(hp>=0)*sqrt(1+time/200);
	time += _delta;

	hspeed -= x*(dist<1)/4;
	vspeed -= y*(dist<1)/4;
	spd -= (dist<1);

	var _delta_sec = delta_time/1000000;
	if (hit>0) && (hit<2) && (floor(hit*2) != floor((hit-_delta_sec)*2))
	{
		audio_play_sound(snd_safe,0,0);	
	}

	if (warning>0) && (floor(warning) != floor(warning-_delta_sec))
	{
		audio_play_sound(snd_warning,0,0);	
	}
	hit -= _delta_sec;
	warning -= _delta_sec;
	if (dist<1) && (hit<=0)
	{
		hp--;
		hit = 2;
		spd -= 2;
		audio_play_sound(snd_hit,0,0);
	}

	z = time;
	var _d = ceil(z/16.+.5);
	if (passed < _d)
	{
		var p = path(passed);
		passed = _d;
	
		if (point_distance(x,y,p[0],p[1])<2) && (_amt==0)
		{
			points++;
			audio_play_sound(snd_point,0,0);
		}
	}

	var _mx,_my,_cx,_cy;
	_mx = window_mouse_get_x();
	_my = window_mouse_get_y();
	_cx = window_get_width()/2;
	_cy = window_get_height()/2;

	var _inertia = .1*max(power(spd,7),0);
	hspeed = lerp(hspeed*.6,(_mx-_cx)/+_cx*9-x,_inertia);
	vspeed = lerp(vspeed*.6,(_my-_cy)/-_cx*9-y,_inertia);

	px += hspeed*dcos(angle)-_delta*dsin(angle);
	py += vspeed;
	pz += hspeed*dsin(angle)+_delta*dcos(angle);

	ax += hspeed;
	ay += vspeed;
	az += _delta;
}

if keyboard_check_pressed(ord("Q"))
{
	quality = (quality+1)%3;
}

var _w,_h;
_w = window_get_width()/(quality+1);
_h = window_get_height()/(quality+1);
if (w != _w) || (h != _h)
{
	if (_w && _h)
	{
		w = _w;//room_width;
		h = _h;//room_height;

		surface_resize(application_surface,w,h);
	}
}

if keyboard_check(vk_escape) game_end();

if keyboard_check_pressed(ord("M"))
{
	audio_set_master_gain(0,!audio_get_master_gain(0));
}

