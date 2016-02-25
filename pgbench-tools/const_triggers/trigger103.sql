CREATE OR REPLACE FUNCTION pgbench_accounts_insert_trigger()
   RETURNS TRIGGER AS $$
   BEGIN
     IF NEW.aid >= '1' AND NEW.aid < '14000001' THEN
       INSERT INTO pgbench_accounts_f_1 VALUES (NEW.*);
     ELSIF NEW.aid >= '14000001' AND NEW.aid < '28000001' THEN
       INSERT INTO pgbench_accounts_f_2 VALUES (NEW.*);
     ELSIF NEW.aid >= '28000001' AND NEW.aid < '42000001' THEN
       INSERT INTO pgbench_accounts_f_3 VALUES (NEW.*);
     ELSIF NEW.aid >= '42000001' AND NEW.aid < '56000001' THEN
       INSERT INTO pgbench_accounts_f_4 VALUES (NEW.*);
     ELSIF NEW.aid >= '56000001' AND NEW.aid < '70000001' THEN
       INSERT INTO pgbench_accounts_f_5 VALUES (NEW.*);
     ELSIF NEW.aid >= '70000001' AND NEW.aid < '84000001' THEN
       INSERT INTO pgbench_accounts_f_6 VALUES (NEW.*);
     ELSIF NEW.aid >= '84000001' AND NEW.aid < '98000001' THEN
       INSERT INTO pgbench_accounts_f_7 VALUES (NEW.*);
     ELSIF NEW.aid >= '98000001' AND NEW.aid < '112000001' THEN
       INSERT INTO pgbench_accounts_f_8 VALUES (NEW.*);
     ELSIF NEW.aid >= '112000001' AND NEW.aid < '126000001' THEN
       INSERT INTO pgbench_accounts_f_9 VALUES (NEW.*);
     ELSIF NEW.aid >= '126000001' AND NEW.aid < '140000001' THEN
       INSERT INTO pgbench_accounts_f_10 VALUES (NEW.*);
     ELSE
       RAISE EXCEPTION 'Aid out of range';
     END IF;
     RETURN NULL;
   END;
   $$ LANGUAGE plpgsql;
