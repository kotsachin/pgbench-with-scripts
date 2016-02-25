CREATE OR REPLACE FUNCTION pgbench_accounts_insert_trigger()
   RETURNS TRIGGER AS $$
   BEGIN
     IF NEW.aid >= '1' AND NEW.aid < '2000001' THEN
       INSERT INTO pgbench_accounts_1 VALUES (NEW.*);
     ELSIF NEW.aid >= '2000001' AND NEW.aid < '4000001' THEN
       INSERT INTO pgbench_accounts_2 VALUES (NEW.*);
     ELSIF NEW.aid >= '4000001' AND NEW.aid < '6000001' THEN
       INSERT INTO pgbench_accounts_3 VALUES (NEW.*);
     ELSIF NEW.aid >= '6000001' AND NEW.aid < '8000001' THEN
       INSERT INTO pgbench_accounts_4 VALUES (NEW.*);
     ELSIF NEW.aid >= '8000001' AND NEW.aid < '10000001' THEN
       INSERT INTO pgbench_accounts_5 VALUES (NEW.*);
     ELSE
       RAISE EXCEPTION 'Aid out of range';
     END IF;
     RETURN NULL;
   END;
   $$ LANGUAGE plpgsql;
