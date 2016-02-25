
create table pgbench_history(tid int,bid int,aid bigint,delta int,mtime timestamp,filler char(22));

create table pgbench_tellers(tid int not null,bid int,tbalance int,filler char(84));

create table pgbench_accounts(aid bigint not null,bid int,abalance int,filler char(84));

create table pgbench_branches(bid int not null,bbalance int,filler char(88));

