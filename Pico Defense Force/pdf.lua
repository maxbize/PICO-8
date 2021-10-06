ants = {}

function _init()
  palt(0, false)
  palt(1, true)

  for i=1,100 do
    local ant = {
      frame = flr(rnd(4)),
      i = 0,
      x = rnd(128),
      y = rnd(128),
      update = function(self) 
        self.i += 1
        if self.i > 4 then
          self.i = 0
          self.frame = (self.frame + 1) % 4
        end
      end,
      draw = function(self) 
        spr(self.frame + 1, self.x, self.y, 1, 1, false, true) 
      end
    }
    add(ants, ant)
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


