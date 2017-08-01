# vim:set ft= ts=4 sw=4 et:

use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

# repeat_each(2);

plan tests => repeat_each() * (6 * blocks());

my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;$pwd/t/lib/?.lua;;";
    lua_package_cpath "/usr/local/openresty/lualib/?.so;;";
    lua_shared_dict locks 1m;
    lua_shared_dict cache 1m;
    lua_shared_dict mutex 1m;
    lua_shared_dict state 1m;

    init_by_lua '
        local config = require "config"
        local checkups = require "resty.checkups"
        local consul = require "resty.consul.config"
        checkups.prepare_checker(config)
        consul.init(config)
    ';
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
            local checkups = require "resty.checkups"
            local cjson = require "cjson.safe"
            checkups.create_checker()
            ngx.sleep(2)
            ngx.say(cjson.encode(config.abc))
        ';
    }
    location = /config {
        content_by_lua '
            local config = require "config"
            local api = require "resty.consul.api"
            ngx.say(api.get_kv_blocking(config.consul.cluster, config.consul.config_key_prefix .. "abc?raw"))
        ';
    }


--- pipelined_requests eval
["GET /config", "GET /t"]
--- response_body eval
['{"version": "abc"}
','{"version":"abc"}
']
--- no_error_log
[error]
