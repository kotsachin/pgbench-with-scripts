CREATE OR REPLACE FUNCTION pgbench_accounts_insert_trigger()
   RETURNS TRIGGER AS $$
   BEGIN
--     IF NEW.aid >= '1' AND NEW.aid < '10000001' THEN
--       INSERT INTO pgbench_accounts_f_1 VALUES (NEW.*);
--     ELSIF NEW.aid >= '10000001' AND NEW.aid < '20000001' THEN
--       INSERT INTO pgbench_accounts_f_2 VALUES (NEW.*);
--     ELSIF NEW.aid >= '20000001' AND NEW.aid < '30000001' THEN
--       INSERT INTO pgbench_accounts_f_3 VALUES (NEW.*);
--     ELSIF NEW.aid >= '30000001' AND NEW.aid < '40000001' THEN
--       INSERT INTO pgbench_accounts_f_4 VALUES (NEW.*);
--     ELSIF NEW.aid >= '40000001' AND NEW.aid < '50000001' THEN
--       INSERT INTO pgbench_accounts_f_5 VALUES (NEW.*);
--     IF NEW.aid >= '50000001' AND NEW.aid < '60000001' THEN
--       INSERT INTO pgbench_accounts_f_6 VALUES (NEW.*);
--     ELSIF NEW.aid >= '60000001' AND NEW.aid < '70000001' THEN
--       INSERT INTO pgbench_accounts_f_7 VALUES (NEW.*);
--     ELSIF NEW.aid >= '70000001' AND NEW.aid < '80000001' THEN
--       INSERT INTO pgbench_accounts_f_8 VALUES (NEW.*);
     IF NEW.aid >= '80000001' AND NEW.aid < '90000001' THEN
       INSERT INTO pgbench_accounts_f_9 VALUES (NEW.*);
     ELSIF NEW.aid >= '90000001' AND NEW.aid < '100000001' THEN
       INSERT INTO pgbench_accounts_f_10 VALUES (NEW.*);
     ELSIF NEW.aid >= '100000001' AND NEW.aid < '110000001' THEN
       INSERT INTO pgbench_accounts_f_10 VALUES (NEW.*);
     ELSE
       RAISE EXCEPTION 'Aid out of range';
     END IF;
     RETURN NULL;
   END;
   $$ LANGUAGE plpgsql;
