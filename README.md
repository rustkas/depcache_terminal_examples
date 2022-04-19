# depcache examples
Manual tests of [depcache](https://github.com/zotonic/depcache) API

Build
-----

    $ rebar3 get-deps && rebar3 compile && rebar3 shell
 

```
%% Examples were created based on tests
%% https://github.com/zotonic/depcache/blob/master/test/depcache_tests.erl
```
## Examples:
    
```
> % get_set_test() ->
> {ok, Server} = depcache:start_link([]).
> undefined = depcache:get(test_key, Server).
> ok = depcache:set(test_key, 123, Server).
> {ok, 123} = depcache:get(test_key, Server).
> ok = depcache:flush(test_key, Server).
> undefined = depcache:get(test_key, Server).
% stop depcache
> gen_server:stop(Server, normal, 1).
```

```
% flush_all_test() ->
> {ok, Server} = depcache:start_link([]).
> ok = depcache:set(test_key1, 123, Server).
> ok = depcache:set(test_key2, 123, Server).
> ok = depcache:set(test_key3, 123, Server).
> {ok, 123} = depcache:get(test_key1, Server).
> {ok, 123} = depcache:get(test_key2, Server).
> {ok, 123} = depcache:get(test_key3, Server).
> ok = depcache:flush(Server).
> undefined = depcache:get(test_key1, Server).
> undefined = depcache:get(test_key2, Server).
> undefined = depcache:get(test_key3, Server).
% stop depcache
> gen_server:stop(Server, normal, 1).
```

```
% get_set_maxage_test() ->
> {ok, Server} = depcache:start_link([]).
> undefined = depcache:get(xtest_key, Server).
%% Set a key and hold it for one second.
> ok = depcache:set(xtest_key, 123, 1, Server). {ok, 123} = depcache:get(xtest_key, Server).
> {ok, 123} = depcache:get(xtest_key, Server).
%% Let the depcache time out.
> timer:sleep(4000).
> undefined = depcache:get(xtest_key, Server).
> depcache:flush(Server).
% stop depcache
> gen_server:stop(Server, normal, 1).
```

```
% get_set_maxage0_test() ->
%% Set a key and hold it for 0 seconds
> {ok, Server} = depcache:start_link([]).
> ok = depcache:set(test_key, 123, 0, Server).
> undefined = depcache:get(test_key, Server).
> depcache:flush(Server).
% stop depcache
> gen_server:stop(Server, normal, 1).

```
