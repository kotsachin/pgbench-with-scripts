CREATE OR REPLACE FUNCTION pgbench_accounts_insert_trigger()
   RETURNS TRIGGER AS $$
   BEGIN
     IF NEW.aid >= '1' AND NEW.aid < '20001' THEN
       INSERT INTO pgbench_accounts_1 VALUES (NEW.*);
     ELSIF NEW.aid >= '20001' AND NEW.aid < '40001' THEN
       INSERT INTO pgbench_accounts_2 VALUES (NEW.*);
     ELSIF NEW.aid >= '40001' AND NEW.aid < '60001' THEN
       INSERT INTO pgbench_accounts_3 VALUES (NEW.*);
     ELSIF NEW.aid >= '60001' AND NEW.aid < '80001' THEN
       INSERT INTO pgbench_accounts_4 VALUES (NEW.*);
     ELSIF NEW.aid >= '80001' AND NEW.aid < '100001' THEN
       INSERT INTO pgbench_accounts_5 VALUES (NEW.*);
     ELSE
       RAISE EXCEPTION 'Aid out of range';
     END IF;
     RETURN NULL;
   END;
   $$ LANGUAGE plpgsql;
