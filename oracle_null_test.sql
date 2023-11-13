--
-- Section 1: basics
-- { 
--= 1
select count(*) from dual where '' is null;
--= 0
select count(*) from dual where empty_clob() is null;
--= 1
select count(*) from dual where empty_clob() is not null;
--= 0
select count(*) from dual where empty_blob() is null;
--= 1
select count(*) from dual where empty_blob() is not null;
--= 0
select dbms_lob.getlength(empty_clob()) from dual;
--= 0
select dbms_lob.getlength(empty_blob()) from dual;
--= 1
select count(*) from dual where dbms_lob.compare(empty_clob(), empty_clob()) = 0;
--= 1, dbms_lob.substr return varchar2 !!!
SELECT count(*) FROM dual WHERE dbms_lob.substr(EMPTY_CLOB(), 1, 1) IS NULL;
-- }

--
-- Section 2: functions take empty string as an input argument
-- {
--= 1
SELECT count(*) FROM dual WHERE REGEXP_REPLACE('x123', '\d', '') IS NOT NULL; 
--= 1
SELECT count(*) FROM dual WHERE REPLACE('xx', 'x', '') IS NULL;
--= 1
SELECT count(*) FROM dual WHERE RPAD('', 1, '*') IS NULL;
--= 1
SELECT count(*) FROM dual WHERE UPPER('') IS NULL;
--= 1
SELECT count(*) FROM DUAL WHERE INSTR('x','', 0, 1) IS NULL;
--= 1
SELECT count(*) FROM dual WHERE CONCAT('', '') IS NULL;
--= 1
SELECT count(*) FROM dual WHERE LPAD('', 10, '*') IS NULL;
-- }

--
-- Section 3: functions return empty string as an output
-- {
--= 1
SELECT count(*) FROM dual WHERE LTRIM('x', 'x') IS NULL;
--= 1
SELECT count(*) FROM dual WHERE REGEXP_REPLACE('123', '\d', '') IS NULL;
--= 1
SELECT count(*) FROM dual WHERE REGEXP_SUBSTR('x', '\d') IS NULL;
--= 1
SELECT count(*) FROM dual WHERE REPLACE('xx', 'x', '') IS NULL;
--= 1
SELECT count(*) FROM dual WHERE RTRIM('x', 'x') IS NULL;
--= 1
SELECT count(*) FROM dual WHERE SUBSTR('x', 0, 0) IS NULL;
--= 1
SELECT count(*) FROM dual WHERE TRIM('x' FROM 'x') IS NULL;
-- }

--
-- Section 4: functions return empty clob as an output
-- {
--= 1
SELECT count(*) FROM dual WHERE LTRIM(to_clob('x'), 'x') IS NOT NULL;
--= 1
SELECT count(*) FROM dual WHERE REGEXP_REPLACE(to_clob('123'), '\d', '') IS NOT NULL;
--= 1
SELECT count(*) FROM dual WHERE REGEXP_SUBSTR(to_clob('x'), '\d') IS NOT NULL;
--= 1
SELECT count(*) FROM dual WHERE REPLACE(to_clob('xx'), 'x', '') IS NOT NULL;
--= 1
SELECT count(*) FROM dual WHERE RTRIM(to_clob('x'), 'x') IS NOT NULL;
--= 0
SELECT count(*) FROM dual WHERE SUBSTR(to_clob('x'), 0, 0) IS NOT NULL;
--= 1
SELECT count(*) FROM dual WHERE TRIM('x' FROM to_clob('x')) IS NOT NULL;
-- }

--
-- Section 5: general queries
-- {
create table foo (a clob);
insert into foo values ('');
insert into foo values (null);
insert into foo values ('x');
insert into foo values (empty_clob());
--= 2
select count(*) from foo where a is null;
--= 2
select count(*) from foo where a is not null;
--= error
select count(*) from foo where a = null;
--= error
select count(*) from foo where a = '';
--= 0
select count(*) from foo where DBMS_LOB.COMPARE(a, TO_CLOB('')) = 0;
--= 0
select count(*) from foo where DBMS_LOB.COMPARE(a, TO_CLOB(null)) = 0;
--= 1
select count(*) from foo where dbms_lob.compare(a, EMPTY_CLOB()) = 0;
--= 1
select count(*) from foo where DBMS_LOB.COMPARE(a, TO_CLOB('x')) = 0;
update foo set a = '' where DBMS_LOB.COMPARE(a, TO_CLOB('x')) = 0;
--= 3
select count(*) from foo where a is null;
delete from foo where a is null;
--= 0
select count(*) from foo where a is null;
drop table foo;
-- }

-- Section 6: prepared statement
-- {
create table foo (a clob);
insert into foo values ('');
insert into foo values (null);
insert into foo values ('x');
insert into foo values (empty_clob());
-- update with bind parameters
DECLARE
  sql_statement VARCHAR2(200);
  cnt NUMBER;
BEGIN
  sql_statement := 'update foo set a = :a where DBMS_LOB.COMPARE(a, TO_CLOB(''x'')) = 0';
  
  -- Prepare the statement with empty string
  EXECUTE IMMEDIATE sql_statement USING '';
END;
-- 3
select count(*) from foo where a is null;
DROP TABLE foo;
-- }

--
-- Section 7: unkown problems
-- {
-- error, should be 0
select count(*) from dual where (1,2) in ((null,null));
-- }
