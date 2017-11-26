%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Dec 2016 8:17 PM
%%%-------------------------------------------------------------------
-module(repo_backend_users_pt).
-compile({parse_trans, exprecs}).
-behavior(pg_repo).
-author("simon").
-include_lib("mixer/include/mixer.hrl").

%% API
%% callbacks
-export([
  %% table define related
  table_config/0
]).

-mixin([
  {pg_store, [pr_formatter/1]}
]).
%%-------------------------------------------------------------
-define(TBL, users).

-type ts() :: erlang:timestamp().

-type id() :: non_neg_integer().
-type name() :: binary().
-type email() :: binary().
-type password() :: binary().
-type role() :: op | admin.
-type status() :: normal | hold |forbidden.
-type token() :: binary().


-export_type([id/0, name/0, email/0, password/0, role/0, status/0, token/0]).

-record(?TBL, {
  id :: id(),
  name :: name(),
  email :: email(),
  password :: password(),
  role :: role(),
  status :: status(),
  last_update_ts = erlang:timestamp() :: ts(),
  last_login_ts :: ts()
}).
-type ?TBL() :: #?TBL{}.
-export_type([?TBL/0]).

-export_records([users]).
%%-------------------------------------------------------------
%% call backs
-define(DEFAULT_PWD, <<"Trust123$">>).

table_config() ->
  #{
    table_indexes => [name]
    , data_init => [
    {{name, <<"admin">>}, [{password, ?DEFAULT_PWD}]}
    , {{name, <<"op">>}, [{password, ?DEFAULT_PWD}]}
  ]

    , pk_is_sequence => true
    , pk_key_name => id
    , pk_type =>integer

    , unique_index_name => name

    , query_option =>
  #{
    id => integer_equal
  }

  }.

