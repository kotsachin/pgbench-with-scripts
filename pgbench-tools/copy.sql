
COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=1 AND aid<12000001) TO '/home/sachin/fix_scale_fdw/child61.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=12000001 AND aid<24000001) TO '/home/sachin/fix_scale_fdw/child62.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=24000001 AND aid<36000001) TO '/home/sachin/fix_scale_fdw/child63.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=36000001 AND aid<48000001) TO '/home/sachin/fix_scale_fdw/child64.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=48000001 AND aid<60000001) TO '/home/sachin/fix_scale_fdw/child65.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=60000001 AND aid<72000001) TO '/home/sachin/fix_scale_fdw/child66.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=72000001 AND aid<84000001) TO '/home/sachin/fix_scale_fdw/child67.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=84000001 AND aid<96000001) TO '/home/sachin/fix_scale_fdw/child68.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=96000001 AND aid<108000001) TO '/home/sachin/fix_scale_fdw/child69.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=108000001 AND aid<120000001) TO '/home/sachin/fix_scale_fdw/child610.csv' WITH DELIMITER ',' CSV HEADER;


COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=1 AND aid<14000001) TO '/home/sachin/fix_scale_fdw/child71.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=14000001 AND aid<28000001) TO '/home/sachin/fix_scale_fdw/child72.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=28000001 AND aid<42000001) TO '/home/sachin/fix_scale_fdw/child73.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=42000001 AND aid<56000001) TO '/home/sachin/fix_scale_fdw/child74.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=56000001 AND aid<70000001) TO '/home/sachin/fix_scale_fdw/child75.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=70000001 AND aid<84000001) TO '/home/sachin/fix_scale_fdw/child76.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=84000001 AND aid<98000001) TO '/home/sachin/fix_scale_fdw/child77.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=98000001 AND aid<112000001) TO '/home/sachin/fix_scale_fdw/child78.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=112000001 AND aid<126000001) TO '/home/sachin/fix_scale_fdw/child79.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=126000001 AND aid<140000001) TO '/home/sachin/fix_scale_fdw/child710.csv' WITH DELIMITER ',' CSV HEADER;



COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=1 AND aid<16000001) TO '/home/sachin/fix_scale_fdw/child81.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=16000001 AND aid<32000001) TO '/home/sachin/fix_scale_fdw/child82.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=32000001 AND aid<48000001) TO '/home/sachin/fix_scale_fdw/child83.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=48000001 AND aid<64000001) TO '/home/sachin/fix_scale_fdw/child84.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=64000001 AND aid<80000001) TO '/home/sachin/fix_scale_fdw/child85.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=80000001 AND aid<96000001) TO '/home/sachin/fix_scale_fdw/child86.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=96000001 AND aid<112000001) TO '/home/sachin/fix_scale_fdw/child87.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=112000001 AND aid<128000001) TO '/home/sachin/fix_scale_fdw/child88.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=128000001 AND aid<144000001) TO '/home/sachin/fix_scale_fdw/child89.csv' WITH DELIMITER ',' CSV HEADER;

COPY (SELECT aid, bid, abalance, filler from pgbench_accounts WHERE aid >=144000001 AND aid<160000001) TO '/home/sachin/fix_scale_fdw/child810.csv' WITH DELIMITER ',' CSV HEADER;

