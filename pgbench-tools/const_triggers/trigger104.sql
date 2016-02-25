CREATE OR REPLACE FUNCTION pgbench_accounts_insert_trigger()
   RETURNS TRIGGER AS $$
   BEGIN
     IF NEW.aid >= '1' AND NEW.aid < '16000001' THEN
       INSERT INTO pgbench_accounts_f_1 VALUES (NEW.*);
     ELSIF NEW.aid >= '16000001' AND NEW.aid < '32000001' THEN
       INSERT INTO pgbench_accounts_f_2 VALUES (NEW.*);
     ELSIF NEW.aid >= '32000001' AND NEW.aid < '48000001' THEN
       INSERT INTO pgbench_accounts_f_3 VALUES (NEW.*);
     ELSIF NEW.aid >= '48000001' AND NEW.aid < '64000001' THEN
       INSERT INTO pgbench_accounts_f_4 VALUES (NEW.*);
     ELSIF NEW.aid >= '64000001' AND NEW.aid < '80000001' THEN
       INSERT INTO pgbench_accounts_f_5 VALUES (NEW.*);
     ELSIF NEW.aid >= '80000001' AND NEW.aid < '96000001' THEN
       INSERT INTO pgbench_accounts_f_6 VALUES (NEW.*);
     ELSIF NEW.aid >= '96000001' AND NEW.aid < '112000001' THEN
       INSERT INTO pgbench_accounts_f_7 VALUES (NEW.*);
     ELSIF NEW.aid >= '112000001' AND NEW.aid < '128000001' THEN
       INSERT INTO pgbench_accounts_f_8 VALUES (NEW.*);
     ELSIF NEW.aid >= '128000001' AND NEW.aid < '144000001' THEN
       INSERT INTO pgbench_accounts_f_9 VALUES (NEW.*);
     ELSIF NEW.aid >= '144000001' AND NEW.aid < '160000001' THEN
       INSERT INTO pgbench_accounts_f_10 VALUES (NEW.*);
     ELSE
       RAISE EXCEPTION 'Aid out of range';
     END IF;
     RETURN NULL;
   END;
   $$ LANGUAGE plpgsql;
