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
rank varchar(50),
salario float,
PRIMARY key(pid)) inherits (person);
  
CREATE TABLE department of departmentUdt(
  PRIMARY KEY(code),
  foreign key (deptChair) references faculty(pid) 
 );

create table student(status varchar(10), major varchar(3) references department(code), primary key(pid)) inherits (person);

alter table faculty add worksIn varchar(3) references department(code);

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
PRIMARY KEY (cId),
UNIQUE(location));

drop table if exists campusClub_members;
create table campusClub_members(
	cId int references campusClub(cId),
	members varchar(11) references student(pid) on delete cascade,
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

INSERT INTO department VALUES ('300','A', NULL);
INSERT INTO department VALUES ('301','B', NULL);

INSERT INTO faculty(pid, firstName, lastName, dob, rank, salario, worksIn) 
	VALUES ('200', 'Juan Carlos', 'Lavariega', '4-OCT-2000', 'Titular', 10000, '300');
INSERT INTO faculty(pid, firstName, lastName, dob, rank, salario, worksIn) 
	VALUES ('201', 'Pablo', 'Diaz', '5-OCT-2000', 'Asociado', 12000, '300');
INSERT INTO faculty(pid, firstName, lastName, dob, rank, salario, worksIn) 
	VALUES ('202', 'Leonardo', 'Garrido', '6-OCT-2000', 'Asistente', 15000,'300' );
INSERT INTO faculty(pid, firstName, lastName, dob, rank, salario, worksIn) 
	VALUES ('203', 'Luis Humberto', 'Gonzalez', '8-OCT-2000', 'Asociado', 10000, '301');
INSERT INTO faculty(pid, firstName, lastName, dob, rank, salario, worksIn) 
	VALUES ('204', 'Elda', 'Quiroga', '9-OCT-2000', 'Instructor', 20000, '301');
INSERT INTO faculty(pid, firstName, lastName, dob, rank, salario, worksIn) 
	VALUES('205', 'Mario', 'De la Fuente', '10-OCT-2000', 'Titular', 18000, '301');

UPDATE department set deptChair = '200'
where department.code = '300';

UPDATE department set deptChair = '203'
where department.code = '301';

INSERT INTO campusClub VALUES ('100', 'Club1', ('Garza Sada', 'A4','101'), '88808707', '201' );
INSERT INTO campusClub VALUES ('101', 'Club2', ('Junco de la Vega', 'A3','301'), '88801000', '202');
INSERT INTO campusClub VALUES ('102', 'Club3', ('Garcia Roel', 'A5','202'), '83675859', '201');

INSERT INTO student values ('0', 'Alex', 'Gg', '12-MAR-1990', 'freshman', '300');
INSERT INTO student values ('1', 'Charlie', 'Aa', '13-MAR-1990', 'freshman', '300');
INSERT INTO student values ('2', 'Juan', 'Bb', '14-MAR-1990', 'freshman', '300');
INSERT INTO student values ('3', 'Pedro', 'González', '15-MAR-1990', 'freshman', '300');
INSERT INTO student values ('4', 'Luis', 'Erick', '16-MAR-1989', 'freshman', '300');
INSERT INTO student values ('5', 'Cordelia', 'Lopez', '17-MAR-1989', 'freshman', '300');
INSERT INTO student values ('6', 'Rosamaria', 'Gonzalez', '18-MAR-1988', 'freshman', '300');
INSERT INTO student values ('7', 'Raul', 'Castellanos', '19-MAR-1989', 'freshman', '300');
INSERT INTO student values ('8', 'Rigo', 'Valadez', '20-MAR-1989', 'freshman', '300');
INSERT INTO student values ('9', 'Natalia', 'Reina', '21-MAR-1989', 'freshman', '300');
INSERT INTO student values ('10', 'Frida', 'Gutierrez', '22-MAR-1989', 'sophomore', '300');
INSERT INTO student values ('11', 'Carlos', 'Gonzalez', '23-MAR-1989', 'sophomore','301');
INSERT INTO student values ('12', 'Luis', 'Rodriguez', '24-MAR-1989', 'sophomore','301');
INSERT INTO student values ('13', 'Sergio', 'Diosdado', '25-MAR-1989', 'sophomore','301');
INSERT INTO student values ('14', 'Iñaki', 'Janeiro', '26-MAR-1989', 'sophomore','301');
INSERT INTO student values ('15', 'Isabel', 'Canales', '27-MAR-1989', 'sophomore','301');
INSERT INTO student values ('16', 'Daniel', 'Ibarra', '28-MAR-1988', 'junior','301');
INSERT INTO student values ('17', 'Hector', 'Ramirez', '29-MAR-1988', 'junior','301');
INSERT INTO student values ('18', 'Laura', 'Garza', '30-MAR-1988', 'junior','301');
INSERT INTO student values ('19', 'Mauricio', 'De La Fuente', '14-MAY-1988', 'junior','301');
INSERT INTO student values ('20', 'Sofia', 'Ontiveros', '15-MAY-1989', 'junior','301');
INSERT INTO student values ('21', 'Andrea', 'Montelongo', '16-MAY-1988', 'junior','301');
INSERT INTO student values ('22', 'Ana', 'Resines', '17-MAY-1987', 'senior','301');
INSERT INTO student values ('23', 'Paola', 'Morales', '18-MAY-1987', 'senior','301');
INSERT INTO student values ('24', 'Barbara', 'Flores', '19-MAY-1987', 'senior','301');
INSERT INTO student values ('25', 'Mariana', 'Moreno', '20-MAY-1987', 'senior','301');
INSERT INTO student values ('26', 'Karen', 'Morales', '21-MAY-1987', 'senior','301');
INSERT INTO student values ('27', 'Eugenio', 'Morales', '22-MAY-1987', 'senior','301');
INSERT INTO student values ('28', 'Daniel', 'Canales', '23-MAY-1987', 'senior','301');
INSERT INTO student values ('29', 'Cristobal', 'Treviño', '24-MAY-1988', 'senior','301');

INSERT INTO campusClub_members values (100, 0);
INSERT INTO campusClub_members values (100, 1);
INSERT INTO campusClub_members values (100, 2);
INSERT INTO campusClub_members values (100, 3);
INSERT INTO campusClub_members values (100, 4);
INSERT INTO campusClub_members values (100, 5);
INSERT INTO campusClub_members values (100, 6);
INSERT INTO campusClub_members values (100, 7);
INSERT INTO campusClub_members values (100, 8);
INSERT INTO campusClub_members values (100, 9);
INSERT INTO campusClub_members values (101, 5);
INSERT INTO campusClub_members values (101, 6);
INSERT INTO campusClub_members values (101, 7);
INSERT INTO campusClub_members values (101, 8);
INSERT INTO campusClub_members values (101, 9);
INSERT INTO campusClub_members values (101, 10);
INSERT INTO campusClub_members values (101, 11);
INSERT INTO campusClub_members values (101, 12);
INSERT INTO campusClub_members values (101, 13);
INSERT INTO campusClub_members values (101, 14);
INSERT INTO campusClub_members values (102, 13);
INSERT INTO campusClub_members values (102, 14);
INSERT INTO campusClub_members values (102, 15);
INSERT INTO campusClub_members values (102, 16);
INSERT INTO campusClub_members values (102, 17);
INSERT INTO campusClub_members values (102, 18);
INSERT INTO campusClub_members values (102, 19);
INSERT INTO campusClub_members values (102, 20);
INSERT INTO campusClub_members values (102, 21);
INSERT INTO campusClub_members values (102, 22);
INSERT INTO campusClub_members values (102, 23);
INSERT INTO campusClub_members values (102, 24);
INSERT INTO campusClub_members values (102, 25);
INSERT INTO campusClub_members values (102, 26);
INSERT INTO campusClub_members values (102, 0);

commit;

CREATE OR REPLACE FUNCTION incrementaSalario_update() RETURNS TRIGGER AS $$
BEGIN
	update faculty set salario = old.salario * 1.10
		where old.rank = 'Asistente' and new.rank = 'Asociado' and pid = old.pid;
RETURN NULL;
END;
$$ language plpgsql;
    
CREATE TRIGGER incrementaSalario AFTER UPDATE OF rank on faculty
FOR EACH row
EXECUTE PROCEDURE incrementaSalario_update();

CREATE OR REPLACE FUNCTION quitarChairSiAplica() RETURNS TRIGGER AS $$
BEGIN
	UPDATE department d SET deptChair = null
		WHERE (code = old.worksIn AND code != new.worksIn AND deptChair = old.pid);
return new;
end;
$$ language plpgsql;

CREATE TRIGGER cambioDepartamento AFTER UPDATE of worksIn on faculty
for each row
execute procedure quitarChairSiAplica();

CREATE OR REPLACE FUNCTION same_dpt() RETURNS TRIGGER AS $$
BEGIN
	UPDATE department d SET deptChair = old.deptChair
			WHERE new.deptChair is not null and new.deptChair not in (SELECT pid FROM faculty f WHERE f.worksIn = d.code) AND new.code = d.code;
return null;
end;
$$ language plpgsql;

CREATE TRIGGER deptChairWorksInDptUpdate AFTER UPDATE of deptChair on department
for each row
execute procedure same_dpt();

CREATE TRIGGER deptChairWorksInDptInsert AFTER INSERT on department
for each row
execute procedure same_dpt();

/* 2.1 */
SELECT s.*
FROM 
(select st.pid, COUNT(st.pid) AS c FROM student st join campusClub_members cm on st.pid = cm.members
GROUP BY st.pid) x JOIN student s
on x.pid = s.pid
where x.c > 1;

/* 2.2 */
SELECT s.*
FROM student s
WHERE s.pid IN (SELECT s.pid FROM student
EXCEPT
SELECT s.pid FROM student s JOIN 
campusClub_members cm on s.pid = members);

/* 2.3 */
SELECT s.firstName, s.lastName, s.dob
FROM student s 
JOIN campusClub_members cm on s.pid = cm.members
WHERE cm.cid = 100;

/* 2.4 */
SELECT f.firstName, f.lastName, f.rank, f.worksIn, d.name
FROM Faculty f join campusClub c on c.advisor = f.pid
JOIN Department d on f.worksIn = d.code
WHERE c.cId = 101;

/* REGLAS */

/* 1 */

/*INSERT INTO Faculty values ('206', 'Pedro', 'García', '12-OCT-1970', 'Jugador', 18700);*/

/* 2 */

/*INSERT INTO Student values ('30', 'Juan', 'Ibarra', '15-OCT-1990', 'Primer', '300');*/

/* 3 */

SELECT f.*, d.code, d.name, d.deptChair
FROM FACULTY f JOIN department d
on f.worksIn = d.code
WHERE f.pid = '201';

UPDATE department
set deptChair = '201'
where code = '301';

select * from department d;

INSERT INTO department VALUES ('305','F', '201');

select * from department d;

/* 4 */

SELECT f.*
FROM FACULTY f
WHERE f.pid = '202';

UPDATE faculty
set rank = 'Asociado'
where pid = '202';

SELECT f.*
	FROM FACULTY f;
	
/* 5 */

SELECT *
FROM department d JOIN faculty f on d.deptChair = f.pid
WHERE d.code = '300';

UPDATE faculty 
set worksIn = '301'
where pid = '200';

SELECT *
FROM department d
WHERE d.code = '300';

/* 6 */
SELECT * FROM STUDENT s JOIN campusClub_members cm on s.pid = cm.members
JOIN campusClub c on cm.cId = c.cId
WHERE s.pid = '0';

/* 7 */
DELETE FROM Student s where s.pid = '14';

SELECT *
FROM Student s
where s.pid = '14';

SELECT *
FROM campusClub_members cm
WHERE cm.members = '14';

/* MAS */

select * from department d;

insert into department values ('306', 'Y', NULL);

select * from department d;

update department
set deptchair = '201'
where code = '306';

select * from department d;

update faculty
set worksIn = '306'
where pid = '201';

select * from faculty f;

update department
set deptchair = '201'
where code = '306';

select * from department d;

update department
set deptchair = '203'
where code = '306';

select * from department d;

update faculty
set worksin = '306'
where pid = '203';

select * from department d;

update department
set deptchair = '203'
where code = '306';

select * from department d;