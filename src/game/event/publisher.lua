---@class Publisher
local Publisher = {}
Publisher.listeners = {}

---Registers a method to a certain topic.
---@param identifier any
---@param topic string
---@param func function
function Publisher.register(identifier, topic, func)
    table.insert(Publisher.listeners, { identifier = identifier, topic = topic or "*", method = func })
end

---Deregisters a listener.
---@param identifier string
function Publisher.deregister(identifier)
    local listeners = Publisher.listeners
    for i = #listeners, #listeners, -1 do
        if listeners[i].identifier == identifier then
            table.remove(Publisher.listeners, i)
        end
    end
end

---Publishes an event.
---@param event Event
function Publisher.publish(event)
    local listeners = Publisher.listeners
    local eventName = event:getName()
    for i = 1, #listeners, 1 do
        local listener = listeners[i]
        if listener.topic == eventName or listener.topic == "*" then
            listener.method(event)
        end
    end
end

return Publisher
