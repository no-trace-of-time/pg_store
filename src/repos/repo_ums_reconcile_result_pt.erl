%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Dec 2016 8:17 PM
%%%-------------------------------------------------------------------
-module(repo_ums_reconcile_result_pt).
-compile({parse_trans, exprecs}).
-behavior(pg_repo).
-author("simon").
-include_lib("mixer/include/mixer.hrl").

-mixin([
  {pg_store, [pr_formatter/1]}
]).

%% API
%% callbacks
-export([
  table_config/0
]).

-compile(export_all).
%%-------------------------------------------------------------
-define(TBL, ums_reconcile_result).

-record(?TBL, {
  id
  , settlement_date
  , txn_date
  , txn_time
  , ums_mcht_id
  , term_id
  , bank_card_no
  , txn_amt
  , txn_type
  , txn_fee
  , term_batch_no
  , term_seq
  , sys_trace_no
  , ref_id
  , auth_resp_code
  , cooperate_fee
  , cooperate_mcht_id
  , up_txn_seq
  , ums_order_id
  , memo

}).
-type ?TBL() :: #?TBL{}.
-export_type([?TBL/0]).

-export_records([?TBL]).
%%-------------------------------------------------------------
%% call backs
table_config() ->
  #{
    table_indexes => [txn_date, ref_id]
    , data_init => []
    , pk_is_sequence => false
    , pk_key_name => id
    , pk_type => tuple

    , unique_index_name => undefined
    , query_option =>
  #{
    mcht_id => integer_equal
  }

  }.

