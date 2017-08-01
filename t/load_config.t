# vim:set ft= ts=4 sw=4 et:

use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

#repeat_each(2);

plan tests => repeat_each() * (6 * blocks());

my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;$pwd/t/lib/?.lua;;";
    lua_package_cpath "/usr/local/openresty/lualib/?.so;;";
    lua_shared_dict load 1m;
};

no_long_string();
#no_diff();

run_tests();

__DATA__

=== TEST 1: config
--- http_config eval: $::HttpConfig
--- config
    location = /t {
        content_by_lua '
            local config = require "config"
            local consul = require "resty.consul.config"
            local rload = require "resty.load"
            local cjson = require "cjson.safe"
            consul.init(config)
            rload.init(config)
            local abc = require "module.abc"
            ngx.say(abc.version)
        ';
    }
    location = /config {
        content_by_lua '
            local config = require "config"
            local api = require "resty.consul.api"
            ngx.say(api.get_kv_blocking(config.consul.cluster, config.consul.config_key_prefix .. "lua/module.abc?raw"))
        ';
    }


--- pipelined_requests eval
["GET /config", "GET /t"]
--- response_body eval
['local f = {version="abc"}
return f
',
'abc
'
]
--- no_error_log
[error]