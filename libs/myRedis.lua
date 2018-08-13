function redis_get_something(hash)
    if rdb[tostring(hash)] then
        return rdb[tostring(hash)]
    end
end

function redis_hget_something(hash, key)
    if rdb[tostring(hash)] then
        if rdb[tostring(hash)][tostring(key)] then
            return rdb[tostring(hash)][tostring(key)]
        end
    end
end

function redis_set_something(hash, value)
    rdb[tostring(hash)] = value
    return true
end

function redis_hset_something(hash, key, value)
    rdb[tostring(hash)] = rdb[tostring(hash)] or { }
    rdb[tostring(hash)][tostring(key)] = value
    return true
end

function redis_get_set_something(hash, value)
    local tmp = redis_get_something(hash)
    redis_set_something(hash, value)
    return tmp
end

function redis_hvals(hash)
    local final = { }
    local tmp = redis_get_something(hash)
    if type(tmp) == 'table' then
        for k, v in pairs(tmp) do
            table.insert(final, v)
        end
    end
    return final
end

function redis_incr(hash, value)
    if not tonumber(value) then
        rdb[tostring(hash)] =(rdb[tostring(hash)] or 0) + 1
        return true
    else
        rdb[tostring(hash)] =(rdb[tostring(hash)] or 0) + tonumber(value)
        return true
    end
    return false
end

function redis_hincr(hash, key, value)
    rdb[tostring(hash)] = rdb[tostring(hash)] or { }
    if not tonumber(value) then
        rdb[tostring(hash)][tostring(key)] =(rdb[tostring(hash)][tostring(key)] or 0) + 1
        return true
    else
        rdb[tostring(hash)][tostring(key)] =(rdb[tostring(hash)][tostring(key)] or 0) + tonumber(value)
        return true
    end
    return false
end

function redis_del_something(hash)
    rdb[tostring(hash)] = nil
    return true
end

function redis_hdelsrem_something(hash, key)
    if rdb[tostring(hash)] then
        rdb[tostring(hash)][tostring(key)] = nil
        return true
    end
    return true
end

function redis_sis_stored(hash, key)
    if rdb[tostring(hash)] then
        if rdb[tostring(hash)][tostring(key)] then
            return true
        end
    end
    return false
end