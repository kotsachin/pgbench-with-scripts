CREATE OR REPLACE FUNCTION pgbench_accounts_insert_trigger()
   RETURNS TRIGGER AS $$
   BEGIN
     IF NEW.aid >= '1' AND NEW.aid < '22222223' THEN
       INSERT INTO pgbench_accounts_f_1 VALUES (NEW.*);
     ELSIF NEW.aid >= '22222223' AND NEW.aid < '44444445' THEN
       INSERT INTO pgbench_accounts_f_2 VALUES (NEW.*);
     ELSIF NEW.aid >= '44444445' AND NEW.aid < '66666667' THEN
       INSERT INTO pgbench_accounts_f_3 VALUES (NEW.*);
     ELSIF NEW.aid >= '66666667' AND NEW.aid < '88888889' THEN
       INSERT INTO pgbench_accounts_f_4 VALUES (NEW.*);
     ELSIF NEW.aid >= '88888889' AND NEW.aid < '111111111' THEN
       INSERT INTO pgbench_accounts_f_5 VALUES (NEW.*);
     ELSIF NEW.aid >= '111111111' AND NEW.aid < '133333333' THEN
       INSERT INTO pgbench_accounts_f_6 VALUES (NEW.*);
     ELSIF NEW.aid >= '133333333' AND NEW.aid < '155555555' THEN
       INSERT INTO pgbench_accounts_f_7 VALUES (NEW.*);
     ELSIF NEW.aid >= '155555555' AND NEW.aid < '177777777' THEN
       INSERT INTO pgbench_accounts_f_8 VALUES (NEW.*);
     ELSIF NEW.aid >= '177777777' AND NEW.aid < '199999999' THEN
       INSERT INTO pgbench_accounts_f_9 VALUES (NEW.*);
     ELSE
       RAISE EXCEPTION 'Aid out of range';
     END IF;
     RETURN NULL;
   END;
   $$ LANGUAGE plpgsql;

