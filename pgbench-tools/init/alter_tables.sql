
alter table pgbench_branches add primary key (bid);
alter table pgbench_tellers add primary key (tid);
alter table pgbench_accounts add primary key (aid);

--alter table pgbench_tellers add foreign key (bid) references pgbench_branches;
--alter table pgbench_accounts add foreign key (bid) references pgbench_branches;
--alter table pgbench_history add foreign key (bid) references pgbench_branches;
--alter table pgbench_history add foreign key (tid) references pgbench_tellers;
--alter table pgbench_history add foreign key (aid) references pgbench_accounts;

