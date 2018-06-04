local cjson = require('cjson')

local args = {}

if ngx.var.request_method == 'POST' then
    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    args = cjson.decode(body)
end

local args_uri = ngx.req.get_uri_args()
for k,v in pairs(args_uri) do args[k] = v end

local name = args.name
local pwd = args.pwd


local redis = require "resty.redis"
local red = redis:new()

red:set_timeout(1000) -- 1 sec

local ok, err = red:connect("97.64.120.195", 6379)

if not ok then 
    ngx.say("fail to connect : ", err)
else 
    ngx.say("connect success!")
end

red:set('hotuser', 'a json string')
-- red:rpush('user', 'dd')

-- if not res then 
--     ngx.say(cjson.encode(res))
-- else 
--     ngx.say("lrange empty")
-- end
