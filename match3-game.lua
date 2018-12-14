-- simple match-3 game
-- ifknord@gmail.com
-- my first lua app
-- 13.12.2018

local COUNT_PIECES_IN_MATCH = 3
local values = {'A', 'B', 'C', 'D', 'E', 'F'}
local ROWS = 10
local COLS = 10

local grid = {}
for i=1,ROWS do
  grid[i] = {}     
  for j=1,COLS do
    grid[i][j] = 'A'
  end
end

local function isValidCoords(x, y)
  return not (tonumber(x) == nil or
    tonumber(y) == nil or
    x < 1 or x > #grid or
    y < 1 or y > #grid[x])
end

local function getValue(x, y)
  if isValidCoords(x, y) then
    return grid[x][y]
  end
    return -1
end

local function dump()
-- после каждого тика визуализируем поле (dump())
  print()
  print('Youre game board is:')
  io.write('  ')
  for i=0,COLS-1 do
    io.write(' ' .. i)
  end
  io.write('\n')
  io.write('  ')
  for i=0,COLS-1 do
    io.write(' _')
  end
  io.write('\n')
  for i=1,ROWS do
    io.write (i-1 .. '|')
    for j=1,COLS do
      io.write(' ' ..grid[i][j])
    end
    io.write ('\n')
  end
  print()
end

local function swap(from, to)
  local value = grid[from[1]][from[2]]
  grid[from[1]][from[2]] = grid[to[1]][to[2]]
  grid[to[1]][to[2]] = value
end

local function move(from, to)
-- ждем ввода от пользователя и move перемещает один кристалл
  if not (isValidCoords(from[1], from[2]) or
    isValidCoords(to[1], to[2])) then
    return
  end
  
  swap(from, to)
  
end

local function isMatch(x, y)
  local matchX = 1
    for i = 1, COUNT_PIECES_IN_MATCH - 1 do
      if getValue(x, y) == getValue(x - i, y) then
        matchX = matchX + 1 
      end  
    end
    
    local matchY = 1
    for i = 1, COUNT_PIECES_IN_MATCH - 1 do
      if getValue(x, y) == getValue(x, y - i) then
        matchY = matchY + 1
      end  
    end
    
    return matchX == COUNT_PIECES_IN_MATCH or
      matchY == COUNT_PIECES_IN_MATCH
end

local function isFoundMatches()
  local matchX
  for i=1,ROWS do
    matchX = 1
    for j=1,COLS do
      if (getValue(i, j) == getValue(i, j + 1)) then
        matchX = matchX + 1
      elseif (matchX >= COUNT_PIECES_IN_MATCH) then
        return true
      else
        matchX = 1
      end
  
    end
  end
  
  local matchY
  for j=1,COLS do
    matchY = 1
    for i=1,ROWS do
      if (getValue(i, j) == getValue(i + 1, j)) then
        matchY = matchY + 1
      elseif (matchY >= COUNT_PIECES_IN_MATCH) then
        return true
      else
        matchY = 1
      end
    end
  end
  
  return false
end

local function isPossibleMatches()
  for i=1,ROWS do
    for j=1,COLS do
        local from = {i, j}
        local tol = {i, j-1}
        local tor = {i, j+1}
        local tou = {i-1, j}
        local tod = {i+1, j}
        if (isValidCoords(tol[1], tol[2])) then
          move(from, tol)
          if (isFoundMatches()) then
            move(tol, from)
            return true
          end
          move(tol, from)
        end
        if (isValidCoords(tor[1], tor[2])) then
          move(from, tor)
          if (isFoundMatches()) then
            move(tor, from)
            return true
          end
          move(tor, from)
        end
        if (isValidCoords(tou[1], tou[2])) then
          move(from, tou)
          if (isFoundMatches()) then
            move(tou, from)
            return true
          end
          move(tou, from)
        end
        if (isValidCoords(tod[1], tod[2])) then
          move(from, tod)
          if (isFoundMatches()) then
            move(tod, from)
            return true
          end
          move(tod, from)
        end
    end
  end
  return false
end

local function tick()
-- tick дальше тикают пока происходит хоть одно изменение на поле
-- horizontal
  local matchX
  for i=1,ROWS do
    matchX = 1
    for j=1,COLS do
      if (getValue(i, j) == getValue(i, j + 1)) then
        matchX = matchX + 1
      elseif (matchX >= COUNT_PIECES_IN_MATCH) then
        for k=j-matchX+1, j do
          if (isValidCoords(i, k)) then
            grid[i][k] = '*'
          end
        end
        matchX = 1
      else
        matchX = 1
      end
  
    end
  end
  
  local matchY
  for j=1,COLS do
    matchY = 1
    for i=1,ROWS do
      if (getValue(i, j) == getValue(i + 1, j)) then
        matchY = matchY + 1
      elseif (matchY >= COUNT_PIECES_IN_MATCH) then
        for k=i-matchY+1, i do
          if (isValidCoords(k, j)) then
            grid[k][j] = '*'
          end
        end
        matchY = 1
      else
        matchY = 1
      end
    end
  end
  
  dump()
  
  -- falling down
  for j=1,COLS do
    for i=ROWS,2,-1 do
      if (getValue(i, j) == '*' and getValue(i-1, j) ~= '*') then
        local k = i
        repeat
          local from = {k-1, j}
          local to = {k, j}
          move(from, to)
          k = k+1
        until not(getValue(k, j) == '*' and k <= ROWS)
        
      end
    end
  end
  
  -- generic new elements for empty places
  for i=1,ROWS do
    for j=COLS,1,-1 do
      if (getValue(i, j) == '*') then
          X = math.random(1, 6)
          grid[i][j] = values[X]
      end
    end
  end
  
  dump()
  
  if (isFoundMatches()) then
    print ('YEEES IS MORE MATCH')
    tick()
  end
  
end

local function input(str)
  -- ввод от пользователя - m x y d
  if str:sub(1,1) == 'q' then
      return
  end
  
  if not (str:sub(1,1) == 'm' and
    isValidCoords(str:sub(3,3) + 1, str:sub(5,5) + 1) and
    str:sub(7,7) == 'l' or str:sub(7,7) == 'r' or
    str:sub(7,7) == 'u' or str:sub(7,7) == 'd') then
    print ('input not correct')
    print ('example: m 0 3 r')
    print ('try again')
    return
  end
  
  local from = {tonumber(str:sub(3,3)) + 1, tonumber(str:sub(5,5)) + 1}
  local to =  {tonumber(str:sub(3,3)) + 1, tonumber(str:sub(5,5)) + 1}
  if (str:sub(7,7) == 'l') then
    to[2] = to[2] - 1 
  elseif (str:sub(7,7) == 'r') then
    to[2] = to[2] + 1 
  elseif (str:sub(7,7) == 'u') then
    to[1] = to[1] - 1
  elseif (str:sub(7,7) == 'd') then
    to[1] = to[1] + 1
  end
  
  if not (isValidCoords(to[1], to[2])) then
    dump()
    print ('move not correct')
    print ('example: m 0 3 r')
    print ('try again')
    return
  end
  
  move(from, to)
  if (isFoundMatches()) then
    print ('YEEES! IS MATCH')
    tick()
  else
    print ('NO. IS NOT MATCH')
    move(to, from)
    dump()
  end
  
end

local function init()
-- init заполняет поле (рандом)
  math.randomseed(os.time())
  math.random()
  for i=1,ROWS do
    for j=1,COLS do
      repeat
        X = math.random(1, 6)
        grid[i][j] = values[X]
      until not isMatch(i, j)
    end
  end
end

local function mix()
-- если возможных перемещений - нет, то перемешиваем кристаллы
-- (mix) чтобы возникли новые варианты перемещений - но не
-- возникло новых готовых троек
  init()

end


init()
dump()
print ('For game need input: m x y d')
print ('example: m 0 3 r')
print ('m its mean move')
print ('x y are coords 0..9')
print ('d - one letter direction (lrud - left, right, up, down)')
print ('or enter \'q\' for quit')
local str 
while str ~= 'q' do
  if not (isPossibleMatches()) then
    mix()
    print ('Attention! No possible matches. Thank You for game! Pieces now mixed. For fun!')
    dump()
  end
  print ('Youre move:')
  str = io.read()
  input(str)
end
