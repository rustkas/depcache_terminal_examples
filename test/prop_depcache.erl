-module(prop_depcache).
-include_lib("proper/include/proper.hrl").
-behaviour(proper_statem).
%% Model Callbacks
-export([command/1, initial_state/0, next_state/3,
         precondition/2, postcondition/3]).


%%%%%%%%%%%%%%%%%%
%%% PROPERTIES %%%
%%%%%%%%%%%%%%%%%%
prop_test() ->
    ?FORALL(Cmds, parallel_commands(?MODULE),
            begin
                {ok, Server} = depcache:start_link([]),
				register(depcache, Server),
				{History, State, Result} = run_parallel_commands(?MODULE, Cmds),
                
				depcache:flush(Server),
				unregister(depcache),
				gen_server:stop(Server, normal, 1),
				unregister(depcache),
                ?WHENFAIL(io:format("History: ~p\nState: ~p\nResult: ~p\n",
                                    [History,State,Result]),
                          aggregate(command_names(Cmds), Result =:= ok))
            end).

%%%%%%%%%%%%%
%%% MODEL %%%
%%%%%%%%%%%%%
-define(CACHE_SIZE, 10).
-record(state, {max=?CACHE_SIZE, count=0, entries=[]}).

%% @doc Initial model value at system start. Should be deterministic.
initial_state() ->
    #{}.

%% @doc List of possible commands to run against the system
command(_State) ->
    frequency([
        {1, {call, depcache, get_wait, [key(), depcache]}},
        {3, {call, depcache, set, [key(), val(), depcache]}}

    ]).

%% @doc Determines whether a command should be valid under the
%% current state.
%% Picks whether a command should be valid under the current state.
precondition(_State, {call, _Mod, _Fun, _Args}) ->
    true.

%% @doc Given the state `State' *prior* to the call
%% `{call, Mod, Fun, Args}', determine whether the result
%% `Res' (coming from the actual system) makes sense.
postcondition(_State, {call, _Mod, _Fun, _Args}, _Res) ->
    true.

%% @doc Assuming the postcondition for a call was true, update the model
%% accordingly for the test to proceed.
%% Assuming the postcondition for a call was true, update the model
%% accordingly for the test to proceed.
%next_state(State, _, {call, depcache, flush, _}) ->
%    State#state{count=0, entries=[]};
%next_state(S=#state{entries=L, count=N, max=M}, _Res,
%           {call, depcache, set, [K, V, depcache]}) ->
%    case lists:keyfind(K, 1, L) of
%        false when N =:= M -> S#state{entries = tl(L) ++ [{K,V}]}; %(1)
%        false when N < M -> S#state{entries = L ++ [{K,V}], count=N+1}; %(2)
%        {K,_} -> S#state{entries = lists:keyreplace(K,1,L,{K,V})} %(3)
%    end;
next_state(State, _Res, {call, _Mod, _Fun, _Args}) ->
    State.

%%%%%%%%%%%%%%%%%%
%%% Generators %%%
%%%%%%%%%%%%%%%%%%
key() ->
    oneof([range(1,?CACHE_SIZE), % reusable keys, raising chance of dupes
           integer()]).          % random keys

val() ->
    integer().