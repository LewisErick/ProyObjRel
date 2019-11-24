drop type if exists personUdt CASCADE;
drop type if exists locationUdt CASCADE;
drop type if exists campusClubUdt CASCADE;
drop type if exists departmentUdt CASCADE;
drop table if exists faculty CASCADE;
drop table if exists person CASCADE;
drop table if exists student CASCADE;
drop table if exists campusClub CASCADE;
drop table if exists department CASCADE;

create type personUdt AS 
(pid varchar(11),
firstName varchar(20),
lastName varchar(20),
dob date);
/*instantiable not final;*/

create table person of personUdt (PRIMARY key(pid));/* OBJECT IDENTIFIER IS SYSTEM GENERATED;*/

CREATE TYPE locationUdt AS
(street varchar(30),
bldg varchar(5),
room varchar(5)
); /*not final;*/

CREATE TYPE departmentUdt AS (
  code varchar(3),
  name varchar(40),
  deptChair varchar(11)
  );/*instantiable not final;*/
  
create table faculty(
rank varchar(5),
salario float,
PRIMARY key(pid)) inherits (person);
  
CREATE TABLE department of departmentUdt(
  PRIMARY KEY(code),
  foreign key (deptChair) references faculty(pid) 
 );

create table student(status varchar(10), major varchar(3) references department(code), primary key(pid)) inherits (person);

alter table faculty add worksIn varchar(3) references department(code);
alter table faculty add chairOf varchar(3) references department(code);

create type campusClubUdt as 
( cId int, 
name varchar(50), 
location locationUdt, 
phone varchar(12),
advisor varchar(11)
);

create table campusClub of campusClubUdt
(
foreign key (advisor) references faculty(pid),
PRIMARY KEY (cId));

drop table campusClub_members;
create table campusClub_members(
	cId int references campusClub(cId),
	members varchar(11) references student(pid),
   	PRIMARY KEY(cId, members)
);

CREATE OR REPLACE FUNCTION getStudents (varchar(3))  
RETURNS SETOF record AS $$
SELECT * FROM student s, department d WHERE s.major = d.code AND d.code = $1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION getFaculty (varchar(3))  
RETURNS SETOF record AS $$
SELECT * FROM faculty f, department d WHERE f.worksIn = d.code AND d.code = $1;
$$ LANGUAGE SQL;

ALTER TABLE faculty add CONSTRAINT check_rank CHECK (rank IN ('Instructor', 'Asistente', 'Asociado', 'Titular'));
 
ALTER TABLE student add CONSTRAINT check_status CHECK (status IN ('freshman', 'sophomore', 'junior', 'senior'));  
    
 ALTER TABLE faculty ADD CONSTRAINT dirDept CHECK (worksIn != chairOf);
commit;