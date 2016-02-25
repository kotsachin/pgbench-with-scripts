CREATE OR REPLACE FUNCTION pgbench_accounts_insert_trigger()
   RETURNS TRIGGER AS $$
   BEGIN
     IF NEW.aid >= '1' AND NEW.aid < '40000001' THEN
       INSERT INTO pgbench_accounts_f_1 VALUES (NEW.*);
     ELSIF NEW.aid >= '40000001' AND NEW.aid < '80000001' THEN
       INSERT INTO pgbench_accounts_f_2 VALUES (NEW.*);
     ELSIF NEW.aid >= '80000001' AND NEW.aid < '120000001' THEN
       INSERT INTO pgbench_accounts_f_3 VALUES (NEW.*);
     ELSIF NEW.aid >= '120000001' AND NEW.aid < '160000001' THEN
       INSERT INTO pgbench_accounts_f_4 VALUES (NEW.*);
     ELSIF NEW.aid >= '160000001' AND NEW.aid < '200000001' THEN
       INSERT INTO pgbench_accounts_f_5 VALUES (NEW.*);
     ELSE
       RAISE EXCEPTION 'Aid out of range';
     END IF;
     RETURN NULL;
   END;
   $$ LANGUAGE plpgsql;
