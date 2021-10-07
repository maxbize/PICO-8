ants = {}

function _init()
  palt(0, false)
  palt(1, true)

  for i=1,100 do
    spawn_ant(rnd(128), rnd(128))
  end
end

function _update60()
  for ant in all(ants) do
    ant.update(ant)
  end
end

function _draw()
  cls(1)

  for ant in all(ants) do
    ant.draw(ant)
  end

  print('cpu: '..(stat(1) < 0.1 and '0' or '')..flr(stat(1) * 100), 1, 1, 0)
  --print('mem: '..stat(0), 1, 13, 0)
end

-- rotate a sprite
-- col 15 is transparent
-- sx,sy - sprite sheet coords
-- x,y - screen coords
-- a - angle
-- w - width in tiles
function rspr(sx,sy,x,y,a,w)
    local ca,sa=cos(a),sin(a)
    local srcx,srcy
    local ddx0,ddy0=ca,sa
    local mask=shl(0xfff8,(w-1))
    w*=4
    ca*=w-0.5
    sa*=w-0.5
    local dx0,dy0=sa-ca+w,-ca-sa+w
    w=2*w-1
    for ix=0,w do
        srcx,srcy=dx0,dy0
        for iy=0,w do
            if band(bor(srcx,srcy),mask)==0 then
                local c=sget(sx+srcx,sy+srcy)
    -- set transparent color here
                if (c~=15) pset(x+ix,y+iy,c)
            end
            srcx-=ddy0
            srcy+=ddx0
        end
        dx0+=ddx0
        dy0+=ddy0
    end
end


--------------------
-- Ant class
--------------------

function spawn_ant(x, y)
  local ant = {
    update = _ant_update,
    draw = _ant_draw,
    x = x,
    y = y,
    angle = 0,           -- animation angle (0-360)
    i = rnd(4),          -- animation timer
    frame = flr(rnd(4)), -- animation frame
  }
  add(ants, ant)
end

function _ant_update(self)

  -- advance animation state
  self.i += 1
  if self.i > 3 then
    self.i = 0
    self.frame = (self.frame + 1) % 4
  end
end

-- todo: optimize tokens
function _ant_draw(self)
  if     self.angle <  22.5 then spr(self.frame     , self.x, self.y, 1, 1, false, false) -- S
  elseif self.angle <  67.5 then spr(self.frame + 16, self.x, self.y, 1, 1, false, false) -- SW
  elseif self.angle < 112.5 then spr(self.frame + 32, self.x, self.y, 1, 1, false, false) -- W
  elseif self.angle < 157.5 then spr(self.frame + 16, self.x, self.y, 1, 1, false, true ) -- NW
  elseif self.angle < 202.5 then spr(self.frame     , self.x, self.y, 1, 1, false, true ) -- N
  elseif self.angle < 247.5 then spr(self.frame + 16, self.x, self.y, 1, 1, true , true ) -- NE
  elseif self.angle < 292.5 then spr(self.frame + 32, self.x, self.y, 1, 1, true , false) -- E
  elseif self.angle < 337.5 then spr(self.frame + 16, self.x, self.y, 1, 1, true , false) -- SE
  else                           spr(self.frame     , self.x, self.y, 1, 1, false, false) -- S
  end
  --rspr(self.frame * 8, 0, self.x, self.y, 0.125, 1) 
end

--------------------
-- 
--------------------

