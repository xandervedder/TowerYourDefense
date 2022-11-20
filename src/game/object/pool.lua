--[[
    Represents a pool of objects with multiple useful helper methods.
    Has the ability to temporarily 'delete' entries and is able to restore 'deleted' entries.
]]

---@class Pool
local Pool = {}
Pool.__index = Pool

setmetatable(Pool, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

---@generic T
---@param objects T[]
---constructor
function Pool:init(objects)
    ---@private
    self.softDeleted = {}
    ---@private
    self.objects = objects or {}
end

---Adds an object to the pool.
---@generic T
---@param object T
function Pool:add(object)
    table.insert(self.objects, object)
end

---Deletes an object from the pool.
---@generic T : GameObject
---@param object T
function Pool:delete(object)
    for i = #self.objects, 1, -1 do
        if self.objects[i] == object then
            table.remove(self.objects, i)
        end
    end
end

---Removes all objects from the pool by a given predicate.
---@generic T : GameObject
---@param predicate fun(object: T) : boolean
function Pool:deleteBy(predicate)
    for i = #self.objects, 1, -1 do
        if predicate(self.objects[i]) then
            table.remove(self.objects, i)
        end
    end
end

---Soft deletes an object that is able to be restored at a later time.
---@generic T : GameObject
---@param object T
function Pool:softDelete(object)
    for i = #self.objects, 1, -1 do
        if self.objects[i] == object then
            table.insert(self.softDeleted, self.objects[i])
            table.remove(self.objects, i);
        end
    end
end

---Soft deletes all objects given a certain predicate.
---@generic T : GameObject
---@param predicate fun(object: T) : boolean
function Pool:softDeleteBy(predicate)
    for i = #self.objects, 1, -1 do
        if predicate(self.objects[i]) then
            table.insert(self.softDeleted, self.objects[i])
            table.remove(self.objects, i);
        end
    end
end

---Restores the previously removed objects.
function Pool:restore()
    for _, object in pairs(self.softDeleted) do
        table.insert(self.objects, object)
    end
end

---Returns the size of the pool.
---@return integer
function Pool:size()
    return #self.objects
end

---Returns the objects of the pool.
---@generic T : GameObject
---@return T[]
function Pool:get()
    return self.objects
end

---Gets all objects given a certain predicate.
---@generic T : GameObject
---@param predicate fun(object: T) : boolean
---@return T[]
function Pool:getBy(predicate)
    local objects = {}
    for _, object in pairs(self.objects) do
        if predicate(object) then
            table.insert(objects, object)
        end
    end
    return objects
end

---Filters by type, works using the type property of the GameObject.
---@generic T : GameObject
---@param type string
---@return T[]
function Pool:getByType(type)
    return self:getBy(function(o) return o.type == type end)
end

return Pool
