%%%-------------------------------------------------------------------
%% @doc pg_store public API
%% @end
%%%-------------------------------------------------------------------

-module(pg_store_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-define(APP, pg_store).
%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
  %% start mnesia
  {ok, MnesiaDirCfg} = application:get_env(?APP, mnesia_dir),
  MnesiaDir = xfutils:get_path(?APP, MnesiaDirCfg),
  lager:error("Mnesia app dir = ~p", [MnesiaDir]),
  application:set_env(mnesia, dir, MnesiaDir),
  mnesia:stop(),
  ok = mnesia:start(),

  pg_store_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
  ok.

%%====================================================================
%% Internal functions
%%====================================================================
