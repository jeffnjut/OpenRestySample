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

local mysql = require "resty.mysql"
local db, err = mysql:new()
if not db then
    ngx.say("failed to instantiate mysql: ", err)
    return
end

db:set_timeout(1000) -- 1 sec

local ok, err, errcode, sqlstate = db:connect{
    host = "97.64.120.195",
    port = 3307,
    database = "testdb",
    user = "testjeff",
    password = "123456",
    charset = "utf8",
    max_packet_size = 1024 * 1024,
}

if not ok then
    ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
    return
end

local qs = ngx.quote_sql_str

-- SQL注入
-- http://localhost:8081/a/login?name=jeff&pwd=1234' or '1'='1
-- local res, err = db:query(string.format("select pwd from users where name = %s ", qs(name)))
local res, err = db:query(string.format("select pwd from users where name = '%s' and pwd = '%s' ", name, pwd))

if err then
   ngx.log(ngx.ERR, err)
end

ngx.log(ngx.ERR, cjson.encode(res))
ngx.log(ngx.ERR, name)

if #res > 0 then 
    ngx.say(cjson.encode({name=name, success=true}))
else
    ngx.say(cjson.encode({name=name, success=false}))
end

-- local a = res[1]
-- if a.pwd == pwd then 
--     ngx.say('{"name":name, "success":"true"}')
-- else
--     ngx.say('{"name":name, "success":"false"}')
-- end
