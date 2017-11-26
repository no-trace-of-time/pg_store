%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. Dec 2016 8:17 PM
%%%-------------------------------------------------------------------
-module(repo_refund_result_pt).
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
-define(TBL, refund_result).


-type txn_type() :: pay |refund|gws_up_query.
-type status() :: success |waiting |fail.
-type txn_amt() :: non_neg_integer().

-export_type([txn_type/0, status/0, txn_amt/0]).


-record(?TBL, {
  mcht_index_key
  , orig_mcht_index_key
  , txn_status
  , refund_amt
  , resp_cd
  , resp_msg
  , settle_date
  , bank_card_no
  , pay_amt
  , pay_txn_time
%%  , up_txn_time
  , up_ref_id
  , up_trace_no

}).
-type ?TBL() :: #?TBL{}.
-export_type([?TBL/0]).

-export_records([?TBL]).
%%-------------------------------------------------------------
%% call backs
table_config() ->
  #{
    table_indexes => []
    , data_init => []
    , pk_is_sequence => false
    , pk_key_name => mcht_index_key
    , pk_type => tuple

    , unique_index_name => mcht_index_key
    , query_option =>
  #{
  }

  }.
