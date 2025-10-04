pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--main
function _init()
	
	init_player()
	
	map_x,map_y = position(start1)
	
	axe_taken = false
	gun_taken = true
	better_gun_taken = false
	ammo = 0
	bullet_speed = 5
	btimer = 0
	
	key = 0
	gkey_taken = false
	key_taken = false
	dtimer = 0
	
	htimer = 0
	hrate = 20
	
	text_shown = false
	info_shown = false
	ready_to_close = false
	text_cooldown = 0
	auto_text = false
	
	window = {}
	init_p()
	init_enemy()
	init_bullets()
--	init_girl()
	init_txt()	
	
	heart_alive = true
	eyes_alive = true
	
	barn_phase1 = false
	barn_phase2 = false
	barn_phase3 = false
	barn_phase4 = false
	
	teleporting = false
	teleporting_timer = 30
	
	guide = true
	
	restart = true
	game_over = false
	saw_body = false
	game_end = false
	game_end_timer = 0
	
	last_music = -1
end


function _update()
	if not restart then
		 reset_game()
		return
	end
	
	if btnp(❎) then
		guide = false
	end
	
	if game_over and 
				btnp(❎) then
		restart = false
	end
	
	if game_end and 
				btnp(❎) then 
		restart = false
	end
	
	player_move()
	
	player_anim()
	
	camera_movement()
	
	update_p()
	
	update_enemy()
	update_spiders()
	update_eyes()
	
	animate_enemy()
	
	update_bullets()
	
	shoot(x,y)
	
	heart_rate()
	
	phases()
	
	update_music()
	
--	girl_cry()

	if health == 0 or
				health < 0 then
		game_over = true
	end
	
	if teleporting and
				teleporting_timer > 0 then
		teleporting_timer -=1
		sfx(18)
	end
	
	if current_map(ending1) then
		gkey_taken = true
	end
	
	if saw_body then
		game_end_timer += 1
	end
	
	if game_end_timer > 60 then
		game_end = true
	end
	

end
	
	

function _draw()
	
	cls()
	
	if guide then
		local y = 20 
		for g in all(guide_txt) do
			print(g,0,y,7)
			y+=6
		end
		print("to continue press ❎",25,y,8)
	end
	
	if game_over then
		cls()
		print("game over",44,60,8)
		print("to restart press ❎",25,72,8)
		return
	end
	
	if game_end then
		cls()
		print("the end",50,61,8)
		print("to restart press ❎",25,72,8)
		return
	end


	
	if not guide then
		if restart then
			pal(11,-12,1)
			pal(14,-8,1)
			
			camera(cam_x,cam_y)
		
			map(map_x,map_y)
			draw_heart()
			draw_pickups()
			draw_blood()
			draw_enemy()
			draw_eyes()
			draw_spider()
			spr(sprite,x,y,1,1,f) --our char
			draw_bullets()
			draw_web()
			forest_fog()
		
			print(repeat_str("♥",health),
			1,1,14)
			print(repeat_str("♥",armor),
			42,1,1)
			print(ammo,2,8,9)
			print(key,2,14,6)
	--		print(track,2,20,6)
		
			draw_txt()
			if teleporting then
				if teleporting_timer > 0 then
					rectfill(0,0,127,127,6)
				end
			end
		end
	end

end


-->8
--player
function init_player()
	x = 55
	y = 120
	ox = 0
	oy = 0
	cam_x = 0
	cam_y = 0
	ospeed = 1.5
	speed = 1.5
	player_slowed = false
	diag_x =.7
	diag_y =.7
	
	stimer = 0
	ani_speed = 5
	sprite = 54
	direct = ""
	f = false	
	
	max_health = 5
	health = 5
	armor = 0
	player_hit = false
	blood_drops = {}
	
	walking_timer = 0
end


function player_move()
	
	dx = 0
	dy = 0
	
	ox = x
	oy = y
	
	if walking_timer > 15 then
--		sfx(21)
		walking_timer = 0
	end
		
	if btn(➡️) then	
		dx += 1 
		walking_timer += 1 
	end

	if btn(⬅️) then	
		dx -= 1 
		walking_timer += 1
	end

	if btn(⬆️) then	
		dy -= 1 
		walking_timer += 1
	end
	
	if btn(⬇️) then	
		dy += 1 
		walking_timer += 1
	end

	if dx !=0 and dy !=0 then
		dx*=diag_x
		dy*=diag_y
		x += dx*speed
		y += dy*speed
		x = flr(x+.5)
		y = flr(y+.5)
	else
		x += dx*speed
		y += dy*speed
	end
	
--collision
	if map_collision(x,y,8,8,true) 
	or (x < 0 and map_x == 0) 
	or (y < 0 and map_y == 0)
	or (y > 127 and map_y == 48)
	or text_shown or 
				(not current_map(barn2) and
				 info_shown) then
		x = ox
		y = oy
	end
	
	if player_hit then
		for e in all(enemies)	do
--			if x > e.x then
--				x += 1
--				player_hit = false
--			elseif x < e.x then
--				x -= 1
--				player_hit = false
--			end
--					
--			if y > e.y then
--				y += 1
--				player_hit = false
--			elseif y < e.y then
--				e.y -= 1
--				player_hit = false
--			end
			player_hit = false
		end
	end
	
	if player_slowed then
		slow_timer +=1
		if slow_timer > 60 then
			speed = ospeed
			player_slowed = false
			slow_timer = 0
		end
	end
end

function player_anim()
	
	stimer+=1
	
--	if not gun_taken then
--		
--		if stimer > ani_speed then
--			if btn(➡️) then
--				sprite = sprite == 49 and 50 or 49
--				f = false
--				stimer = 0
--				direct = "right"
--			elseif btn(⬅️) then
--				sprite = sprite == 49 and 50 or 49
--				f = true
--				stimer = 0
--				direct = "left"
--			elseif btn(⬆️) then
--				sprite = sprite == 52 and 53 or 52
--				stimer = 0
--				direct = "up"
--			elseif btn(⬇️) then
--				sprite = sprite == 48 and 51 or 48
--				stimer = 0
--				direct = "down"
--			end
--			
--		end
	
--	else
	
		if btn(➡️) then
			direct = "right"
			if stimer > ani_speed then
				sprite = sprite == 55 and 56 or 55
				f = false
				stimer = 0
			end
		elseif btn(⬅️) then
			direct = "left"
			if stimer > ani_speed then
				sprite = sprite == 55 and 56 or 55
				f = true
				stimer = 0
			end
		elseif btn(⬆️) then
			direct = "up"
			if stimer > ani_speed then
				sprite = sprite == 58 and 59 or 58
				stimer = 0
			end
		elseif btn(⬇️) then
			direct = "down"
			if stimer > ani_speed then
				sprite = sprite == 54 and 57 or 54				stimer=0
				stimer = 0
			end
		end	
	
--	end

end

function camera_movement()

--x axis	--
	if x > 127 then
		map_x += 16
		x = 5
	elseif x < -5 then
		map_x -= 16
		x = 122
	end	
	
--y axis	--
	if y > 127 then
		map_y += 16
		y = 5
	elseif y < -5 then
		map_y	-= 16
		y = 122
	end

--	if x > 127 then
--		cam_screen +=1
--		x = 0
--	elseif x < 0 then
--		cam_scren -=1
--		x = 127
--	end
--	cam_x = cam_screen * 128

end




function init_bullets()
	bullets = {}
end


function update_bullets()
	
	for b in all(bullets) do
		
		if b.dir == "right" then
			b.x+=bullet_speed
		elseif b.dir == "left" then
			b.x-=bullet_speed
		elseif b.dir == "up" then
			b.y-=bullet_speed
		elseif b.dir == "down" then
			b.y+=bullet_speed
		end
		
		if b.x > 127 then
			del(bullets,b)
		elseif b.x < -1 then
			del(bullets,b)
		elseif b.y > 127 then
			del(bullets,b)
		elseif b.y < -1 then
			del(bullets,b)
		end
		
		if map_collision(b.x,b.y,
																	8,8,false) then
			del(bullets,b)
			
		end
	
  for e in all(enemies) do
			if aabb_collide
													(b.x,b.y,8,8,
														e.x,e.y,8,8)
			and map_x == e.map_x 
			and	map_y == e.map_y
			and e.alive then			
				
				if e.typ != "monster" or
							e.phase2 then
					
					e.alive = false
					e.fx = e.x
					e.fy = e.y
					e.death_timer = 0
					del(bullets,b)
				
				else
					e.phase2 = true
					e.speed *= 2
					e.old_speed *= 2
					sfx(14)
					del(bullets,b)
				end
			end
		end
		for s in all(spiders) do
			if aabb_collide
													(b.x,b.y,8,8,
														s.x,s.y,8,8)
			and map_x == s.map_x 
			and	map_y == s.map_y
			and s.alive then			
				
				s.alive = false
				s.fx = s.x
				s.fy = s.y
				s.death_timer = 0
				del(bullets,b)
			end
		end
		
		for e in all(eyes) do
			if aabb_collide
													(b.x,b.y,8,8,
														e.x,e.y,8,8)
			and map_x == e.map_x 
			and	map_y == e.map_y
			and e.alive then	
				e.alive = false
				del(bullets,b)
			end
		end
	
	end

end


function draw_bullets()
	
	for b in all(bullets) do	
		if not better_gun_taken then
			if b.dir == "right" then
				spr(60,b.x+6,b.y)
			elseif b.dir == "left" then
				spr(60,b.x-6,b.y)
			elseif b.dir == "up" then
				spr(60,b.x,b.y-6)
			elseif b.dir == "down" then
				spr(60,b.x,b.y+6)
			end
		else
			if b.dir == "right" then
				spr(101,b.x+6,b.y)
			elseif b.dir == "left" then
				spr(101,b.x-6,b.y)
			elseif b.dir == "up" then
				spr(101,b.x,b.y-6)
			elseif b.dir == "down" then
				spr(101,b.x,b.y+6)
			end
		end
	end

end


function shoot(player_x,
															player_y)
	btimer += 1
	
	if text_cooldown > 0 then 
		return
	end
	
	if gun_taken and ammo > 0 then
		if not better_gun_taken then	
				if btn(🅾️) and 
				btimer > 30 then
					add(bullets,{x=player_x,
																		y=player_y,
																		dir=direct})
					ammo-=1
					btimer=0
					sfx(00)
				end
		else
			if btn(🅾️) and 
			btimer > 20 then
				add(bullets,{x=player_x,
																	y=player_y,
																	dir=direct})
				ammo-=1
				btimer=0
				sfx(00)
			end
		end
	end
end



function draw_blood()
	for b in all(blood_drops) do
		if b.map_x == map_x and 
					b.map_y == map_y then
			spr(8,b.x,b.y)
		end
	end
end








function player_anim_old()
	
	if not gun_taken then
	
		if btn(➡️) then
			stimer+=1
			if stimer > ani_speed then
				stimer = 0
				sprite = sprite == 45 and 46 or 45
			
			end
				
		elseif btn(⬅️) then
			stimer+=1
			if stimer > ani_speed then
				stimer = 0
				sprite = sprite == 47 and 48 or 47
			
			end
				
		elseif btn(⬆️) then
			stimer+=1
			if stimer > ani_speed then
				stimer = 0
				sprite = sprite == 50 and 51 or 50
			
			end
				
		elseif btn(⬇️) then
			stimer+=1
			if stimer > ani_speed then
				stimer = 0
				sprite = sprite == 44 and 49 or 44
			end
	
		end
	
	else
	
		if btn(➡️) then
				stimer+=1
				if stimer > ani_speed then
					stimer = 0
					sprite = sprite == 53 and 54 or 53
				
				end
				
		elseif btn(⬅️) then
			stimer+=1
			if stimer > ani_speed then
				stimer = 0
				sprite = sprite == 55 and 56 or 55
			
			end
				
		elseif btn(⬆️) then
			stimer+=1
			if stimer > ani_speed then
				stimer = 0
				sprite = sprite == 58 and 59 or 58
			
			end
				
		elseif btn(⬇️) then
			stimer+=1
			if stimer > ani_speed then
				stimer = 0
				sprite = sprite == 52 and 57 or 52
			end
		
		end

	end
		
end
-->8
--tools
function map_collision(x,y,w,h,is_player)
 local tx = x/8+map_x
 local ty = y/8+map_y
 local tw = (x+w-1)/8+map_x
 local th = (y+h-1)/8+map_y
	
--	local s1 = mget(x/8,y/8)
--	local	s2 = mget((x+w-1)/8,y/8)
--	local	s3 = mget(x/8,(y+w-1)/8)
--	local	s4 = mget((x+w-1)/8,(y+w-1)/8)
 local s1 = mget(tx,ty)
 local s2 = mget(tw,ty)
 local s3 = mget(tx,th)
 local s4 = mget(tw,th)
	
	if fget(s1,0) or fget(s2,0)
	or fget(s3,0) or fget(s4,0)
	then return true
	end
	if is_player then
		if	heart_alive then
			if fget(s1,4) or fget(s2,4)
			or fget(s3,4) or fget(s4,4)
			then return true
			end
		end
	end
--	doors collion

	if not is_player then
		return false
	end
	 
	dtimer +=1
--	near_door =fget(s1,1) 
--									or fget(s2,1)
--									or fget(s3,1) 
--									or fget(s4,1)
--	
--
--	if near_door then
--		if	btn(❎) then
--   sfx(03) 
--   fset(65, 1, false)
--   fset(66, 1, false)
--   key -= 1
--  elseif key == 0 and btn(❎) 
--  and dtimer > 30 then
--  	sfx(04)
--  	dtimer = 0
--  	return true 
--  
--  else
--   return true 
--  end
--	
--	end
	local obj_x = flr((x+4)/8)+map_x
	local obj_y = flr((y+4)/8)+map_y
	local tile = mget(obj_x,obj_y)
	
	
	if fget(tile,1) then
		if key > 0 and btnp(❎) then
			sfx(03)
			key-=1
			mset(obj_x,obj_y,0)
			return false
		elseif key == 0 and 
									btnp(❎) and 
									dtimer > 30 then
			sfx(04)
			dtimer = 0
			return true
		else
			return true
		end
	end
	

	if fget(tile,2) then
		if axe_taken and btnp(❎) then
			sfx(13)
			mset(obj_x,obj_y,50)
			return false
		
		elseif not axe_taken and 
									btnp(❎) 					and 
									dtimer > 30 then
			sfx(04)
			dtimer = 0
			return true
		else
			return true
		end
	end
	
	
	if fget(tile,3) then
		if gkey_taken and btnp(❎) then
			sfx(03)
			mset(obj_x,obj_y,0)
			return false
		elseif not gkey_taken and 
									btnp(❎) and 
									dtimer > 30 then
			sfx(04)
			dtimer = 0
			return true
		else
			return true
		end
	end
	
	
	
	if fget(tile,5) then
		if not info_shown then
			take_info("hole")
			auto_text = true
			ready_to_close = false
		end
	
	
		if info_shown and auto_text 
																and btnp(❎) then
   teleport(ending1,48,56)
   teleporting = true
   info_shown = false 
 	end
	else
		if auto_text then
			auto_text = false
			info_shown = false
		end
	end
	
	return false

end

function aabb_collide(
																			x1,y1,w1,h1,
																			x2,y2,w2,h2)
	
	if x1 < x2 + w2 and
				x1 + w1 > x2 and
				y1 < y2 + h2 and
				y1 + h1 > y2 then
	return true
	end
	
	return false	
	 
end


function draw_fog()
	for y=0,127,2 do
		line(0, y, 127, y, 5) -- 5 = light gray
	end
end

function forest_fog()
	if map_x == 32 and 
				map_y == 32 then
		draw_fog()
	elseif map_x == 48 and 
								map_y == 48 then
		draw_fog()
	elseif map_x == 64 and 
								map_y == 48 then
		draw_fog()
	end
end

function rectfill2(_x,_y,_w,
																			   _h,_c)
	rectfill(_x,_y,_x+_w-1,
										   _y+_h-1,_c)

end

function make_zombie(args,position)
	return {						
		map_x = position.map_x,
		map_y = position.map_y,
		x_base = args.bx*8,
		y_base = args.by*8,
		x = args.x*8,
		y = args.y*8,
		fx = 0,
		fy = 0,
		ox = 0,
		oy = 0,
		s = 34,
		speed = args.speed,
		old_speed = args.speed,
		stimer = 0,
		ani_speed = 6,
		stuck = false,
		alive = true,
		hit = false,
		hit_cooldown = 0,
		typ = "zombie",
		death_timer = 0
		}									
end
function make_skeleton(args,position)
	return {						
		x_base = args.bx*8,
		y_base = args.by*8,
		x = args.x*8,
		y = args.y*8,
		fx = 0,
		fy = 0,
		map_x = position.map_x,
		map_y = position.map_y,
		ox = 0,
		oy = 0,
		s = 36,
		speed = args.speed,
		old_speed = args.speed,
		stimer = 0,
		ani_speed = 6,
		stuck = false,
		alive = true,
		hit = false,
		hit_cooldown = 0,
		typ = "skeleton",
		sound = false
		}									
end
function make_spider(args,position)
	return {						
		x_base = args.bx*8,
		y_base = args.by*8,
		range = 20,
		dir = 1,
		x = args.x*8,
		y = args.y*8,
		fx = 0,
		fy = 0,
		map_x = position.map_x,
		map_y = position.map_y,
		ox = 0,
		oy = 0,
		s = 41,
		speed = args.speed,
		old_speed = args.speed,
		stimer = 0,
		ani_speed = 6,
		stuck = false,
		alive = true,
		hit = false,
		hit_cooldown = 0,
		typ = "spider",
		sound = false
		}									
end
function make_monster(args,position)
	return {						
		map_x = position.map_x,
		map_y = position.map_y,
		x_base = args.bx*8,
		y_base = args.by*8,
		x = args.x*8,
		y = args.y*8,
		fx = 0,
		fy = 0,
		ox = 0,
		oy = 0,
		s = 98,
		speed = args.speed,
		old_speed = args.speed,
		stimer = 0,
		ani_speed = 6,
		stuck = false,
		alive = true,
		hit = false,
		hit_cooldown = 0,
		typ = "monster",
		sound = false,
		phase2 = false
		}									
end

function make_eye1(args,position)
	return {
	map_x = position.map_x,
	map_y = position.map_y,
	x = args.x*8,
	y = args.y*8,
	s = 110,
	alive = true,
	sound = false,
	}
end

function make_eye2(args,position)
	return {
	map_x = position.map_x,
	map_y = position.map_y,
	x = args.x*8,
	y = args.y*8,
	s = 111,
	alive = true,
	sound = false
	}
end 

function position(place)
	return place.map_x,place.map_y
end

function current_map(obj)
	return obj.map_x == map_x and
								obj.map_y == map_y
end


function take(list)
	
	for l in all(list) do
		if aabb_collide(
														x,y,8,8,
														(l.x-map_x)*8,
														(l.y-map_y)*8,
														8,8) then
			return l
		end											
	end
	return nil
end

function draw_p(list)
	
	for l in all(list) do
			spr(l.s,(l.x-map_x)*8,
						(l.y-map_y)*8)
	end
		
end

function repeat_str(str, n)
 local result = ""
 for i=1,n do
  result = result..str
 end
 return result
end


function take_heal()
	local h = take(heal)
	if h then
		if health < max_health-1 then
			del(heal,h)
			health+=2 
			sfx(08)
		elseif health < max_health then
			del(heal,h)
			health+=1
			sfx(08)		
		else
		sfx(11)
		end
	end
end

function take_keys()
local k = take(keys)
	if k then
		del(keys,k)
		key+=1
		sfx(01)
		key_taken = true
	end
end

function take_ammo()
local b = take(buckshot)	
 if b then
		del(buckshot,b)
		ammo+=4
		sfx(07)
	end	
end

function take_plates()
	local a = take(plates)
	if a then
		if armor == 1 then
			del(plates,a)
			armor+=1
			sfx(08)
		elseif armor == 0 then
			del(plates,a)
			armor+=2
			sfx(08)
		else
			sfx(11)
		end
	end
end

function take_letters(name)

	if take(letters) then
		text_object = name
		text_shown = true
		sfx(20)
	end
end

function take_info(name)

	if take(info) then
		text_object = name
		info_shown = true
	end
end

 

function phases()
	local zombie_alive = false
	local skeleton_alive = false
	local monster_alive = false
	
	
	for e in all(enemies) do
		if e.map_x == 96 and
					e.map_y == 16 then
			if e.alive then
				if not e.hit then 
					if e.typ == "zombie" and
								barn_phase1 then
						zombie_alive = true
						e.speed = e.old_speed
					elseif e.typ == "skeleton" and
												barn_phase2 then
						skeleton_alive = true
						e.speed = e.old_speed
					elseif e.typ == "monster" and
								    barn_phase3 then
						monster_alive = true
						e.speed = e.old_speed
					end
				end
			end
		end	
	end				
	
	if not zombie_alive  and
								barn_phase1	then
		zombie_timer += 1
	end
	if not skeleton_alive  and
								barn_phase2	then
		skeleton_timer += 1
	end
	if not monster_alive  and
							barn_phase3	then
		monster_timer += 1
	end
	
	
	
	if zombie_timer > 60 then
		barn_phase2 = true
		zombie_timer = 0
	end
	
	if skeleton_timer > 60 then
		barn_phase3 = true
		skeleton_timer = 0
	end
	
	if monster_timer > 30 then
		barn_phase4 = true
		monster_timer = 0
	end
	
	for e in all(enemies) do	
		if e.map_x == 96 and 
					e.map_y == 16 then
			if e.typ == "zombie" and
							not	barn_phase1 and
							not e.hit then
				e.speed =	0
				
			elseif e.typ == "skeleton" and
													not	barn_phase2 and
													not e.hit then
				e.speed =	0
			
			elseif e.typ == "monster" and
												not	barn_phase3 and
												not e.hit then
				e.speed =	0
			
			end
		end
	end
	
	if current_map(barn1) then
		barn_phase1 = true
	end
end

function draw_heart()
	if current_map(barn1) then
		if heart_alive then
			spr(106,56,56)
			spr(107,64,56)
			spr(122,56,64)
			spr(123,64,64)
		else
			spr(40,56,56)
			spr(40,64,56)
			spr(40,56,64)
			spr(40,64,64)
		end
	end

end

function teleport(dest,px,py)
	map_x = dest.map_x
	map_y = dest.map_y
	x = px
	y = py
end

function reset_game()
--	lower half of the map
	 reload(0x2000, 0x2000, 0x1000)
--	upper half of the map
	 reload(0x1000, 0x1000, 0x1000)
--	sprites/flags
	 reload(0x3000, 0x3000, 0x0100)
	 _init()
end
-->8
--pick-ups
function init_p()
	heal = {}
--	gun = {}
	better_gun = {}
	buckshot = {}
	keys = {}
	gkey = {}
	letters = {}
	info = {}
	axe = {}
	plates = {}
	
--	backyard
	add(heal, {s=32,x=4,y=4})
	add(keys,{s=43,x=13,y=3})

--	house
	add(buckshot, {s=62,x=11,y=20})
	add(buckshot, {s=63,x=12,y=22})
	
-- near_house
	add(keys,{s=43,x=4,y=36})
		
--	near_house2
	add(gkey,{s=45,x=27,y=35})
	
--outside_house
	add(buckshot, {s=63,x=19,y=4})
	add(buckshot, {s=63,x=25,y=3})	

--	graveyard
	add(heal, {s=32,x=37,y=20})
	
-- forest1
	add(buckshot, {s=63,x=52,y=44})
	
-- forest3
	add(better_gun, {s=30,x=37,y=54})
	add(better_gun, {s=31,x=38,y=54})

--	small cabin
	add(heal, {s=32,x=89,y=50})
	add(plates,{s=53,x=83,y=52})
	add(buckshot, {s=63,x=86,y=51})
	add(buckshot, {s=63,x=88,y=53})
	
--	add(gun, {s=30,x=6,y=21})
--	add(gun, {s=31,x=7,y=21})
	
--	cabin2
	add(axe, {s=48,x=88,y=38})

-- cave2
	add(heal, {s=32,x=76,y=3})
	add(buckshot, {s=63,x=77,y=3})

-- cave3
--	add(buckshot, {s=63,x=93,y=14})
	add(plates,{s=53,x=83,y=13})
	add(keys,{s=43,x=84,y=10})
	
-- cave4
	add(buckshot, {s=63,x=100,y=5})
	add(heal, {s=32,x=102,y=3})
	
-- cave5
	add(keys,{s=43,x=122,y=2})
	add(heal, {s=32,x=124,y=2})

-- barn1
	add(heal, {s=32,x=99,y=20})
	add(heal, {s=32,x=109,y=29})
	add(buckshot, {s=63,x=98,y=18})
	add(buckshot, {s=63,x=105,y=18})
	add(buckshot, {s=63,x=100,y=29})
	add(buckshot, {s=63,x=109,y=24})
	

--	add(letters,{s=61,x=5,y=55})


	
--	text
	
--	start
		add(letters,{s=61,x=9,y=57})

--	house
	add(letters,{s=61,x=4,y=21})
	
-- near_house2
	add(letters,{s=2,x=27,y=35})

 
-- near_cave
	add(letters,{s=2,x=53,y=20})
	add(letters,{s=2,x=52,y=19})
	add(letters,{s=2,x=53,y=18})
	add(letters,{s=2,x=54,y=19})
	
-- forest1
	add(letters,{s=2,x=50,y=41})
	add(letters,{s=2,x=51,y=42})
	add(letters,{s=2,x=50,y=43})

-- forest3
	add(letters, {s=2,x=37,y=54})
	add(letters, {s=2,x=38,y=54})

--	small_cabin 
	add(letters,{s=2,x=85,y=54})

-- barn1 (eyes_are_dead)
	add(letters,{s=2,x=102,y=23})
	add(letters,{s=2,x=102,y=24})
	
	add(letters,{s=2,x=103,y=22})
	add(letters,{s=2,x=104,y=22})
	
	add(letters,{s=2,x=105,y=23})
	add(letters,{s=2,x=105,y=24})
	
	add(letters,{s=2,x=103,y=25})
	add(letters,{s=2,x=104,y=25})

-- ending3
	add(letters,{s=2,x=122,y=63})
	add(letters,{s=2,x=123,y=63})
	add(letters,{s=2,x=124,y=63})
	add(letters,{s=2,x=125,y=63})


-- info

-- start2
	add(info,{s=2,x=30,y=56})
	add(info,{s=2,x=30,y=57})	

-- near_house2
	add(info,{s=2,x=24,y=34})
	add(info,{s=2,x=24,y=35})

-- graveyard
	add(info,{s=2,x=38,y=23})
	add(info,{s=2,x=38,y=24})
	add(info,{s=2,x=41,y=23})
	add(info,{s=2,x=41,y=24})
 add(info,{s=2,x=39,y=25})
 add(info,{s=2,x=40,y=25})

--	near_cave
	add(info,{s=2,x=55,y=17})
	add(info,{s=2,x=56,y=17})
	add(info,{s=2,x=57,y=17})
	
-- well
	add(info,{s=2,x=69,y=21})
	add(info,{s=2,x=69,y=22})
	
-- forest3
	add(info,{s=2,x=45,y=56})
	add(info,{s=2,x=45,y=57})	

-- near_cabin
	add(info,{s=2,x=78,y=57})
	add(info,{s=2,x=78,y=58})
	
-- barn1 (heart)
	add(info,{s=2,x=102,y=23})
	add(info,{s=2,x=102,y=24})
	
	add(info,{s=2,x=103,y=22})
	add(info,{s=2,x=104,y=22})
	
	add(info,{s=2,x=105,y=23})
	add(info,{s=2,x=105,y=24})
	
	add(info,{s=2,x=103,y=25})
	add(info,{s=2,x=104,y=25})
	
-- barn2 (the hole)
	add(info,{s=2,x=122,y=24})
	add(info,{s=2,x=123,y=24})
	add(info,{s=2,x=122,y=25})
	add(info,{s=2,x=123,y=25})
	
-- ending3
	add(info,{s=2,x=121,y=59})
	add(info,{s=2,x=122,y=59})
	add(info,{s=2,x=122,y=61})

-- ending4
	add(info,{s=2,x=98,y=55})
	add(info,{s=2,x=98,y=56})
	add(info,{s=2,x=98,y=57})

end


function update_p()
	
	if btnp(❎) then
		take_heal()
		take_keys()
		take_ammo()
		take_plates()
		if take(axe) then
			axe = {}
			axe_taken = true
			sfx(07)
		end
		if take(gkey) then
			gkey = {}
			gkey_taken = true
			sfx(16)
		end
		if take(better_gun) then
			better_gun = {}
			better_gun_taken = true
			sfx(07)
		end
		

-- text
		if current_map(house) then
			take_letters("goal")
		elseif current_map(start2) and
		not gkey_taken then
			take_info("sdoor")	
		elseif current_map(near_house2) then
			if not axe_taken then
				take_info("barricade")
			end
			take_letters("gkey")
		elseif current_map(graveyard) then
			take_info("statue")
		elseif current_map(near_cave) then
			take_letters("cave_warning")
			if not axe_taken then
				take_info("barricade")
			end
		elseif current_map(well) and
		not axe_taken then
			take_info("barricade")
		elseif current_map(forest1) then
			take_letters("forest_warning")
		elseif current_map(forest3) then
			take_letters("better_gun")
			if	not gkey_taken then
				take_info("sdoor")
			end
		elseif current_map(near_cabin) and
		not axe_taken then
			take_info("barricade")
		elseif current_map(small_cabin) then
			take_letters("armor")
		elseif current_map(start) then
			take_letters("intro")
		elseif current_map(barn1) then
			if eyes_alive then
				take_info("eyes_alive")
			elseif heart_alive then
				take_letters("kill_heart")
			end
		elseif current_map(ending3) then
			take_info("car")
			take_letters("road")
		elseif current_map(ending4) then
			take_info("deadman")
			saw_body = true
		end

	
	end
	
	if text_shown or
				info_shown then
	 if not auto_text then
	  if not btn(❎) then
	   ready_to_close = true
	  end
	 	
	 	
			if ready_to_close then
		 	
		 	if btnp(❎) or btnp(🅾️) then
		 		if text_object == "kill_heart" then
	   		sfx(06)
	   		heart_alive = false
	   	end
	 		text_shown = false
	 		info_shown = false
	   ready_to_close = false
	   text_cooldown = 10
	   end
	 	end
	 end 
 else
 	if text_cooldown > 0 then
 		text_cooldown -= 1
 	end
	end


end



function draw_pickups()

	draw_p(heal)
	draw_p(keys)
	draw_p(buckshot)
	draw_p(letters)
	draw_p(info)
	draw_p(plates)
	draw_p(axe)
	draw_p(gkey)
	draw_p(better_gun)
	
end
-->8
--enemies
function init_enemy()
	enemies = {}
	spiders = {}
	eyes = {}
	web = {}
	web_timer = 0
	wspeed = 3
	web_dir="down"
	slow_timer = 0
	
	spawn_zombie()
	spawn_skeleton()
	spawn_spider()
	spawn_monster()
	spawn_eyes()
	
	zombie_timer = 0
	skeleton_timer = 0
	monster_timer = 0
end


function update_enemy()
	diff_move_enemy()
	for e in all(enemies) do
		e.ox = e.x
		e.oy = e.y
		
		if map_x==e.map_x and 
					map_y==e.map_y then
			
			if e.alive then
				if e.hit then
					e.hit_cooldown -=1
					if e.hit_cooldown <=0 then
						e.hit = false
						e.speed = e.old_speed
					end
				else
--					move_enemy(e)
					animate_enemy()
				end
				if not game_over and 
							aabb_collide(x,y,8,8,
														e.x,e.y,8,8) then
					move_enemy_back(e)
					if armor !=0 then
						armor -=1
					else
						health -=1
					end
					sfx(02)
					hit_player(e)							
				end
			else
				e = nil											
		 end
		
		else
			if e.alive then
				e.x = e.x_base
				e.y = e.y_base
			end
		end

	end

end


function draw_enemy()
	for e in all(enemies) do

		if map_x==e.map_x and 
					map_y==e.map_y then
			
			if e.alive then
				spr(e.s,e.x,e.y)
				
			else 
				if e.typ == "zombie" then		
					if e.death_timer < 8 then
						spr(34, e.fx, e.fy)
						sfx(09)  
					elseif e.death_timer < 16 then
						spr(39, e.fx, e.fy) 
					else
						spr(40, e.fx, e.fy)
					end
				
				elseif e.typ == "skeleton" then
					if not e.sound then	
						sfx(11)
						e.sound = true
					end
					spr(38,e.fx,e.fy)	
				elseif e.typ == "monster" then
					if not e.sound then	
						sfx(11)
						e.sound = true
					end
					spr(5,e.fx,e.fy)
				end
		
			end
		end
	end

end



function move_enemy(e)
	
	if not e.alive and 
								e.hit then 
		return 
	end
				
	local dx = 0
	local dy = 0
	
	if x > e.x then
		dx = 1
	elseif x < e.x then
		dx = -1
	end
	
	if y > e.y then
		dy = 1
	elseif y < e.y then
		dy = -1
	end
	
	local next_x = e.x+dx*e.speed
	if not map_collision(next_x,e.y,
																	8,8,false) then
		e.x = next_x
	end
	
	local next_y = e.y+dy*e.speed
	if not map_collision(e.x,next_y,
																	8,8,false) then
		e.y = next_y
	end
	
	if flr(e.x) == flr(e.ox) then
		e.stuck = true
	else
		e.stuck = false
	end
	
	if flr(e.y) == flr(e.oy) then
		e.stuck = true
	else
		e.stuck = false
	end
	
end

function diff_move_enemy()
	for e in all(enemies) do
		if not e.alive then
			goto continue
		end

		-- target vector
		local dx = x - e.x
		local dy = y - e.y

		-- normalize direction
		local len = sqrt(dx*dx + dy*dy)
		if len == 0 then len = 1 end
		local nx = dx / len
		local ny = dy / len

		-- try full movement
		local new_x = e.x + nx * e.speed
		local new_y = e.y + ny * e.speed

		if not map_collision(new_x, new_y, 8, 8, false) then
			e.x = new_x
			e.y = new_y

		else
			-- try x-only
			new_x = e.x + nx * e.speed
			if not map_collision(new_x, e.y, 8, 8, false) then
				e.x = new_x
			else
				-- try y-only
				new_y = e.y + ny * e.speed
				if not map_collision(e.x, new_y, 8, 8, false) then
					e.y = new_y
				end
			end
		end

		::continue::
	end
end



function animate_enemy()
	
	for e in all(enemies) do
		if e.alive then
			
			if e.x != e.x_base or
						e.y != e.y_base then
						
				e.stimer+=1
				if e.stimer > e.ani_speed then
					e.stimer = 0
					if e.typ == "zombie" then
						e.s = e.s == 34 and 35 or 34
					elseif e.typ == "skeleton" then
						e.s = e.s == 36 and 37 or 36	
					elseif e.typ == "monster" then
						if not e.phase2 then
							e.s = e.s == 98 and 99 or 98						
						else
							e.s = e.s == 3 and 4 or 3
						end
					end
				end
			end
		
		else
			if e.typ == "zombie" then
				if not e.death_timer then
					e.death_timer = 0
				end
				e.death_timer +=1
			end
		
		end
	
	end

end


function hit_player(e)
	if not e.hit then
		e.hit = true
		e.hit_cooldown = 15
		e.speed = 0
		player_hit = true
		add(blood_drops,
		{x=x,
		y=y,
		map_x=map_x,
		map_y=map_y})
	end
end

function move_enemy_back(e)
	if not e.alive then 
	return 
	end
		if x > e.x then
			e.x -= 5*e.speed
		elseif x < e.x then
			e.x += 5*e.speed
		end
				
		if y > e.y then
			e.y -= 5*e.speed
		elseif y < e.y then
			e.y += 5*e.speed
		end
	
end



function update_spiders()
	for s in all(spiders) do
	
		if map_x==s.map_x and 
					map_y==s.map_y then
			update_web(s)
			if s.alive then
				if s.hit then
					s.hit_cooldown -=1
					if s.hit_cooldown <=0 then
						s.hit = false
						s.speed = 0
					end
				else
					move_spider(s)
					animate_spider(s)
				end
				if not game_over then	
					shoot_web(s)						
				end
			else
				s = nil											
		 end
		
		else
			if s.alive then
				s.x = s.x_base
				s.y = s.y_base
			end
		end

	end
end

function draw_spider()
	for s in all(spiders) do

		if map_x==s.map_x and 
					map_y==s.map_y then
			
			if s.alive then
				spr(s.s,s.x,s.y)		
			else 	
				if s.typ == "spider" then
					if not s.sound then	
						sfx(11)
						s.sound = true
					end
					spr(1,s.fx,s.fy)	
				end
			end
		end
	end

end

function move_spider(s)
	
	if not s.alive and 
								s.hit then 
		return 
	end
	if s.x <= s.x_base - s.range then
		s.dir = 1
		
	elseif s.x >= s.x_base + s.range then
		s.dir = -1
	end
	
	local next_x = s.x+s.dir*s.speed
	if not map_collision(next_x,s.y,
																	8,8,false) then
		s.x = next_x
	end
	
--	local next_y = s.y+dy*s.speed
--	if not map_collision(s.x,next_y,
--																	8,8,false) then
--		s.y = next_y
--	end
	
end

function animate_spider(s)

		if s.alive then	
			if s.x != s.x_base or
						s.y != s.y_base then
						
				s.stimer+=1
				if s.stimer > s.ani_speed then
					s.stimer = 0
					s.s = s.s == 41 and 42 or 41
				end
			end
		
		end
	

end

function shoot_web(s)
	if map_x == s.map_x and
				map_y == s.map_y then
		web_timer += 1
		
		if web_timer > 60 then
			if s.y < y then
				add(web,{x=s.x,
												y=s.y,
												web_dir="down",
												player_x = x,
												player_y = y,
												web_stay_timer = 0,
												web_speed = wspeed})
			else
				add(web,{x=s.x,
												y=s.y,
												web_dir="up",
												player_x = x,
												player_y = y,
												web_stay_timer = 0,
												web_speed = wspeed})
			end
			web_timer = 0	
		end							
	end	
									
--	aabb_collide(x,y,8,8,
--						web.x,web.s,8,8) 
end

function draw_web()
	for s in all(spiders) do
		if map_x == s.map_x and
					map_y == s.map_y then
		 for w in all(web) do
					spr(33,w.x,w.y+3)
					sfx()	
			end
		end
	end
end

function update_web(s)
	for w in all(web) do
--		local dx = 0
--		if web_dir=="down" then
--			w.y+=web_speed
--		elseif web_dir=="up" then
--			w.y-=web_speed
----		elseif s.x > ox then
----			w.x-=web_speed
----		elseif s.x < ox then
----			w.x+=web_speed
--		end
--		
--		if w.player_x > w.x then
--			dx = 1
--		elseif w.player_x < w.x then
--			dx = -1
--		end	
--	 w.x += dx*web_speed
--		
--		if w.x > 128+s.map_x then
--			del(web,w)
--		elseif w.x < -2-s.map_x then
--			del(web,w)
--		elseif w.y > 128+s.map_y then
--			del(web,w)
--		elseif w.y < -2-s.map_y then
--			del(web,w)
--		end

		local dx = w.player_x - w.x
		local dy = w.player_y - w.y
	
		-- normalize to unit vector
		local length = sqrt(dx*dx + dy*dy)
		if length > 0 then
			dx /= length
			dy /= length
		end
	
		-- apply movement
		w.x += dx * w.web_speed
		w.y += dy * w.web_speed
		
		if abs(w.x - w.player_x) < 1 
		or abs(w.y - w.player_y) < 1 then
		w.web_stay_timer += 1
		w.web_speed = 0
		if w.web_stay_timer > 20 then
			del(web,w)
		end
		end
	
	if aabb_collide
											(w.x,w.y,8,8,
												x,y,8,8) then
		sfx(02)
		player_slowed = true
		speed = speed/2
		slow_timer = 0
--			spider_hit_player()
					
		if armor !=0 then
					armor -=1
				else
					health -=1
				end
		del(web,w)
	end
		
		
	end
end



function update_eyes()
	for e in all(eyes) do
		
		if map_x==e.map_x and 
					map_y==e.map_y then
			
			if not e.alive then
				e = nil											
		 end
		end
		if dead_eyes() then
			eyes_alive = false
		end
	end

end


function draw_eyes()
	for e in all(eyes) do

		if map_x==e.map_x and 
					map_y==e.map_y then
			
			if e.alive then
				spr(e.s,e.x,e.y)
				
			else
				if not e.sound then
					sfx(14)
					e.sound = true
				end 
				spr(40,e.x,e.y)
		
			end
		end
	end

end

function dead_eyes()
	for e in all(eyes) do 
		if e.alive then
			return false
		end
	end
	return true
end
-->8
--nps/interactions
--function init_girl()
-- girl = {s=79,timer=0}
--end
--
--
--function girl_cry()
--	girl.timer+=1
--	if girl.timer > 40 then
--		girl.s=79
--		girl.timer=0
--	elseif girl.timer > 30 then
--		girl.s=95
--	elseif girl.timer > 20 then
--		girl.s=94
--	end
--end
--
----function draw_girl()
----	if map_y == 32 and map_x ==0 then
----		spr(girl.s,11*8,11*8)
----	end
----end

-->8
--text/ui
function add_window(_x,_y,_w,
																					_h,_txt,
																					_name)
	
	local w = {x=_x,
												y=_y,
												w=_w,
												h=_h,
												txt=_txt,
												name=_name}
	add(window,w)
	return w
end

function draw_window(position)
	for w in all(window) do
		if	w.name == position then
			local wx,wy,ww,wh = w.x,w.y,w.w,w.h
			rectfill2(wx,wy,ww,wh,1)
			rectfill2(wx+1,wy+1,ww-2,wh-2,6)
			rectfill2(wx+2,wy+2,ww-4,wh-4,1)
			wx+=4
			wy+=4
			clip(wx,wy,ww-8,wh-8)
			for i=1, #w.txt do
				local txt=w.txt[i]
				print(txt,wx,wy,6)
				wy+=6
			end
		end
	end
end


function init_txt()
	text_object = nil
	info_object = nil

		add_window(10,50,112,25,
		house_txt,"goal")
		
	add_window(10,40,108,20,
	barricade_txt,"barricade")
	
	add_window(40,80,48,20,
		statue_txt,"statue")	
		
	add_window(40,40,52,25,
		cave_warning_txt,"cave_warning")
	
	add_window(25,80,84,25,
		forest_warning_txt,"forest_warning")

	add_window(15,40,76,25,
	sdoor_txt,"sdoor")
	
	add_window(10,40,102,25,
	better_gun_txt,"better_gun")
	
	add_window(15,40,91,25,
	gkey_txt,"gkey")
	
	add_window(15,40,92,20,
	armor_txt,"armor")
	
	add_window(0,0,128,80,
	intro_txt,"intro")
	
	add_window(20,75,103,20,
		eyes_alive_txt,"eyes_alive")
	
	add_window(20,75,75,20,
		kill_heart_txt	,"kill_heart")
		
	add_window(10,75,115,25,
		hole_txt	,"hole")	
	
	add_window(10,75,87,25,
		car_txt	,"car")
		
	add_window(10,75,95,20,
		road_txt	,"road")
	
	add_window(10,75,46,14,
		deadman_txt	,"deadman")
end



function draw_txt()
	if text_shown or info_shown
	and text_object then
		draw_window(text_object)
	end
	
end
-->8
--txt/positions/templates
zombie_template = {
	x_base = 0*8,
	y_base = 0*8,
	x = 0*8,
	y = 0*8,
	ox = 0,
	oy = 0,
	
	s = 34,
	speed = .7,
	stimer = 0,
	ani_speed = 6,
	stuck = false,

	alive = true,
	map_x = 0,
	map_y = 0,
	hit = false,
	hit_cooldown = 0
	}

player_pos = {map_x,map_y}

start = {map_x=0,map_y=48}
start2 = {map_x=16,map_y=48}

backyard = {map_x=0,map_y=0}
house = {map_x=0,map_y=16}
house2 = {map_x=16,map_y=16}
near_house = {map_x=0,map_y=32}
near_house2 = {map_x=16,map_y=32}
outside_house = {map_x=16,map_y=0}

landslide = {map_x=32,map_y=0} 
graveyard = {map_x=32,map_y=16}

forest1 = {map_x=48,map_y=32}
forest2 = {map_x=32,map_y=32}
forest3 = {map_x=32,map_y=48}
forest4 = {map_x=48,map_y=48}

near_cabin = {map_x=64,map_y=48}
cabin1 = {map_x=64,map_y=32}
cabin2 = {map_x=80,map_y=32}
small_cabin = {map_x=80,map_y=48}

near_cave = {map_x=48,map_y=16}
cave1 = {map_x=48,map_y=0}
cave2 = {map_x=64,map_y=0}
cave3 = {map_x=80,map_y=0}
cave4 = {map_x=96,map_y=0}
cave5 = {map_x=112,map_y=0}

well = {map_x=64,map_y=16}
near_barn = {map_x=80,map_y=16}
barn1 = {map_x=96,map_y=16}
barn2 = {map_x=112,map_y=16}

ending1 = {map_x=96,map_y=32}
ending2 = {map_x=112,map_y=32}
ending3 = {map_x=112,map_y=48}
ending4 = {map_x=96,map_y=48}


-- text
house_txt = {
"to escape this nightmare,",
"you have to destroy 3 eyes",
"and a heart, one is behind"}
													
barricade_txt = {
"i need something",
"to destroy this barricade"}													
													
statue_txt = {
"looks like",
"a statue!"}													

cave_warning_txt = {
"  danger!",
"unsafe cave",
"  stay out"}

forest_warning_txt = {
"      beware!",
"     dence fog",
"and roaming animals"}		

sdoor_txt = {
"it looks like",
"i need a special",
"key for this door"}

better_gun_txt = {
"now i have a better gun!",
"it shoots faster, than ",
"my old one"}

gkey_txt = {
"looks like i can",
"open something secret",
"with this key"}

armor_txt = {
"this should help you",
"to absorb more damage"}

intro_txt = {
"your name is joshua brown,you",
"are a forest ranger. during",
"daily patrol of the forest,",
"you heard someone's scream.",
"after looking for a source of",
"that scream, you've found a",
"trail of blood steps. after",
"following the trail, you",
"appeared in a strange place,",
"that is not shown on maps. now",
"it's your time to figure out,",
"what is going on in this place"}
											
eyes_alive_txt = {
"i can't kill it,",
"untill all eyes are dead"}

kill_heart_txt = {
"to kill the heart",
"press ❎"}

hole_txt = {
"there is a hole beneath you",
"do you want to jump in?",
"press ❎/x to jump"}

car_txt = {
"this is my car!",
"did i finally escape",
"that nightmare?"}

road_txt = {
"i can't go anywhere...",
"i'm so tired"}

deadman_txt = {
"it's me..."}

guide_txt = {
"            controls",
"",
"",
"     ⬆️        move up",
"     ⬇️        move down",
"     ⬅️        move left",
"     ➡️        move right",
"     🅾️(z)     shoot",
"     ❎(x)     interact",
"     f6        save screenshot",
"     f9        save replay",
"",
"",
""}


function spawn_zombie()
--	backyard
	add(enemies,make_zombie(
	{bx=10,by=12,x=10,
	y=12,speed=.7}, backyard
	))
	
-- outside_house
	add(enemies,make_zombie(
	{bx=2,by=5,x=2,y=5,
	speed=1}, outside_house
	))
	add(enemies,make_zombie(
	{bx=10,by=7,x=6,y=3,
	speed=.7}, outside_house
	))
	add(enemies,make_zombie(
	{bx=15,by=10,x=15,y=10,
	speed=.9}, outside_house
	))
	add(enemies,make_zombie(
	{bx=11,by=13,x=11,y=13,
	speed=.6}, outside_house
	))
	
--	forest
	add(enemies,make_zombie(
	{bx=13,by=3,x=13,y=3,
	speed=.6}, forest4
	))

-- cave3
	add(enemies,make_zombie(
	{bx=1,by=1,x=1,y=1,
	speed=1}, cave3
	))

-- cave 5
	add(enemies,make_zombie(
	{bx=4,by=6,x=4,y=6,
	speed=.7}, cave5
	))
	add(enemies,make_zombie(
	{bx=8,by=7,x=8,y=7,
	speed=.7}, cave5
	))
	
-- barn
	add(enemies,make_zombie(
	{bx=18,by=2,x=18,y=2,
	speed=1}, barn1
	))
	add(enemies,make_zombie(
	{bx=21,by=4,x=21,y=4,
	speed=.6}, barn1
	))
	add(enemies,make_zombie(
	{bx=18,by=13,x=18,y=13,
	speed=.8}, barn1
	))
	add(enemies,make_zombie(
	{bx=23,by=13,x=23,y=13,
	speed=.7}, barn1
	))
--	add(enemies,make_zombie(
--	{bx=1,by=1,x=1,y=1,
--	speed=0}, barn1
--	))
	
end


function spawn_skeleton()
--	backyard
--	add(enemies,make_skeleton(
--	{bx=6,by=8,x=6,
--	y=8,speed=1}, backyard
--	))
	 
--	forest
	add(enemies,make_skeleton(
	{bx=3,by=5,x=3,y=5,
	speed=1}, forest2
	))
	add(enemies,make_skeleton(
	{bx=3,by=13,x=3,y=13,
	speed=1}, forest2
	))
	add(enemies,make_skeleton(
	{bx=14,by=7,x=14,y=7,
	speed=1}, forest4
	))
	
-- cabin1
	add(enemies,make_skeleton(
	{bx=4,by=6,x=4,y=6,
	speed=.6}, cabin1
	))
	add(enemies,make_skeleton(
	{bx=12,by=8,x=12,y=8,
	speed=1}, cabin1
	))
	add(enemies,make_skeleton(
	{bx=16,by=12,x=16,y=14,
	speed=1.2}, cabin1
	))

-- cabin2
	add(enemies,make_skeleton(
	{bx=2,by=4,x=2,y=4,
	speed=.8}, cabin2
	))
	add(enemies,make_skeleton(
	{bx=7,by=5,x=7,y=5,
	speed=.7}, cabin2
	))
	add(enemies,make_skeleton(
	{bx=8,by=12,x=8,y=12,
	speed=1}, cabin2
	))
	
-- barn
	add(enemies,make_skeleton(
	{bx=17,by=3,x=17,y=3,
	speed=1}, barn1
	))
	add(enemies,make_skeleton(
	{bx=17,by=6,x=17,y=6,
	speed=1.2}, barn1
	))
	add(enemies,make_skeleton(
	{bx=17,by=14,x=17,y=14,
	speed=.8}, barn1
	))
	add(enemies,make_skeleton(
	{bx=17,by=11,x=17,y=11,
	speed=1}, barn1
	))
	
end

function spawn_spider()
--	add(spiders,make_spider(
--	{bx=33-landslide.map_x,
--	by=3,
--	x=35-landslide.map_x,
--	y=3,
--	speed=.5}, landslide
--	))
--	add(spiders,make_spider(
--	{bx=38-landslide.map_x,
--	by=3,
--	x=35-landslide.map_x,
--	y=3,
--	speed=.5}, landslide
--	))
--	cabin1
	add(spiders,make_spider(
	{bx=6,by=5,x=6,y=5,
	speed=.5}, cabin1
	))
	
-- cave4
	add(spiders,make_spider(
	{bx=6,by=4,x=6,y=4,
	speed=.5}, cave4
	))
	
	
end

function spawn_monster()
--	test
--	add(enemies,make_monster(
--	{bx=4,
--	by=8,
--	x=4,
--	y=8,
--	speed=.5}, start
--	))
	
-- cave2
	add(enemies,make_monster(
	{bx=4,by=3,x=4,y=3,
	speed=.5}, cave2
	))

-- cave3
	add(enemies,make_monster(
	{bx=5,by=12,x=5,y=12,
	speed=.7}, cave3
	))
	
-- cave4
	add(enemies,make_monster(
	{bx=14,by=9,x=14,y=9,
	speed=.7}, cave4
	))
	
-- cave5
	add(enemies,make_monster(
	{bx=6,by=7,x=6,y=7,
	speed=.7}, cave5
	))
	
-- barn
	add(enemies,make_monster(
	{bx=17,by=6,x=17,y=6,
	speed=.8}, barn1
	))
	add(enemies,make_monster(
	{bx=25,by=12,x=25,y=12,
	speed=.7}, barn1
	))
end

function spawn_eyes()
	
	add(eyes,make_eye1(
	{x=11,y=3}, house))
	add(eyes,make_eye2(
	{x=12,y=3}, house))
	
	add(eyes,make_eye1(
	{x=13,y=7}, cabin1))
	add(eyes,make_eye2(
	{x=14,y=7}, cabin1))
	
	add(eyes,make_eye1(
	{x=6,y=4}, cave5))
	add(eyes,make_eye2(
	{x=7,y=4}, cave5))

end
-->8
-- sounds
	
function heart_rate()	
	if heart_alive then	
		htimer += 1
		if htimer > hrate then
			if current_map(barn1) then
				sfx(05)
				htimer = 0
			elseif current_map(barn2) then
				sfx(05)
				htimer = 0
			elseif current_map(near_barn) then
				sfx(21)
				htimer = 0
				
	  end	
		end
	end	
end



function update_music()
	if game_over then
		 music(-1)
		 sfx(40) 
	end
	
	
	if current_map(start) or
				current_map(start2) or
	 		current_map(near_house) or
	 		current_map(near_house2) then
		if last_music != 2 then	
			last_music = 2
			music(last_music)
		end
	elseif current_map(backyard) or
								current_map(outside_house) then
		if last_music != 4 then
			last_music = 4
			music(last_music)
		end
	elseif	current_map(forest2) or
								current_map(forest3) or
								current_map(forest4) or
								current_map(near_cabin) or
								current_map(cabin1) or
								current_map(cabin2) then
		
		if last_music != 5 then
			last_music = 5
			music(last_music)
		end
	
	elseif current_map(cave1) or
								current_map(cave2) or
								current_map(cave3) or
								current_map(cave4) or
								current_map(cave5) then
		if last_music != 7 then
			last_music = 7
			music(last_music)
		end
	elseif current_map(landslide)	or
					 		current_map(graveyard)	or
					 		current_map(near_cave)	or
					 		current_map(forest1) or
					 		current_map(well) then
		if last_music != 9 then
			last_music = 9
			music(last_music)
		end	
	
	elseif current_map(ending1) or
								current_map(ending2) or
								current_map(ending3) then
		if last_music != 12 then
			last_music = 12
			music(last_music)
		end
	else
		if last_music != -1 then
		 last_music = -1
		 music(last_music)
		end
	end
end
__gfx__
00000000000000600000000003ee000003ee000000888880000000000000000000000000000000090900000004000400005b4000000b45000000000000000000
0000000006006036000000003088808830888088008822800000000000000000000800000a900090a990a0904440b440005440000004b5000000000000000000
00700700066637330000000030787880307878800888888000000880000000000000000800aa909090999900444044b000d4b00000044d000000000000000000
000770000033777000000000088838000888380008828820000000000000000008000000990999a09090a0905ddd555500d0000000000d0000000dd55dd00000
000770000637733600000000003ee000003e800008228822000000000000000000000800a99a9a90a99099004440444000d4400000044d0000000d0000d00000
0070070000637733000000000083380000338e00082882800000000000000800000000000a99a99000999000b440b44000544000000445000000050000500000
000000000033736300000000008008800330e0e008888200000000000000080000080080000990000a909a9055dd5ddd005b40000004b50000000d5555d00000
000000000006630000000000080030333808080300000000000000000000000008000000099909909099000044b044b000d0000000000d0000000d0000d00000
00000d0000d000000400040000000000b4b4b4b4b000000000000000040000000000000000000000000000000030000030300000830000000000000000000000
000445000054b0004440444000000000b4b4b4b4b00000000000000004000000000f000b00000000000300003003000330300030030003000000000000000000
00044500005440004440444000000000b4bbb4b4b46611111111100004000000000030010000000030300030300300300a000030000773030000000000000000
0004b55dd55b4000444d444500dd5dd5b4b4b4bbb466ddddddddd100040000004ff3311000dd5000030003000303033003003009003770030000000060000000
00000d0000d000004440444000d00000b4b4b4b4b466dddddddddd10044440004ff3310000d55d500030300300333300030030300030003abbb0bbbb66666666
0000050000500000444044b000500000bbb4b4b4b44444444444444b044444004883311b055555d03030300330033003300083303c000330b44bb44466555500
000005dddd500000444d4bbd00dd5dd5b4b4bbb4b44bbbbbbbbbb44b040004000088300b0d55dd5003030030030300303003030330030303b444460060000000
000000000000000044404b4000d00000b4b4b4b4bbb0000000000bbb0400040000080f000000000000333300003333000003000300030703bbbb006600000000
00666000000000000066600000666000005650000056500000000000066666008800008005555500055555000000000000d0000000000000dd555ddddd55dddd
0600060007006000008680000086800060666060006660000660060008666800088822000858580008585800000000004b500000000000005006600dd000005d
08888800077667700066600000666000060606000006000006000660066666000888822805555550055555500600666044500000090099905006600d55555555
088688000076770006666600066666000066600000666000000600606666666688888888055550500555505006666060b455dd55099990905dd55555500000d5
08666800060666006066606060666060000600000606060000600000066666608828882005055050050550050000666000d00000000099905d00000555555dd5
088688000077666060111060601110600066600060666060000066000011100082288820550505050505050500000000005000000000000055555555d0066005
08888800007660000100010000100100060606000606060006600660010001000888828050050505505000500000000000dddd5500000000d500000dd0066005
0000000000000000050005000050005060000600060000600600000005000500880000885005050550500050000000000000000000000000dddd55ddddd555dd
0006b666000b4b000000000000000000000000000d0000d00044400000444000004440000044400000444000004440000000a000005566000000000000000000
0006b66600bb4b000004000b00000000000000006d0000d6007f700000ff700000ff7000007f700000fff00000fff000000000a0066655608000000008900000
000b406600bb4b000040040bbbbbbbbb000000006dd66dd600fff00000fff00000fff00000fff00000fff00000fff00000a0a000656566609000000000000000
0004400000bb4b000400040b44444444000d000005d66d5003363300033633000336330003363300033333000333330000000000665655600000890000000000
00b4b000000b4b00000b000bbbbbbbbb005d000005d66d50b3466666b3466666b3466666b34666663633343b3633343b000a00a0666666600090000000980080
0044000000bb4b0000bb04000bbb0bbb005d0000055d6550bbf110f0bbf611f0bbf611f0bbf110f00f111fbb0f111fbb00000000655656000080000000000090
004b000000bb4b000bb00040000000000055d000005dd50000101000011001000010010000101000001010000010100000000a00666565000000098000000000
00b0000000bb4b000b0000000000000000d550000055550000b0bb000b000bb000b00bb00bb0b00000b0bb000bb0b000000a0000066666000000000000089000
bb44bbbbbb44444bb44444bb000000000000000000000000000000000005500000000003000000000300000300000000000011111100000000099d909909d909
b000004bb44bb00bb00bb44b00000000000000000000000660000000000550000000003330000000033000333030330000110000001110000999999090990990
44444444b040b004400b040b000011111100000000000066660000000055550000000003300330000030333433033000010000000000011099099d9955959099
400000b4b04045544554040b00016616661000000000006666600000555555550003003433300000000303040300003010000000000000100999559955050050
44444bb4404045544554040400166616666100000000906666090000005555000000333400300000000000044003030310000000000001110099d55511150599
b00550044040400bb004040411111111111111100000aa966aa988660005500000300004000000003033303330033003d1000000000011dd0995511111115500
b0055004b040400bb004040b811111155111111166888aaaa98888660005500003333043330303000303033433330000dd11111111111dd59995110000001599
bbb444bbbb444bbbbbb444bb611551111115511166888888888880000005500000003333433330000000004440000003dd5dd5ddd5ddddd50951100000000555
5000000000000005bbb444bb115665111156651100088888668800000009000033000444400003003000004440000033555dd5ddd5dddd559951000000000059
5000000660000005b0055004000550000005500000000066600000000090900903330444403000330330333344033303dd55d5ddd5dd55559551000000000559
5000000660000005b0055004000000000000000000000066600000000009909000333343333333303303003333330330dd5555555555555d0951000000000599
500000066000000544444bb4000000000000000000000055600000000000990003303333433003003003304443003300dd5dd5dd555555dd0951100000005500
5000000660000005400000b4000000000000000000000056660000000330333333000444400330000000004444000000555dd5ddd5ddd5dd9999101000155599
500000066000000544444444000000000000000000000666560000000303390300044444400030000000004444400000155dd5ddd5ddd1119909100005055099
5000000660000005b000004b000000000000000000000566550000000003390000000440444000000000444400440000011111ddd51110000999595590999090
5000000000000005bb44bbbb00000000000000000000556665000000000030300000440000440000000400400400400000000111111000000900095099959990
55550000111100000033300000333000eeeeedee0000e000000009000339330300004444444400000e000ee0ee000e0000000000000e00000088888ee8888800
55550000111100000073700000737000eeeeedee000000e000909000300933000004444444444000e0e0e0ee0000e0000eeeee0ee0e0e00e082e22e99e22e280
55550000111100000033333000333330eeeeedee00e0e00009099090000030000004444444444000000e00022200e000ee0000e0e000e0eee22228e99e82222e
55550000111100000333300303333003dddddddd000000000000990903303000000444444444400000ee02288822e0ee00eee000e000e0e0e2e822e99e228e2e
00005555000011113033300030333000eedeeeee000e00e003303333300339300004444444444000e00e228888e22e00eee00e0eee00e0e0e2e822e99e228e2e
00005555000011113033330030033330eedeeeee00000000030339030003390300004444444400000ee22228888e2eee000000e00e0ee0e0e82e82e99e28e28e
00005555000011110030033003330303eedeeeee00000e000003390000003300000440000004400000028e222888e20eeeee000e0e0e0ee0e822222ee222228e
00005555000011110300303300303030dddddddd000e0000000030300000300000040000000040000ee28eee2888822e000eeee00e0e0e00ee88882ee28888ee
005550000050005050000000bbbbbbbbb8b8b8b8d55d55d5000000005000000000000005505050500e8288ee2888e22000ee0000000000000000000000000000
555d55000550555050050005b555444bb8b8b8b8d55d555d00000000550000000000005555505550ee028eeee28ee2000eee0000000000000000000000002200
5dd5d550555d5dd000500505b444555bb8bbb8b8d5d5d55d00000000500000000000000550555055e002282ee28882e00e0e00e0222220022222000022222220
5d555d555d5d555005000505b545544bb8b8b8bbd5d555d500000000550000000000005555505550eeee2822e88822e00e0ee0e028eee222228eee22228eee22
d55d55d5d5d5d55500050005bbbbbbbbb8b8b8b85d555d5500000090500000000000000550555055e0002282e8e228ee0e00e00eeeee22eeeeeee22eeeeee22e
dddd55dddddd555500050500000bb000bbb8b8b8d555d5d55550000055000000000000555550555000eee2288e220e000e00ee0e222228888222228882222288
5555d5dd555d005505550050000bb000b8b8bbb85d555d5d000b00005000000000000005505550550eee0022822e8ee0ee000eee888eeee88888eeee8888eeee
dd15d111dd15d11505000000000bb000b8b8b8b85d555d55000b0000550000000000005550505050ee00eeee000ee0eee0000000000000000000000000000000
d04141414141411424414141414141414141414141414141414141414141414184948494849484948494a4b4849484948494000000000084948494a4b4849484
948494a4b4849484948494a4b484948494a4b484948494849400000000008494a4b4008494a4b400000084940000a4b48494008494a4b4008595a4b400008494
d000a100910000700000000000a4b4a10000000084940000410000000000004185958595859585958595a5b5859585958595230000239185958595a5b5859585
958595a5b5859585958595a5b585958595a5b585958595859523000023008595a5b5008595a5b5a4b4008595a4b4a5b58595008595a5b5a4b4008595a4b48595
d0000000000000000000600000a5b5000000000085950000130000008200004184940000000000000000000000008494849491000000a1000000000000a18494
849441004141410041414141410041414141414141234141410023000041a4b400849491008494a5b5a4b400a5b5000000849491000000a5b5849400a5b500a4
d000a4b400009100007000000000000000000000000000001300000000008241859500000000a1000000000000008595859500000000000000a10000b1a18595
859500000000000000000000000000000000000000000000000000000041a5b5008595000085950000a5b50000849400008595000085950000859500008494a5
d0a1a5b500000000000000700000000000000000910000004100000000000041a4b4000000000000000000a10000a4b4a4b400b100910000b100000000008494
8494410082000000000000000000000000000000000000000000005000418494849400a4b40000a10000000000859500000000a4b40000a10000000000859500
d08494a4b4a4b40000000000000000b100000000000000004141414141414141a5b5000000000000000000910000a5b5a5b500a100a1000000b10091a1918595
8595410000000000000000008200005000000000000000000000000000418595859500a5b500000000b1000000a10000000000a5b500000000b1000000a18494
d08595a5b5a5b58595000000000000000000000000a4b4008494a4b4849400c0849400000000000000000000000084948494000000000000000000b10000a4b4
000041000000820000000000000000000000000082000000000000000041000000a4b4000000a1000091000000000000000000000000a1000091000000008595
d0a4b400008494849400000000a4b4000000000000a5b5008595a5b5859500c08595000091000000000000000000859585950000000000a100b10000a100a5b5
d7d7d7e7e7e7e7e7e7e7d7e7f70000000000000000005000000050000041859500a5b50000000000000000000000000000000000000000000000000000849400
d0a5b585958595859570000000a5b50000000000000000a4b4000084948494c0849400000000000000a10000000000000000910000a100000000000000918494
849441000000008200000000000000828200000000000000000000000041a4b400008494b1000000a10000b10000a100000000910000000000000000008595b1
d08494a4b48494a4b40000910000000000000000000000a5b5859585958595c085950000000000000000000000000000000000000000b1a10000000000008595
859541000000000000005000008200000000000000000000000000000041a5b5849485950000910000000000009100000000000000000000000000000000a4b4
d08595a5b58595a5b50000000000910000000000a100008494a4b48494a4b4c084940000a10000000000000000008494a4b4370000b1b10000b100a100008494
849441000000000000000000000000000000005000000000000000000041849485950084940000000000849400008494000000008494000084940000b191a5b5
d08494a4b48494000000700000000000000000000084948595a5b58595a5b5c085950000000000000000000091008595a5b500000000a1000000000000008595
85954100000000000000000000000000000000000000000000000000004185950000008595a5b5a1a4b48595a4b48595a4b400008595a4b48595000000a4b400
d08595a5b58595000000000000000000000000910085958494a4b484940000c0a4b4000000000000000000000000a4b484940000000000000000000000008494
8494410000000000000000000000000050000000500000000000000000418494000084940000a4b4a5b50000a5b5a4b4a5b584940000a5b5a4b4000000a5b5a4
d0a4b40000849400000000000084948494a4b48494a4b48595a5b585958595c0a5b50000000000a1000000000000a5b585950000000000910000009100008595
8595000000000000000023000000000000000000000000005000000000418595a5b585950000a5b5849400859500a5b58494859500859500a5b50000000000a5
d0a5b58595859570006000859585958595a5b58595a5b5a4b4000084948494c0849400000000000000000000000000008494849484948494a4b4849484948494
a4b44100002300002300000000000000000000000017000000001700004184948494008494a4b4008595a4b40084940085958494a4b400849400b1000000a4b4
d08494a4b4849400000000a4b48494a4b48494a4b48494a5b5a4b485958595c085950000000000000000a100000000008595859585958595a5b5859585958595
a5b54141410000230000414117414117411741414117414141414117414185958595008595a5b5000000a5b50085950000008595a5b50085950000009100a5b5
d08595a5b5859500000000a5b58595a5b58595a5b585950091a5b50000a4b4c0849400009100000000000000000000008494849484948494a4b4849484948494
41414141410000000000414141414117414141174141414117414141414184944141414141414141414141414141414141b0b0b0b0b0b0b0f000000000a4b400
d08494a4b48494007000009184948494a4b4009184948494a4b4849400a5b5c0859500000000000000000000000000008595859585958595a5b5859585958595
00000000000023002300000000170041410000170000000000000000004185954100000000000000000000000000004141c1c1d1c1c1d1c1c000000000a5b584
d08595a5b58595000000859585958595a5b5859585958595a5b58595312121114646464646464646464646464600000000000000000000000000000000000000
00000000230000000000000000000041410000000000000000000000004184944100516100000000007186960000004141d1c1d1c1d1c1c1c000000000849485
d08494a4b48494000000a4b48494a4b48494a4b48494a4b48494a4b4c0a4b4464606060606060606060606064600008494000000000000000000000000000000
00000091000000000023009100000041410000000000000000000000004185954100000000000000000000000000004141c1d1c1c1c1d1c1c00000a100859500
d08595a5b58595700000a5b58595a5b58595a5b58595a5b58595a5b5c0a5b54646060606060606060606060646000085950000000000b1000000000000000000
0000000000b1000000000000000000414100000000000000000000000041a4b44100000000000000000000000000004141c1c1d1c1c1c1c1c00000000000a4b4
012121212121212323212121212121212121212121212121212121211191004646060606060606060606060646000000000000000000000000000000000000a1
000000000000000000000000b10000414100000000000000000000000041a5b54100000000000000000000000000004141c1d1c1c1d1c1d1c00000000000a5b5
00008494a494000000000000849400a4b48494a4b4a4b4a4b48494a4b40000464606060606060606060606064600000000000000000000000000000000000000
000000000000000000000000000000414100000000d3000000000000004184944100000000000000000000000000004141212121212121211100000091a4b400
a5b58595a595000070000000859500a5b58595a5b5a5b5a5b58595a5b50000464606060606060606060606064600000000000000000000000000000000000000
000000000000000000000000000000414100000000000000000000000041859541006700001616161616000000000000f2000000000000000000000000a5b500
84948494a4940070000000000000000000000000b10000000000b100000000f2060606060606060606060606f200000000000000910000000000000000000000
000000000000000000000000000000414100000000000000006200000041849441008100001616161616000000000000e2000000000000000000000000008494
85958595a59500000000000000000091000000000000009100000000000000e2060606060606060606060606e200000000000000000000000084940000000000
0000000000000000000000000000001300000000007186960000000000418595410050000016161616160000000000414100000000000000b1000000a1008595
a4b4a4b4849400000000000000000000000000a4b400008494a4b40000a4b4464606060606060606060606064600000000b100000000a1000085950000000000
000000000000000000000000000000130000000000000000000000000041a4b4410000000016161616160000000000414100910000849400000000000000a4b4
a5b5a5b5859500007000000000000000000000a5b585958595a5b58595a5b54646060606060606060606060646910000000000000000000000000000b1000000
000091000000b10000000000000000414100000000120000008200620041a5b54100000000161616161600000000004141000084948595a4b40000000000a5b5
84948494a4b400000000000084940000a4b48494a4b48494a4b40000849400464606060606060606060606064600000000000000000000000000000000000000
00000000000000000000000091000041410000000000000000000000004184944100000000000000000000000000004141a4b485950000a5b534440515a4b400
85958595a5b50000000000008595a5b5a5b58595a5b58595a5b58595859500464606060606060606060606064600000000000085950000000000000000000000
00000000000000000000000000000041414141414141414141414141414185954100000000000000000000000000004141a5b584940085950035450515a5b500
008494a4b400007000000084948494a4b4849484940000a4b48494a4b4a4b44646060606060606060606060646008494a4b4849484948494a4b48494a4b48494
849484948494a4b4849484948494a4b4849484948494a4b4849484948494a4b44100000000000000000000000000004141849485958494008494000515008494
b18595a5b500000000000085958595a5b5859585958595a5b58595a5b5a5b54646464646464646464646464646008595a5b5859585958595a5b58595a5b58595
859585958595a5b5859585958595a5b5859585958595a5b5859585958595a5b54141414141414141414141414141414141859500008595008595000515008595
__label__
k4k4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4ookoo400oo0oo000oo0oo000oo0oo000oo0oo00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4ooooo400ooooo000ooooo000ooooo000ooooo00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4oooook00ooooo000ooooo000ooooo000ooooo00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4koook4000ooo00000ooo00000ooo00000ooo000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
kkk4o4k40000o0000000o0000000o0000000o0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4kkk4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k49994k4000000000000000000000000000000000000000000000000000000000000000000000000000000000005500000000000000000000000000000000000
k49494k4000000000000000000000000000000000000000000000000000000000000000000000000000000000005500000000000000000000000000000000000
k49k94k4000000000000000000000000000000000000000000000000000000000000000000000000000000000055550000000000000000000000000000000000
k49494kk000000000000000000000000000000000000000000000000000000000000000000000000000000005555555500000000000000000000000000000000
k49994k4000000000000000000000000000000000000000000000000000000000000000000000000000000000055550000000000000000000000000000000000
kkk4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000005500000000000000000000000000000000000
k4666kk4000000000000000000000000000000000000000000000000000000000000000000000000000000000005500000000000000000000000000000000000
k46464k4000000000000000000000000000000000000000000000000000000000000000000000000000000000005500000000000000000000000000000000000
k46464k4000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k46464k4000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k46664k4000000000000000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4kk000000000000000055555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
kkk4k4k4000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4kkk4000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000005500000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000005500000000000000000000000000000000000000000000000000000000000
k4kkk4k4000000000000000000000000000000000000000000000000000000000055550000000000000000000000000000000000000000000000000000000000
k4k4k4kk000000000000000000000000000000000000000000000000000000005555555500000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000055550000000000000000000000000000000000000000000000000000000000
kkk4k4k4000000000000000000000000000000000000080000000000000000000005500000000000000000000000000000000000000000000000000000000000
k4k4kkk4000000000000000000000000000000000000080000000000000000000005500000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000005500000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000066600000000000000000000000000000000000000000000000000000000000000000000005500000000000
k4k4k4k4000000000000000000000000000000000600060000000000000000000000000000000000000000000000000000000000000000000005500000000000
k4kkk4k4000000000000000000000000000000000888880000000000000000000000000000000000000000000000000000000000000000000055550000000000
k4k4k4kk000000000000000000000000000000000886880000000000000000000000000000000000000000000000000000000000000000005555555500000000
k4k4k4k4000000000000000000000000000000000866680000000000000000000000000000000000000000000000000000000000000000000055550000000000
kkk4k4k4000000000000000000000000000000000886880000000000000000000000000000000800000000000000000000000000000000000005500000000000
k4k4kkk4000000000000000000000000000000000888880000000000000000000000000000000800000000000000000000000000000000000005500000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005500000000000
k4k4k4k4000000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4kkk4k4000000000055550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4kk000000005555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000055550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
kkk4k4k4000000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4kkk4000000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4kkk4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4kk0000000000000000000000000000000000dd500000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k40000000000000000000000000000000000d55d5000000000000000000000000000000000000000000000000000000000000000000000000000000000
kkk4k4k400000000000000000000000000000000055555d000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4kkk4000000000000000000000000000000000d55dd5000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000005500000000000000000000000000000000000000000066000000000000000000000000000000000000000000000000000000000000000
k4kkk4k4000000000055550000000000000000000000000000000000000000666600000000000000000000000000000000000000000000000000000000000000
k4k4k4kk000000005555555500000000000000000000000000000000000000666660000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000055550000000000000000000000000000000000000090666609000000000000000000000000000000000000000000000000000000000000
kkk4k4k40000000000055000000000000000000000000000000000000000aa966aa9886600000000000000000000000000000000000000000000000000000000
k4k4kkk400000000000550000000000000000000000000000000000066888aaaa988886600000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000005500000000000000000000000000000000000668888888888800000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000000000000000000000888886688000000000000000000000000000000000000000550000000000000000000
k4k4k4k4000000000000000000000000000000000000000004440000000000666000000000000000000000000000000000000000000550000000000000000000
k4kkk4k4000000000000000000000000000000000000000007f70000000000666000000000000000000000000000000000000000005555000000000000000000
k4k4k4kk00000000000000000000000000000000000000000fff0000000000556000000000000000000000000000000000000000555555550000000000000000
k4k4k4k4000000000000000000000000000000000000000033633000000000566600000000000000000000000000000000000000005555000000000000000000
kkk4k4k4000000000000000000000000000000000000000k34666660000006665600000000000000000000000000000000000000000550000000000000000000
k4k4kkk4000000000000000000000000000000000000000kkf110f00000005665500000000000000000000000000000000000000000550000000000000000000
k4k4k4k4000000000000000000000000000000000000000001010000000055666500000000000000000000000000000000000000000550000000000000000000
k4k4k4k400000000000000000000000000000000000000000k0kk000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4kkk4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4kk000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
kkk4k4k4000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000
k4k4kkk4000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4kkk4k4000000000000000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4kk000000000000000055555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
kkk4k4k4000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4kkk4000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4kkk4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088000000000
k4k4k4kk0000000000000000000000000000000000000000000000000000000000dd500000000000000000000000000000000000000000000000000000000000
k4k4k4k40000000000000000000000000000000000000000000000000000000000d55d5000000000000000000000000000000000000000000000000000000000
kkk4k4k400000000000000000000000000000000000000000000080000000000055555d000000000000000000000000000000000000000000000000000000000
k4k4kkk4000000000000000000000000000000000000000000000800000000000d55dd5000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005500000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005500000000000
k4kkk4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055550000000000
k4k4k4kk000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005555555500000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055550000000000
kkk4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005500000000000
k4k4kkk4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005500000000000
k4k4k4k4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005500000000000
k4k4k4k4000000000000000000000000000000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4kkk4k4000000000000000000000000000000000055550000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4kk000000000000000000000000000000005555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000055550000000000000000000000000000000000000000000000000000000000000000000000000000000000
kkk4k4k4000000000000000000000000000000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4kkk4000000000000000000000000000000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000
k4k4k4k4000000000000000000000000000000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000003000000000000000300000000030000030000000000000003000000000000000300000000000000030000000003000003000000000000000300000000
00000033300000000000003330000000033000333030330000000033300000000000003330000000000000333000000003300033303033000000003330000000
00000003300330000000000330033000003033343303300000000003300330000000000330033000000000033003300000303334330330000000000330033000
00030034333000000003003433300000000303040300003000030034333000000003003433300000000300343330000000030304030000300003003433300000
00003334003000000000333400300000000000044003030300003334003000000000333400300000000033340030000000000004400303030000333400300000
00300004000000000030000400000000303330333003300300300004000000000030000400000000003000040000000030333033300330030030000400000000
03333043330303000333304333030300030303343333000003333043330303000333304333030300033330433303030003030334333300000333304333030300
00003333433330000000333343333000000000444000000300003333433330000000333343333000000033334333300000000044400000030000333343333000
33000444400003003300044440000300300000444000003333000444400003003300044440000300330004444000030030000044400000333300044440000300
03330444403000330333044440300033033033334403330303330444403000330333044440300033033304444030003303303333440333030333044440300033
00333343333333300033334333333330330300333333033000333343333333300033334333333330003333433333333033030033333303300033334333333330
03303333433003000330333343300300300330444300330003303333433003000330333343300300033033334330030030033044430033000330333343300300
33000444400330003300044440033000000000444400000033000444400330003300044440033000330004444003300000000044440000003300044440033000
00044444400030000004444440003000000000444440000000044444400030000004444440003000000444444000300000000044444000000004444440003000
00000440444000000000044044400000000044440044000000000440444000000000044044400000000004404440000000004444004400000000044044400000
00004400004400000000440000440000000400400400400000004400004400000000440000440000000044000044000000040040040040000000440000440000

__gff__
0000100000000000000000010101010101010101010000000000000000000000000000000000000000000000010008080004000400000000000000000000000002020201010101000101010101012020000002000001010001010101010120200000000001000000010101010000000001010001010100010101010100000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
78797979797979797979797979797700000048494a4b48494a4b48494a4b4a4b484948494a4b48494a4b4a4b484971757575757575757575757575757575757575752805280526757575757575757575757570757571717575757570707575757575757575757570757575757575757575757575757575757575707075757175
78000000000000000000000000197700000058595a5b58595a5b58595a5b5a5b585958595a5b58595a5b5a5b585971757575757575757075757575757519007100710026282628717171000000717175750000000000000000000000707075757500000075007575000070007575750075757575007575750000000070757175
784849001900001b00004a4b0000770078797979797979797979797979797979790000000000001900191970707171717575757519757000707575750000007171712828002800707171710000757175750000000000000000000000007575757575000000000000000000000075757575757575000000000000000000707575
785859000000000000005a5b0000772278000000000000000000000019000077780000000000000000007100717171757570757171710070000000001971717171707128002828707100717100007575750000340000007171000000007575757575000000000000000000000000750000007575750000340000000000340075
7800000000000000000000000000770078000000000000000000000000000077780000000000001900007171007570717571707000000000000000700000007100707171712800717070707100007575750000000071007100000000007575757575000000000000000000000000007100000000000000007d7d7d7d7d7d7d75
780000000000001900000019000077007800000000000000001b000000000077780000000000000000191900717170717500000000001a00000000000000717171717071717171700071710071000000003400000071757500710000757575757575000000000000000000000000000000000000000000000000007175757575
7800001900000000000000000000770078000000000000000000000000000077780000001b000019190019001a007075750000001900000000001a001b00717171710071007171717134000019000000000000007171757171000000007575757575750000000000000000000000000000000000000000000000007175000075
7800000000000000000000001b0077007800000000000000000000000000007778000000000000000000001b191b1b757571003400001b00000000000070007171007100717171711919003400000075750000707075757100000000007571757575000000000000000034000000700000000000000000000071757571717575
78000000000000001b0000000000772278000000000000000000000000000077780000000000000000001a701a701a7075000000340000000000701a0000000000340000000000000000000000007575757070707000750000000000007575757175750000000000000000000000000000000000000000000000750000007575
781b0000000000000000000000007700780000000000000000000000000072000000007200000000001b19001a1b707575007100000000710000000000001b1900001900003400000000001900007575757000707000000000000000000000757175000000003400000000000000000000000000000071000000000075757575
780000000000000000000000000077007800000019000000000000000000007200720600000000000000001b1b191b70750000001b0000000000000000001b0000343400000034000000000000007070717570700000000000000000000075757500000000000000000000000034000000000000000000340000717100340075
78000000000000000000001a00007700780000000000000007000000000006777800000000000000190000001b700071750000000000190000001b000000000000190000000000001900000019007570757575000000000000000000000040000000000000000000000000000000000000000000003400007571717571007575
780000001a00000000000000000077007800001a00000000000000001a000077780000000000000000001919000071707500000000001a00001900003400000000000000001900000000340000717070717570000000000000000000000052000000000000000000000000000000000000000000000000757500757500757575
78000000000000000000000019007700780000000000000000320000000000777800000007000000000000001a191b757500000000000000000000000000000000000019000000340019001900757170757570000000001900000000000075750075000075757575000000000000757575340075717500757575750071007575
7800000000000000001a0000000077007800001b3200003200000000000000777800000000000000000000001a001a717500000000000000000000000000000000000000000000000000000000757571707570000000000000000034000000757575757575757575000000000075757575750075007575757175717575717575
1414000014141414141414141414141414141400000000000032141414141414140000000000070000000000007100717575757575757500280875757575757575757575757575757575757575757575717575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575
14140000141414141414141414141414141414000028001a000014141414141414000000000000000000000000000000757575757575753333337575757575757575757575750e0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b747474747474747474747474747474747474747474747474747474747474747474
000000000000000000000000000000141400003200280007320000000000001414000000000000000000004700000000001a0000001a000808000000080000190000000000000d57000066000057000066000057000066000057005700570074740000000000006d6d0000000000003202000000000000000000000000000074
00000000000000000000000000000014140000000000000000000000000000141400004700000000000000000000000000001a1900000000000800281a1a00000000000000000d67000067000067000067000067000067000067006700670074740000320000006d6d0000000000000002000000000a00000000000000000074
000000000000000000000000007f7d1414001a0000000032001a003200000014140000000007000047000000000000000000000000730000000000000000000000004c4d00000d00000000000000000000000000000000000000000000000074740000000009006d6d0000090000000a020000000000000000000a0000090074
0000000000000000000000000000001414002800280000000700000000000014140000000000000000070000000047001a00001a1a1900001a0019001a1a000000005c5d00000d5700006600005700005700006600005700065700660057007474000000006c6c6d6d7c7c000000000002000000000000000000000000000074
000000000000000000000000000000141400000000000000000000000000001414004700000000000000000000000000000000000000000000000000000000000000000000003167000067000067060067000067000067000067006700670074740000006c6c6c6d6d7c7c7c00000000020000000a0000000000000000000074
0000000000000000000000000000001414000000000000000000000000000014140000000019000000000000000000000000001a0000001a0000000000001a000000000000003100000000000000000000000000060000000000000600000040006c6c6c6c6c6c6d6d7c7c7c0000000002000000000000000000003200090074
000000000000006869000000000000141400000000320000000000000000001414004700000000454600000000000000000000191a0000000000191a000000001a00000000000d66000666000057000066000066000057000066005700660652006c6c6c6c6c6c02026c6c6c00000000023200000000000000000a0a09000074
006161616161610000000000000000141400000000000000000700000032001414000000000000555600000000470000000000000000000000000000000000000006000000000d67000067000067000067000067000067000067006700670074746c6c6c6c6c6c02026c6c6c000000000200000000000000000a4e4f0a090074
00616161616161000000000000000014140000000000000000000000000000141400000000000000000700000000000000001900000000001a060000001900001900000000000d00000000000000000000000000000000000000000000000074740000006d6d6d7c7c6d6d00000000000200000a0000000000095e5f09090074
006161616161610000000006000600400000000000000600000000000000001414000047000000000000000000000000000000000000000000000000000600000000000006000d57000066000066000057000066000066000032000000000074740000006d6d6d7c7c6d6d00000a0000020000000000320000090a090a000074
006161616161610000060000060000520000060000000000000000000000001414000000000007001900000000000600000000000600000000000000000000000000000000000d6700006700006700006700006700006700000000003200007474000900006d007c7c006d6d0000000002000000000000000a00090909000074
000000000000000000000000000000141400000000000000000000320000001414000000000000000000000000004700000000000000001900000000001919000019000000000d0000000000000000000000000000000000003200000000007474000000000a0000000000000000000a02000000000a00000000000000000074
0000000000000000000000000000001414000000000000320000000000000014140000000047000000000000000000000000000000000000000000000000000000000000000010121212121212121212121212121212121232000000003200747400000000000032000000000000000002000000000000000000090000320074
0000000000000007000000000000001414000000000000000000000000000014484948494a4b4849484948494a4b48494a4b0032000032484948494a4b48494a4b484948494849484948494a4b4849484948494a4b48494849000000320048497400000000000000000000000000003202000000000000000000000000000074
1414141414141400001414141414141414141414141414141414141414141414585958595a5b5859585958595a5b58595a5b0019003200585958595a5b58595a5b585958595859585958595a5b5859585958595a5b58595859003200320058597474747474747474747474747474747474747474747474747474747474747474
__sfx__
000000001864017631156251362511625110000100007620086230a6330d6331064313653186421e6301f62000000000000000000000000000000005630046400463004630056300000000000000000000000000
000100003072034720377203c737007001a7000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00050000281001d12117121201011d1021e100101001c1001d1002010024100271000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
0005000021121131220a12113102111001c1201e12000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
0004000021121131220a1210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000074100700007000070000700007000070000743007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00010000350212d022220232803126022230431602116022210331d041260221e03319031200421203319023130221b021200231c04218031140331304111032100431603413033100340c0250c0340902500000
0004000012021230252c0242100014000140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000010720157201c720237202b720397201770015700147001370012700127001170011700107001070010700007000070000700007000070000700007000070000700007000070000700007000070000700
00030000191212d1242a1222712324122211231710415104141001210016100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200000c03108032060230402207000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001f121181220b1230f1210b120001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
00020000327202a720247201f7201e700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000200000c02108022060230402205030050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002a0212b0221d023140210c022130231802412023100200802005000050000500004000040000400004000040000000000000000000000000000000000000000000000000000000000000000000000000
0002000019321103220c32307321053251432406305093000a3000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000200000e5220f5211052112521135211552117521185211b5211c5211f5312253125535285002b5002f50033500395003e5003f500005000050000500005000050000500005000050000500005000050000500
003c00001f7111d7121b71319711187121671315711137121271311714107120f7140e7130d7140c7130c7020b7040b7000b7000a700087000670004700047000470015700157001570015700157001570015700
003c00001f72000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000300001b7251e7250c72510725247251d7030a70000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0003000002022050220a0220b0221102208002110031f00017000150001b0000a00007000090000f0001100000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500000071100700007000070000700007000070000713007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
300f000000004160141f014270142b0142e0142e0142b0141f0141601413014110141301413014180141b01422014290142b0142b0142b01429014240141f014180141601416014180141f014270142901429014
080f00000352503525035250352503525035250352503525035250552507525075250752507525075250752507525075250752505525035250352503525035250352505525075250752507525075250752507525
000f00000c0330000000000000000c0330000000000000000c0330000000000000000c0330000000000000000c0330000000000000000c0330000000000000000c0330000000000000000c033000000000000000
100f00000210002100021300212002110021300212002110021300212002110021300212002110021300211002130021200211002130021200211002130021200211002130021200211002130021100213002110
000500000070100700007000070000700007000070000703007000070000700007002f70000700007000070000700007000070000700007000070000700007000070000700007000070000700000000000000000
080f00000a5250a5250a5250a5250a5250a5250a5250a52507525055250552503525035250352503525035250352505525055250552507525075250a5250a5250a5250a5250a5250a5250a5250c5250752503525
000f00003571035710307102e71230712357103571235712337103571135710337103071033712357103371230710307103371035711377103771037712377103571035712377123371033710337113571137710
000f00000072000720007200072000720007200072000720007200072000720007200072000720007200072000720007200072000720007200072000720007200072000720007200072000720007200072000720
000f00000772007720077200772007720077200772007720077200772007720077200772007720077200772008720087200872008720087200872008720087200872008720087200872008720087200872008720
000f00000772007720077200772007720077200772007720077200772007720077200772007720077200772006720067200672006720067200672006720067200672006720067200672206720067200672006720
001c00000c0230c1350c1352271400114001352271422715001350013522514001350a015160152e7142e5150c02300135001352271400114001352271422715001350013522514001350a015160152e7143a515
001c00000011407125071251b7143061507125277142771507125071252751407125306150c02327714275150011407125071251b7143061507125277142771507125071252751407125306150c0232771433515
001c00000c02300135001352e71400114001352e7143a51500135001353a514001350a015160152e5142e5150c02300135001352271400114001352271422715001350013522514001350a015160152e7143a515
001c00000011406125061252071430615061252c7143851506125061253f51406125306150c02338514385150011407125071251b7143061507125277142771507125071252751407125306150c0232771433515
000f00002e71030710307103371233712337103371235712307103071133710357103371030712307103071233710337103571035711357103771037712377103071030712337123571037710337113371130710
381900000352503525035250352503525035250352503525035250552507525075250752507525075250752507525075250752505525035250352503525035250352505525075250752507525075250752507525
381900000a5250a5250a5250a5250a5250a5250a5250a52507525055250552503525035250352503525035250352505525055250552507525075250a5250a5250a5250a5250a5250a5250a5250c5250752503525
000f00000c033000000c033000000c0330000000000000000c0330000000000000000c0330000000000000000c0330c0000c033000000c0330000000000000000c0330000000000000000c033000000000000000
000f00000072000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
382300000352503525035250352503525035250352503525035250552507525075250752507525075250752507525075250752505525035250352503525035250352505525075250752507525075250752507525
382300000a5250a5250a5250a5250a5250a5250a5250a52507525055250552503525035250352503525035250352505525055250552507525075250a5250a5250a5250a5250a5250a5250a5250c5250752503525
__music__
01 565c1744
02 56641744
01 175a4344
02 1b584344
03 27424344
01 1d1e4344
02 1d1f4344
01 20214344
02 22234344
01 25424344
02 26424344
03 27424344
01 29424344
02 2a424344

