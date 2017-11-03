%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. 十一月 2017 9:49
%%%-------------------------------------------------------------------
-module(pg_store).
-author("simon").

%% API
-export([
  start/0
,stop/0

]).


-define(APP,pg_store).
%%------------------------------------------------
start() ->
  application:start(?APP).

stop() ->
  application:stop(?APP).

