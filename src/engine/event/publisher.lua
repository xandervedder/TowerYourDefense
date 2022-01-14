Publisher = {}
Publisher.listeners = {}

function Publisher.register(func)
    table.insert(Publisher.listeners, func)
end

function Publisher.publish(event)
    local listeners = Publisher.listeners
    for i = 1, #listeners, 1 do
        listeners[i](event)
    end
end

return Publisher
