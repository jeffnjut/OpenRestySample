local cjson = require('cjson')

local args = {}

ngx.say('success')
return

if ngx.var.request_method == 'POST' then
    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    args = cjson.decode(body)
end

local args_uri = ngx.req.get_uri_args()
for k,v in pairs(args_uri) do args[k] = v end

local name = args.name
local email = args.email
local message = args.message

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

local res, err = db:query(string.format("insert into contactme(name, email, message) values(%s, %s, %s)", qs(name), qs(email), qs(message)))

if err then
   ngx.log(ngx.ERR, err)
end
ngx.say('success')
