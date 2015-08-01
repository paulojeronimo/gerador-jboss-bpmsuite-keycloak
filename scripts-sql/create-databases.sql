-- keycloak
create user keycloak identified by keycloak default tablespace users;
alter user keycloak quota unlimited on users;
grant create session, create table, create procedure, create trigger, create any directory, create view, create sequence, create synonym, create materialized view to keycloak;

-- bpms
create user bpms identified by bpms default tablespace users;
alter user bpms quota unlimited on users;
grant create session, create table, create procedure, create trigger, create any directory, create view, create sequence, create synonym, create materialized view to bpms;
