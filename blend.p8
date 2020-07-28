pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- blend
-- by ampersands

game = {}
p    = {}
es   = {}
os   = {}

function _init()
 game_init()
 player_init()
end

function game_init()
 game.state="title"
 game.frm=0
 game.speed=1
 game.rad=60
 game.col=init_col()
 game.frm_rate=60
 map(0,0)
 palt(8,true)
 palt(0,true)
end

function _update60()
 game.frm+=1
 if (game.state=="title") then
  title_update()
  player_update()
  env_update()
 elseif (game.state=="init") then
  player_update()
  enemy_update()
  env_update()
 elseif (game.state=="play") then
  player_update()
  enemy_update()
  env_update()
 elseif (game.state=="end") then
  env_update()
  enemy_update()
  end_update()
 end
end

function _draw()
 cls()
 if (game.state=="title") then
  title_draw()
  env_draw()
  player_draw()
 elseif (game.state=="init") then
  env_draw()
  enemy_draw()
  player_draw()
 elseif (game.state=="play") then
  env_draw()
  enemy_draw()
  player_draw()
 elseif (game.state=="end") then
  env_draw()
  enemy_draw()
  end_draw()
 end
end
-->8
-- title, init, end

function title_update()

end

function title_draw()

end

function init_update()

end

function init_draw()

end

function end_update()
 if (btnp(⬆️)) then
  reset()
 end

end

function end_draw()

end

function reset()
 game_init()
 player_init()
 es={}
 
 game.state="init"
end
-->8
-- draw library

-- player draw
function player_draw()
 pal()
 pal(7,p.col[7])
 spr(1,p.x,p.y)
 pal()
 pal(8,p.col[6])
 spr(3,p.x,p.y)
 pal()
 pal(8,p.col[4])
 spr(4,p.x,p.y)
 pal()
 pal(8,p.col[2])
 spr(5,p.x,p.y)
 
 -- fill corrupted sprites
 if (p.corrupted) then
  -- calculate spr
  cor_frm=corrupt_frame()
  if (cor_frm>0) then
   pal()
   pal(8,p.col[5])
   spr3=p.spr_lrg[cor_frm]
   spr(spr3,p.x,p.y)
   pal()
   pal(8,p.col[3])
   spr2=p.spr_med[cor_frm]
   spr(spr2,p.x,p.y)
   pal()
   pal(8,p.col[1])
   spr1=p.spr_sml[cor_frm]
   spr(spr1,p.x,p.y)
   
  end
 end
end
-->8
-- misc functions

function calc_dist2(x1,y1,x2,y2)
 local x_sqr=x2-x1
 local y_sqr=y2-y1
 return x_sqr*x_sqr+y_sqr*y_sqr
end

function init_col()
 col_tbl = {}
 for i=1,12 do add(col_tbl,i)
 end
 del(col_tbl,7)
 del(col_tbl,8)
 return shuffle(col_tbl)
end

function shuffle(tbl)
 for i=#tbl, 2, -1 do
  local j = flr(rnd(i))+1
  tbl[i],tbl[j]=tbl[j],tbl[i]
 end
 return tbl
end

function bound_collide(p)
	if (p.x+p.dx>121
	 or p.x+p.dx<-1
  or p.y+p.dy>121 
  or p.y+p.dy<-1) then
  return true
 end
 return false 
end

function oasis_collide(p,o)
 if (o!=nil) then
	 -- if p within o area
	 local dist2 = 
	 calc_dist2(o.x,o.y,p.x,p.y)
	 if (dist2 < (o.rad*o.rad)) then
	  --printh("inside")
	  return true
	 end
	 --printh("outside")
	 return false
	end
end

function enemy_collide(p)
 return true
end

function set_quadrant(o,p)
 if (p.x<60) then o.x=60
 else o.x=30 
 end
 if (p.y<60) then o.y=60
 else o.y=30
 end 
end

function check_corrupt(obj,o_col)
 for x=1,#obj.col-1 do
  if (obj.col[x]!=o_col) then
   return false
  end
 end
 return true
end

function corrupt_frame()
 count=game.frm%game.frm_rate*2 
 if (count<game.frm_rate/2) then
  return 1
 else
  return 2
 end
end
-->8
-- player

function player_init()
 p.x=60
 p.y=60
 p.dx=0
 p.dy=0
 p.w=6
 p.h=6
 p.xspd=32
 p.yspd=32
 p.acc=1
 p.drg=0.01
 p.col={0,0,0,0,0,0,7}
 p.spr_sml={6,7}
 p.spr_med={8,9}
 p.spr_lrg={10,11}
 p.core=nil
 p.corrupted=false
 p.corrupt_frm=0

end

function player_update()
 if (btn(⬅️)) p.dx-=p.acc
	if (btn(➡️)) p.dx+=p.acc
 if (btn(⬆️)) p.dy-=p.acc
	if (btn(⬇️)) p.dy+=p.acc

 -- cap diagonal speed
 if (p.dx*p.dx+p.dy*p.dy>1) then
  diag=sqrt(p.dx*p.dx+p.dy*p.dy)
  p.dx/=diag
  p.dy/=diag
 end
 
 -- max speed
 p.dx=mid(-p.xspd,p.dx,p.xspd)
 p.dy=mid(-p.yspd,p.dy,p.yspd)
 
 oasis_hit=oasis_collide(p,os[#os])
 if (oasis_hit) then
  -- start corruption
  if (p.core==nil) then
   p.core={}
   p.corrupted=true 
   p.core.col=os[#os].col
   p.core.stg=1
   p.col[p.core.stg]=p.core.col
   p.core.stg+=1
   p.col[p.core.stg]=p.core.col
  end
 end
 
 -- increment corruption
 if (p.corrupted) then
  p.corrupt_frm+=1
  show=p.corrupt_frm%game.frm_rate==0
  if (show) then
   if(p.corrupted and 
	  check_corrupt(p,os[#os].col)) then
	 -- freeze all motor functions
	 -- game over
    p.col[#p.col]=p.core.col
    game.state="end"
   end
   
   if (p.core.stg<6) then
    p.core.stg+=1
    p.col[p.core.stg]=p.core.col
    p.core.stg+=1
    p.col[p.core.stg]=p.core.col

 	 end
  end
  
 end
 
 bound_hit=bound_collide(p)
 if (bound_hit) then
  -- stop at wall
  p.x=mid(-1,p.x+p.dx,121)
  p.y=mid(-1,p.y+p.dy,121)
  
 else
  p.x+=p.dx
  p.y+=p.dy
 end
 
 enemy_hit=enemy_collide(p)
 if (enemy_hit) then
  -- swap enemy color
  -- two way bump
  -- change enemy state to chase
  
 end

 -- apply drag
 if (abs(p.dx)>0) p.dx*=p.drg
 if (abs(p.dy)>0) p.dy*=p.drg

 -- stop if slowed enough
 if (abs(p.dx)<0.02) p.dx=0
 if (abs(p.dy)<0.02) p.dy=0
 
end




-->8
-- enemy
e_n_type={1,2,3,4,5}
e_c_type={1,2,3,4,5}
e_base_spd=1

-- different types spawn
e_dif=1

function enemy_update()
 -- update enemy position
 
 -- do
end

function enemy_draw()
 foreach(es,e_draw)
end

function e_init()
 -- determine enemy position
 -- determine enemy neutral t
 -- determine enemy col
 -- determine enemy chase t
end

function e_draw()

end
-->8
-- oasis

function env_update()
 // increase rad of circle
 foreach(os,o_update)
 // remove 2big circles & spwn
 foreach(os,o_chk)
 
 if (#os<1) init_oasis()
end

function env_draw()
 foreach(os, o_draw)
end

function init_oasis()
 local o = {}
 set_quadrant(o,p)
 o.x=flr(rnd(30))+o.x
 o.y=flr(rnd(30))+o.y
 o.rad=1
 o.grow=.3
 o.col=game.col[1]
 o.s_anim=100
 o.s_anim_spd=6
 o.s_rad=0
 o.active=true
 add(os,o)
end

function o_draw(o)
 if (o.s_anim > 0) then
  circfill(o.x,o.y,o.s_rad,o.col)
 else
  circfill(o.x,o.y,o.rad,o.col)
 end
end

function o_update(o)
 if (o.s_anim > 0) then
  o.s_anim-=1
  if (o.s_anim%o.s_anim_spd==1) then
   o.s_rad=o.s_anim%5
  end
 else
  o.rad+=o.grow*game.speed
 end
end

function o_chk(o)
 if (o.rad>140 and o.active) then
  game.speed+=.05
  del(game.col,o.col)
  o.active=false
  init_oasis()
  add(game.col,o.col)
 end
 if (o.rad>400 and not o.active) then
  del(os,o)
 end
 
end
__gfx__
00000000007777007700007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000070000707000000700888800000000000000000000000000000000000000000000000000000808000080800000000000000000000000000000000000
00700700700000070000000008888880008888000000000000000000000000000008080000808000008888800888880000000000000000000000000000000000
00077000700000070000000008888880008888000008800000008000000800000088800000088800088888000088888000000000000000000000000000000000
00077000700000070000000008888880008888000008800000080000000080000008880000888000008888800888880000000000000000000000000000000000
00700700700000070000000008888880008888000000000000000000000000000080800000080800088888000088888000000000000000000000000000000000
00000000070000707000000700888800000000000000000000000000000000000000000000000000008080000008080000000000000000000000000000000000
00000000007777007700007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
