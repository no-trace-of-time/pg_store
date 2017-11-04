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
  , stop/0
  , load_mnesia_csv/0
  , load_mnesia_csv/1
  , load_one_table_csv/2
  , mnesia_startup/0
  , backup_dir/0

]).

%% db init related api
-export([
  init_table/0
]).

%% pr_formatter
-export([
  pr_formatter/1
]).

-define(APP, pg_store).
%%------------------------------------------------
start() ->
  application:start(?APP).

stop() ->
  application:stop(?APP).

backup_dir() ->
  list_to_binary(xfutils:get_path(?APP, [home, db_backup_dir])).
%%------------------------------------------------
load_mnesia_csv() ->
  load_mnesia_csv(datetime_x_fin:today()).

load_mnesia_csv(YYYYMMDD) when is_binary(YYYYMMDD), 8 =:= byte_size(YYYYMMDD) ->
  TableList = [repo_mchants_pt
    , repo_mcht_txn_log_pt
    , repo_up_txn_log_pt
    , repo_mcht_txn_acc_pt
    , repo_ums_reconcile_result_pt
    , repo_backend_users_pt
    , repo_history_mcht_txn_log_pt
    , repo_history_up_txn_log_pt
    , repo_history_ums_reconcile_result_pt
  ],
  [load_one_table_csv(Table, YYYYMMDD) || Table <- TableList].

%%------------------------------------------------
load_one_table_csv(Table, Date) when is_atom(Table), is_binary(Date) ->
  BackupDir = backup_dir(),
  TableRaw = atom_to_binary(Table, utf8),
  Delimiter = <<".">>,
  TableFileName = <<BackupDir/binary, "mnesia.backup.csv.", TableRaw/binary, Delimiter/binary, Date/binary>>,
  csv_table_deal:restore(Table, TableFileName),
  lager:info("Restore mnesia table ~p to file ~p ok.", [Table, TableFileName]),
  ok.
%%------------------------------------------------
mnesia_startup() ->
  {ok, MnesiaDirCfg} = application:get_env(?APP, mnesia_dir),
  MnesiaDir = xfutils:get_path(?APP, MnesiaDirCfg),
  lager:error("Mnesia app dir = ~p", [MnesiaDir]),
  application:set_env(mnesia, dir, MnesiaDir),
  mnesia:stop(),
  mnesia:start().

%%------------------------------------------------
init_table() ->
  mnesia:stop(),
  mnesia:delete_schema([node()]),
  mnesia:create_schema([node()]),
  ok = mnesia:start(),
  db_init().

%% Internal Functions

db_init() ->
  Tbls = [
    repo_backend_users_pt
    , repo_history_mcht_txn_log_pt
    , repo_history_ums_reconcile_result_pt
    , repo_history_up_txn_log_pt
    , repo_mchants_pt
    , repo_mcht_txn_acc_pt
    , repo_mcht_txn_log_pt
    , repo_refund_result_pt
    , repo_ums_reconcile_result_pt
    , repo_up_txn_log_pt

  ],
  [pg_repo:init(Tbl) || Tbl <- Tbls].

%%------------------------------------------------
pr_formatter(Field)
  when (Field =:= order_desc)
  or (Field =:= reqReserved)
  or (Field =:= reserved)
  ->
  string;
pr_formatter(_) ->
  ok.


