Name
====

lua-resty-consul - load config from consul for the ngx_lua

Table of Contents
=================

* [Name](#name)
* [Status](#status)
* [Description](#description)
* [Synopsis](#synopsis)
* [Methods](#methods)
    * [config.init](#configinit)
    * [load:new](#loadnew)
    * [load:lkeys](#loadlkeys)
    * [load:lget](#loadlget)
    * [load:lversion](#loadlversion)
    * [api.get_kv](#apiget_kv)
    * [api.get_kv_blocking](#apiget_kv_blocking)
* [Author](#author)
* [Copyright and License](#copyright-and-license)

Status
======

This library is already usable though still experimental.

The Lua API is still in flux and may change in the near future.

Description
===========

This Lua library to help OpenResty/ngx_lua users to load config from consul

* `resty.consul.api` currently provides consul key/value store `GET api`
* `resty.consul.config` provides dynamic config for ngx_lua and upstream config for [lua-resty-checkups](http://gitlab.widget-inc.com/openresty/lua-resty-checkups)
* `resty.consul.load` provides load_init script/module for [lua-resty-load](http://gitlab.widget-inc.com/lib.huang/lua-resty-load)

Synopsis
========

```lua
    http {
        lua_package_path "/path/to/lua-resty-consul/lib/?.lua;/path/to/lua-resty-checkups/lib/?.lua;/path/to/lua-resty-load/lib/?.lua;;";
        
        init_by_lua '
            local rload  = require "resty.load"
            local config = require "config"
            consul.init(config)
            rload.init(config)
        ';
        
        init_worker_by_lua '
            local checkups = require "resty.checkups.api"
            local config = require "config"
    		checkups.prepare_checker(config)
    		checkups.create_checker()
    		local rload  = require "resty.load"
            rload.create_load_syncer()
        ';
    }
    
    server {
        location = /t {
        	content_by_lua '
        		-- script
        	    local abc = require "module.abc"
        	    ngx.say(abc.version)
        	    -- upstream config
        	    local cjson = require "cjson.safe"
            	ngx.say(cjson.encode(config.test))
        	';
    	}
    	location = /config_script {
        	content_by_lua '
        	    local config = require "config"
        	    local api = require "resty.consul.api"
        	    ngx.say(api.get_kv_blocking(config.consul.cluster, config.consul.config_key_prefix .. "lua/module.abc?raw"))
        	';
    	}
    	location = /config_upstream {
        	content_by_lua '
        	    local config = require "config"
        	    local api = require "resty.consul.api"
        	    ngx.say(api.get_kv_blocking(config.consul.cluster, config.consul.config_key_prefix .. "upstreams/test?raw"))
        	';
    	}
    }
```

[Back to TOC](#table-of-contents)

Methods
=======

[Back to TOC](#table-of-contents)

config.init
-------
`syntax: ok, err = consul.config.init(config)`

`context: init_by_lua*`

Initialize the library. In case of failures, returns `nil` and a string describing the error.

An Lua table `config` can be specified as the only argument to this method to specify load_init consul config:

* `config_key_prefix` key prefix for consul key/value store endpoints  

* `config_positive_ttl` ttl for cache good data

* `config_negative_ttl` ttl for cache failed lookup

* `config_cache_enable` A boolean indicating whether enable [lua-resty-shcache](https://github.com/cloudflare/lua-resty-shcache) to cache config

* `cluster` [Cluster configurations](http://gitlab.widget-inc.com/openresty/lua-resty-checkups#cluster-configurations)


[Back to TOC](#table-of-contents)

    
load:new
---
`syntax: load_object, err = consul.load:new(config)`

Creates a load object. In case of failures, returns nil and a string describing the error.

* `config`

    Just the parameter in `consul.config.init`

load:lkeys
---
`syntax: keys, err = load_object:lkeys()`

Retrieving a lua array that include all the script/module names from consul k/v store. In case of failures, returns nil and a string describing the error.

load:lget
---
`syntax: code, err = load_object:lget(key)`

Retrieving the code from consul k/v store for the script/module name `key`. In case of failures, returns nil and a string describing the error.

load:lversion
---
`syntax: version, err = load_object:lversion()`

Retrieving the version from consul k/v store for current codes. This is optional for fallback and version checking. `version` no longer than 32 characters.

In case of failures, returns nil and a string describing the error.

[Back to TOC](#table-of-contents)

api.get_kv
-------
`syntax: value, err = api.get_kv(cluster, key, options_table?)`

Retrieving the value from consul k/v store for the key `key` without blocking.

An optional Lua table can be specified as the last argument to this method:

* `default`

	If the key does not exist, this option will be returned.
    
* `decode`
    
    If this option is set , then the value will be decoded before returning.

[Back to TOC](#table-of-contents)

api.get_kv_blocking
-------
`syntax: value = api.get_kv_blocking(key, options_table?)`

Similar to the `api.get_kv` method, but blocking on the current connection.

[Back to TOC](#table-of-contents)



Author
======

UPYUN Inc.

[Back to TOC](#table-of-contents)

Copyright and License
=====================

This module is licensed under the BSD license.

Copyright (C) 2016, by UPYUN Inc.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[Back to TOC](#table-of-contents)
