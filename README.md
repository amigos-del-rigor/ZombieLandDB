ZombieLandDB
===
More than a DB, more than a caché...

Usage
===

Quick start
---
Start ZombieLandDB:

    make
    erl -pa ebin deps/*/ebin -boot zldb    

Set some example data:

    {ok, Pid1} = zldb_manager:get_pid_from_id("abc").
    {ok, Pid2} = zldb_manager:get_pid_from_id("123").

    zldb_entity:get(Pid1, id).
    zldb_entity:get(Pid2, id).
    zldb_entity:get(Pid1, data).
    zldb_entity:get(Pid2, data).


Test
===
    ERL_AFLAGS="-boot zldb" deps/etest/bin/etest-runner

On Symfony2ErlangBundle Demo, Start ZombieLandDB as:
====================================================

    erl -pa ebin deps/*/ebin -boot zldb -sname node0 -setcookie abc +P 2000000

TODO
===
- Persistent layer. Now is too fool.
- Alternative process register: gproc (https://github.com/uwiger/gproc)

