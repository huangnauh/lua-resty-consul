# vim:set ft= ts=4 sw=4 et:

use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

#repeat_each(2);

plan tests => repeat_each() * (6 * blocks());

my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;$pwd/t/lib/?.lua;;";
    lua_package_cpath "/usr/local/openresty/lualib/?.so;;";
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
            local cjson = require "cjson.safe"
            consul.init(config)
            ngx.say(cjson.encode(config.test))
        ';
    }
    location = /config {
        content_by_lua '
            local config = require "config"
            local api = require "resty.consul.api"
            ngx.say(api.get_kv_blocking(config.consul.cluster, config.consul.config_key_prefix .. "upstreams/test?raw"))
        ';
    }


--- pipelined_requests eval
["GET /config", "GET /t"]
--- response_body eval
['{
"servers": [
{"fail_timeout": 15, "host": "127.0.0.1", "port":80, "weight": 2, "max_fails": 6}
],
"keepalive": 20
}
',
'{"cluster":[{"servers":[{"host":"127.0.0.1","weight":2,"fail_timeout":15,"max_fails":6,"port":80}],"keepalive":20}]}
'
]
--- no_error_log
[error]
