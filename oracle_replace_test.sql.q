--
-- https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/REPLACE.html#GUID-1A79BDDF-2D3B-4AD4-98E7-985B2E59DA6B
--

--
-- Section 1: functional test
-- {
--= ab
select replace('axxb', 'x') from dual;
--?
select replace('axxb', '') from dual;
--?
select replace('axxb', '', '') from dual;
-- }

--
-- Section 2: type test
-- {
--<<
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE T';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
-->>

create table T(a char(10), b varchar(10), c varchar2(10), d clob);
insert into T values('x', 'x', 'x', 'x');
--?
select count(*) from T where replace(a, 'x') is null;
--?
select count(*) from T where replace(b, 'x') is null;
--?
select count(*) from T where replace(c, 'x') is null;
--?
select count(*) from T where replace(d, 'x') is null;
drop table T;
-- }

