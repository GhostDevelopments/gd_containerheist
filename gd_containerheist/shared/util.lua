-- Shared Utilities
Util = {}

function Util.ShuffledTable(t)
    local shuffled = {}
    for i, v in ipairs(t) do shuffled[i] = v end
    for i = #shuffled, 2, -1 do
        local j = math.random(i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end
    return shuffled
end
