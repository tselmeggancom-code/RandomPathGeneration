local stack = {}
stack.__index = stack


function stack.new() --constructor with the metatable to make the instance
   local instance = setmetatable({},stack) -- this allows the creation of the instance
   instance.pointer = 1
   instance.paths = {}
   instance.tableValues = {}
   instance.MaxP = 101
   return instance
end

function stack:Push(value, path) -- push in stack
    if (self.pointer < self.MaxP) then
        table.insert(self.paths, self.pointer, path)
        table.insert(self.tableValues, self.pointer, value)
        self.pointer = self.pointer + 1    
    end
end

function stack:Pop() -- Pop in stack
    if (self.pointer > 1) then -- it is not a zero based indexed language
        local lastPath = table.remove(self.paths)
        self.pointer = self.pointer - 1
        local lastValue = table.remove(self.tableValues)
        return lastValue, lastPath
    end
end

function stack:GetValues() -- getter to get values
    return self.tableValues
end

function stack:ReturnLength() -- getter to get length of values
    return #self.tableValues
end
--This is the stack inplementation#
local collectionofTiles = {}
-------------------------------------------------------------------------------------------------------------------------------------------
local tile = {}

tile.__index = tile

function tile.new(paramx, paramy , i, j)
    local instance = setmetatable({},tile) -- intialize instance
    instance.x = paramx
    instance.y = paramy
    instance.sizex = 50
    instance.mapx = i
    instance.mapy = j
    instance.sizey = 50
    instance.vistied = false
    instance.typeofTile = "EmptyCell"
    return instance
end

function tile:getSizeX() -- encapsulation
    return self.sizex
end

function tile:SetImage(newimage1)
    self.typeofTile = newimage1
end 
function tile:getSizeY()
    return self.sizey
end 

function tile:GetX()
    return self.x
end

function tile:GetY()
    return self.y
end

local imageCache = {}

function tile:GetImage()
    if not imageCache[self.typeofTile] then
        imageCache[self.typeofTile] =
            love.graphics.newImage("assets/" .. self.typeofTile .. ".png")
    end
    return imageCache[self.typeofTile]
end


function tile:GetVisited()
    return self.vistied 
end

function tile:SetVisited(boolval)
    self.vistied = boolval
end

function tile:getNeighbours()
    local nearbytiles = {}
    local mapx = self.mapx
    local mapy = self.mapy

    -- left
    if mapx - 1 >= 1 then
        if collectionofTiles[mapx - 1][mapy]:GetVisited() == false then
            table.insert(nearbytiles, collectionofTiles[mapx - 1][mapy])
        end
    end

    -- right
    if mapx + 1 <= 10 then
        if collectionofTiles[mapx + 1][mapy]:GetVisited() == false then
            table.insert(nearbytiles, collectionofTiles[mapx + 1][mapy])
        end
    end

    -- up
    if mapy - 1 >= 1 then
        if collectionofTiles[mapx][mapy - 1]:GetVisited() == false then
            table.insert(nearbytiles, collectionofTiles[mapx][mapy - 1])
        end
    end

    -- down
    if mapy + 1 <= 10 then
        if collectionofTiles[mapx][mapy + 1]:GetVisited() == false then
            table.insert(nearbytiles, collectionofTiles[mapx][mapy + 1])
        end
    end

    return nearbytiles
end

----------------------------------------------------------------------------I believe this to be the main 
local mapx = 150
local mapy = 50
local startx = 1
local starty = 1
local endx = 1
local endy = 1
local endpath = {}

function love.load() --- global stuff
    TileGen()
end

function TileGen()
    for i = 1, 10 do
        collectionofTiles[i] = {}
        for j = 1, 10 do
            local newtile = tile.new(mapx,mapy,i,j)
            collectionofTiles[i][j] = newtile
            newtile.typeofTile = "Path"                       ---this is change bro of the tiletype rememeber
            mapx = mapx + 50
        end
        mapy = mapy + 50
        mapx = 150
    end
end

function RandomTwoTiles()
    startx,starty,endx,endy = TwoValidNumber(1,1,1,1)
    local tile = collectionofTiles[startx][starty]
    local tile2 = collectionofTiles[endx][endy]
    tile.typeofTile = "TwoNodeFound"
    tile2.typeofTile = "TwoNodeFound"
end
     


function TwoValidNumber(x,y,x1,y1) -- I use recursion
    math.randomseed(os.time()*1000000000)
    if x1 - 3 > x then -- this range is a detection thing
        return x,y,x1,y1
    else
        local x = math.random(1,5)
        local y = math.random(1,10)
        local x1 = math.random(1,10)
        local y1 = math.random(1,10)
        return TwoValidNumber(x,y,x1,y1)
    end
end

function DepthFirstSearch()
    local goal = collectionofTiles[endx][endy]
    local stack = stack.new()
    local RootNode = collectionofTiles[startx][starty]
    local path = {RootNode}
    RootNode:SetVisited(true)
    stack:Push(RootNode, path)
    while stack:ReturnLength() > 0 do 
        local current,newpath = stack:Pop()
        local neighbours = current:getNeighbours()


        for i = #neighbours, 2, -1 do  ----ai --knuth algorithims 
            local j = math.random(i)  ----
            neighbours[i], neighbours[j]= neighbours[j], neighbours[i] ---
        end-----


        if current == goal then
           endpath = newpath
           break
        end

        for index,tiles in ipairs(neighbours) do
            if tiles:GetVisited() == false then
                    tiles:SetVisited(true)
                    local newPath = {unpack(newpath)}
                    table.insert(newPath, tiles)
                    stack:Push(tiles, newPath)
            end 
        end
    end
end



function love.draw()
    for i = 1, 10 do
        for j = 1, 10 do
            local curtile = collectionofTiles[i][j]
            local hor = curtile:GetImage()
            love.graphics.draw(hor,curtile:GetX(),curtile:GetY())
        end
    end
end

function FinalPath()
    for index, items in ipairs(endpath) do
        items.typeofTile = "thing"
    end
    local RootNode = collectionofTiles[startx][starty]
    local tile = collectionofTiles[endx][endy]
    tile.typeofTile = "TwoNodeFound"
    RootNode.typeofTile = "TwoNodeFound"
end




function Reset()
    for i = 1, 10 do
        for j = 1, 10 do
            local curtile = collectionofTiles[i][j]
            curtile:SetVisited(false)
            curtile.typeofTile = "Path"
        end
    end
end


function love.mousepressed(x,y,button)
    if button == 1 then
        Reset()
        RandomTwoTiles() -- when the mouse button is pressed yh
        DepthFirstSearch()
        FinalPath()
    end
end