CREATE OR REPLACE FUNCTION pgbench_accounts_insert_trigger()
   RETURNS TRIGGER AS $$
   BEGIN
     IF NEW.aid >= '1' AND NEW.aid < '25000001' THEN
       INSERT INTO pgbench_accounts_f_1 VALUES (NEW.*);
     ELSIF NEW.aid >= '25000001' AND NEW.aid < '50000001' THEN
       INSERT INTO pgbench_accounts_f_2 VALUES (NEW.*);
     ELSIF NEW.aid >= '50000001' AND NEW.aid < '75000001' THEN
       INSERT INTO pgbench_accounts_f_3 VALUES (NEW.*);
     ELSIF NEW.aid >= '75000001' AND NEW.aid < '100000001' THEN
       INSERT INTO pgbench_accounts_f_4 VALUES (NEW.*);
     ELSIF NEW.aid >= '100000001' AND NEW.aid < '125000001' THEN
       INSERT INTO pgbench_accounts_f_5 VALUES (NEW.*);
     ELSIF NEW.aid >= '125000001' AND NEW.aid < '150000001' THEN
       INSERT INTO pgbench_accounts_f_6 VALUES (NEW.*);
     ELSIF NEW.aid >= '150000001' AND NEW.aid < '175000001' THEN
       INSERT INTO pgbench_accounts_f_7 VALUES (NEW.*);
     ELSIF NEW.aid >= '175000001' AND NEW.aid < '200000001' THEN
       INSERT INTO pgbench_accounts_f_8 VALUES (NEW.*);
     ELSE
       RAISE EXCEPTION 'Aid out of range';
     END IF;
     RETURN NULL;
   END;
   $$ LANGUAGE plpgsql;

