CREATE OR REPLACE FUNCTION pgbench_accounts_insert_trigger()
   RETURNS TRIGGER AS $$
   BEGIN
     IF NEW.aid >= '1' AND NEW.aid < '33333334' THEN
       INSERT INTO pgbench_accounts_f_1 VALUES (NEW.*);
     ELSIF NEW.aid >= '33333334' AND NEW.aid < '66666667' THEN
       INSERT INTO pgbench_accounts_f_2 VALUES (NEW.*);
     ELSIF NEW.aid >= '66666667' AND NEW.aid < '100000000' THEN
       INSERT INTO pgbench_accounts_f_3 VALUES (NEW.*);
     ELSIF NEW.aid >= '100000000' AND NEW.aid < '133333333' THEN
       INSERT INTO pgbench_accounts_f_4 VALUES (NEW.*);
     ELSIF NEW.aid >= '133333333' AND NEW.aid < '166666666' THEN
       INSERT INTO pgbench_accounts_f_5 VALUES (NEW.*);
     ELSIF NEW.aid >= '166666666' AND NEW.aid < '199999999' THEN
       INSERT INTO pgbench_accounts_f_6 VALUES (NEW.*);
     ELSE
       RAISE EXCEPTION 'Aid out of range';
     END IF;
     RETURN NULL;
   END;
   $$ LANGUAGE plpgsql;

