CREATE OR REPLACE FUNCTION pgbench_accounts_insert_trigger()
   RETURNS TRIGGER AS $$
   BEGIN
     IF NEW.aid >= '1' AND NEW.aid < '10000001' THEN
       INSERT INTO pgbench_accounts_f_1 VALUES (NEW.*);
     ELSIF NEW.aid >= '10000001' AND NEW.aid < '20000001' THEN
       INSERT INTO pgbench_accounts_f_2 VALUES (NEW.*);
     ELSE
       RAISE EXCEPTION 'Aid out of range';
     END IF;
     RETURN NULL;
   END;
   $$ LANGUAGE plpgsql;
