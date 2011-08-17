--[[
	Indexing values by tuple keys, implemented as a hash tree
	Any array works as a key, even arrays with holes, provided keys.n is set
	or n is passed as parameter to get() and set().

	Procedural interface:
		set(t, keys, e, [n])
		get(t, keys, [n]) -> e

		values(t) -> iterator -> e

		t[k1][k2]...[kn][E] -> e

	Objectual interface:
		([t]) -> idx
		wrap(t) -> idx
		idx.index -> t

		idx[keys] = e			idx:set(keys, e, [n])
		idx[keys] -> e			idx:get(keys, [n]) -> e

		idx:values() -> iterator -> e

]]

function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function shallowcopy(object)
	local t = {}
	for k,v in pairs(object) do
		t[k]=v
	end
	return t
end


local coroutine, pairs, next, select, setmetatable, deepcopy, shallowcopy, table, unpack,math =
	  coroutine, pairs, next, select, setmetatable, deepcopy, shallowcopy, table, unpack,math

setfenv(1, {})

local function const(name)
	return setmetatable({}, {__tostring = function() return name end})
end

local function add(t, keys, e)
	t[keys[1]*32768+keys[2]]=e
end

local function many(t)
	return next(t,next(t))
end

local function set(t, keys, e)
	t[keys[1]*32768+keys[2]] = e
end

local function get(t, keys)
	return 	t[keys[1]*32768+keys[2]]
end

local function yield_values(t)
	for k,v in pairs(t) do
		coroutine.yield(v)
	end
end

local function values(t)
	return coroutine.wrap(yield_values), t
end

local function yield_keys(t,key)
	for k,v in pairs(t) do
		local x,y = math.floor(k/32768),k%32768
		coroutine.yield(x,y)
	end
end

local function keys(t)
	return coroutine.wrap(yield_keys), t
end
--objectual interface

local methods = {}
function methods:set(keys, e, n) set(self.index, keys, e, n) end
function methods:get(keys, n) return get(self.index, keys, n) end
function methods:values() return values(self.index) end
function methods:keys() return keys(self.index) end

local meta = {__type = 'index'}
function meta:__index(k) return methods[k] or get(self.index, k) end
function meta:__newindex(k, v) return set(self.index, k, v) end

local function wrap(t)
	return setmetatable({index = t}, meta)
end

local M = {
	meta = meta,
	methods = methods,
	set = set,
	get = get,
	values = values,
	keys = keys,
	wrap = wrap,
}

return setmetatable(M, {__call = function(_,t) return wrap(t or {}) end})