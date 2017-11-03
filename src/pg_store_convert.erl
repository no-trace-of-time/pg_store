%%%-------------------------------------------------------------------
%%% @author simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. 十一月 2017 10:44
%%%-------------------------------------------------------------------
-module(pg_store_convert).
-author("simon").

%% API
-export([
  convert_node_name/4
  , t/0
  , t_prod/0
]).


t() ->
  convert_node_name('zr_online_pg_sh@trust-test', 'nonode@nohost',
    <<"mnesia.backup">>, <<"mnesia.restore">>).
t_prod() ->
  convert_node_name('zr_online_pg@trust-prod', 'nonode@nohost',
    <<"mnesia.prod.backup">>, <<"mnesia.prod.restore">>).

restore(RestoreFileName) ->
  mnesia:install_fallback(RestoreFileName),
  mnesia:stop(),
  mnesia:start(),
  lager:error("please waiting for data restore...", []),
  mnesia:wait_for_tables([history_up_txn_log], infinity),
  ok.
%%------------------------------------------------------------------
convert_node_name(From, To, FromFile, ToFile)
  when is_atom(From), is_atom(To), is_binary(FromFile), is_binary(ToFile) ->

  BackupDir = pg_store:backup_dir(),
  FullFromFile = binary_to_list(<<BackupDir/binary, FromFile/binary>>),
  FullToFile = binary_to_list(<<BackupDir/binary, ToFile/binary>>),
  lager:error("FromFile = ~ts,ToFile = ~ts", [FullFromFile, FullToFile]),
  do_convert_node_name(mnesia_backup, From, To, FullFromFile, FullToFile),

  restore(FullToFile),
  ok.

do_convert_node_name(Mod, From, To, Source, Target) ->
  Convert = convert_fun(From, To),
  mnesia:traverse_backup(Source, Mod, Target, Mod, Convert, switched).

convert_fun(From, To) ->
  fun
    ({schema, db_nodes, Nodes}, Acc) ->
      L = [maybe_convert(X, {From, To}) || X <- Nodes],%:>
      {[{schema, db_nodes, L}], Acc};
    ({schema, Tab, CreateList}, Acc) ->
      L = [maybe_key(KeyVal, {From, To}) || KeyVal <- CreateList], %:>
      {[{schema, Tab, L}], Acc};
    (Other, Acc) -> {[Other], Acc}
  end.

maybe_convert(N, {N, To}) -> To;
maybe_convert(N, {_From, N}) -> throw({error, already_exists});
maybe_convert(N, {_, _}) -> N.

maybe_key({Key, Vals}, B) ->
  Keys = [ram_copies, disc_copies, disc_only_copies],
  Member = lists:member(Key, Keys),
  maybe_key({Key, Vals}, B, Member).

maybe_key({Key, Vals}, B, true) ->
  L = [maybe_convert(X, B) || X <- Vals], %:>
  {Key, L};
maybe_key(A, _, false) -> A.


