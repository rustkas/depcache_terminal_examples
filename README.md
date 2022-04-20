# depcache examples
Manual tests of [depcache](https://github.com/zotonic/depcache) API

Build
-----

    $ rebar3 get-deps && rebar3 compile && rebar3 shell
 

```
%% Examples were created based on tests
%% https://github.com/zotonic/depcache/blob/master/test/depcache_tests.erl
```
## Examples (Erlang CLI):
    
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
> f().
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
> f().
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
> f().
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
> f().
```

```
% get_set_depend_test() ->
%% Set a key  and Get items.
> {ok, Server} = depcache:start_link([]).
> ok = depcache:set(test_key, [{test_key_dep, 555}], 3600, [test_key_dep], Server).
> {ok,[{test_key_dep,555}]} = depcache:get(test_key, Server).
> {ok,555} = depcache:get(test_key, test_key_dep, Server).
> {ok,555} = depcache:get_subkey(test_key, test_key_dep, Server).
> undefined = depcache:get(test_key_dep, Server).
> depcache:flush(Server).
% stop depcache
> gen_server:stop(Server, normal, 1).
> f().
```

```
% get_set_depend_test() ->
%% Set a key  and Get items.
> {ok, Server} = depcache:start_link([]).
> undefined = depcache:get(a, b, Server).
> ok = depcache:set(a, #{ b => 1 }, Server).
> {ok,1} = depcache:get(a, b, Server).
> {ok,1} = depcache:get_subkey(a, b, Server).
> depcache:flush(Server).
% stop depcache
> gen_server:stop(Server, normal, 1).
> f().
```

```
% get_set_depend_test() ->
%% Set a key  and Get items.
> {ok, Server} = depcache:start_link([]).
> ok = depcache:set(a, [{b, 1}], Server).
> {ok,1} = depcache:get(a, b, Server).
> {ok,1} = depcache:get_subkey(a, b, Server).
> ok = depcache:flush(Server).
% stop depcache
> ok = gen_server:stop(Server, normal, 1).
> f().
```

```
% in_process_server/1
> {ok, Server} = depcache:start_link([]).
> false = depcache:in_process_server(Server).
> undefined = depcache:in_process(true).
> true = depcache:in_process_server(Server).
> ok = depcache:set(a, [{b, 1}], Server).
> {ok,1} = depcache:get_subkey(a, b, Server).
ok = depcache:set(test_key, [{test_key_dep, 555}], 3600, [test_key_dep], Server).
depcache:in_process(false).
{ok,555} = depcache:get(test_key, test_key_dep, Server).
{ok,555} = depcache:get_subkey(test_key, test_key_dep, Server).
depcache:set(test_key2, [{test_key_dep2, 556}], 3600, [test_key_dep2], Server).
{ok,556} = depcache:get(test_key2, test_key_dep2, Server).
depcache:in_process(true).
ok = depcache:set(test_key3, [{test_key_dep3, 557}], 3600, [test_key_dep3], Server).
depcache:set(test_key, [{test_key_dep, 55}], 3600, [test_key_dep], Server).
depcache:set(test_key, [{test_key_dep, 5}], 3600, [test_key_dep], Server).
depcache:in_process(false).
depcache:get(test_key).
true = depcache:in_process_server(Server).
depcache:in_process(false).
exit(Server, ok).
is_process_alive(Server).
f().
```

```
% memo test
> {ok, Server} = depcache:start_link([]).
> IncreaseFun = fun(X) ->
    I = case erlang:get(X) of
            undefined -> 1;
            Num -> Num + 1
        end,
    erlang:put(X, I),
    I end.
>  IncreaserFunX = fun() ->
                           IncreaseFun(ok)
                   end.
> 1 = depcache:memo(IncreaserFunX, test_key, Server).
> 1 = depcache:memo(IncreaserFunX, test_key, Server).
> ok = depcache:flush(test_key, Server).
> 2 = depcache:memo(IncreaserFunX, test_key, Server).
> ok = depcache:flush(Server).
% stop depcache
> ok = gen_server:stop(Server, normal, 1).
> f().
```

```
> {ok, Server} = depcache:start_link([]).
> rd(memo, {value, max_age, deps=[]}).
> IncreaseFun = fun(X) ->
    I = case erlang:get(X) of
            undefined -> 1;
            Num -> Num + 1
        end,
    erlang:put(X, I),
    I end.
> Fun = fun() -> V = IncreaseFun(y), #memo{value=V, deps=[dep]} end.
> Fun = fun() -> {dep, V = IncreaseFun(ok)}, #memo{value=V, deps=[dep]} end.
> depcache:memo(Fun, test_key, Server).
> {ok, 1} = depcache:get(test_key1, Server).
> depcache:get(test_key1, dep, Server).
```

```
$ ​rebar3​ as test ​new​ ​proper_statem​ ​depcache
​$ rebar3 proper -p prop_test
```

