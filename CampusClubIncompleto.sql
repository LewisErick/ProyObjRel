drop type personUdt FORCE;
drop type facultyUdt FORCE;
drop type locationUdt FORCE;
drop type studentUdt FORCE;
drop type campusClubUdt FORCE;
drop type studUdtAux FORCE;
drop table faculty FORCE;
drop table person FORCE;
drop table student FORCE;
drop table campusClub FORCE;
drop table department FORCE;
drop type departmentUdt FORCE;
drop type campusClubAux FORCE;
drop type studArr FORCE;
drop type facultyArr FORCE;

create type personUdt AS OBJECT
(pid varchar(11),
firstName varchar(20),
lastName varchar(20),
dob date)
instantiable not final;
/

CREATE TYPE locationUdt AS OBJECT
(street varchar(30),
bldg varchar(5),
room varchar(5)
)not final;
/


create type studentUdt under personUdt
( status varchar(10)
) instantiable not final;
/

create table person of personUdt(pid PRIMARY KEY)  OBJECT IDENTIFIER IS SYSTEM GENERATED;

create table faculty of facultyUdt;

create table student of studentUdt;


create type studUdtAux as VARRAY(50) of REF studentUdt;
/

create type campusClubUdt as OBJECT
( cId number, 
name varchar(50), 
location locationUdt, 
phone varchar(12), 
advisor REF facultyUdt,
members studUdtAux
) instantiable not final
;
/

create table campusClub of campusClubUdt(
CONSTRAINT cIdPK PRIMARY KEY (cId), 
advisor SCOPE IS faculty
)
OBJECT IDENTIFIER IS SYSTEM GENERATED;


create type studArr as VARRAY(1000) of REF studentUdt;
 /
 
create type facultyArr as VARRAY(50) of REF facultyUdt;
  /
  
 
CREATE TYPE departmentUdt AS OBJECT (
  code varchar(3),
  name varchar(40),
  deptChair REF facultyUdt,
  MEMBER FUNCTION getStudents(arg1 in Number) RETURN studArr,
  MEMBER FUNCTION getFactulty(arg1 in Number) RETURN facultyArr
  )instantiable not final;
  /
  CREATE OR REPLACE TYPE BODY departmentUdt AS
	MEMBER FUNCTION getStudents(arg1 in Number) RETURN studArr IS
		cosa studArr;
		BEGIN
			Select REF(s) BULK COLLECT into cosa from student s where ROWNUM<=50 AND deref(major).code = arg1;
			RETURN cosa;
		END;

END;
/
  
CREATE TABLE department of departmentUdt(
  CONSTRAINT dep_PK PRIMARY KEY(code),
  deptChair NOT NULL SCOPE IS faculty 
 )OBJECT IDENTIFIER IS SYSTEM GENERATED;
 
 create type campusClubAux as VARRAY(5) of REF campusClubUdt;
 /
 
   
 ALTER TYPE facultyUdt ADD ATTRIBUTE (
   advisorOF campusClubAux,
   worksIn REF departmentUdt,
   chairOf REF departmentUdt
 )CASCADE;
 
 ALTER TABLE faculty add CONSTRAINT check_rank CHECK (rank IN ('Instructor', 'Asistente', 'Asociado', 'Titular'));
 
 ALTER TABLE student add CONSTRAINT check_status CHECK (status IN ('freshman', 'sophomore', 'junior', 'senior'));
  
  ALTER TABLE faculty ADD(
    SCOPE FOR (worksIn) IS department,
    SCOPE FOR (chairOf) is department
  );
  
  ALTER TABLE student ADD(
      SCOPE FOR (major) is department
    );  
    
 ALTER TABLE faculty 
      ADD CONSTRAINT dirDept CHECK (worksIn = chairOf) ENABLE;



---INSERCION DE PROFESORES---

INSERT INTO faculty VALUES (1, 'Juan Carlos', 'Lavariega', '4-OCT-2000', 'Titular', 10000, NULL, NULL, NULL);
INSERT INTO faculty VALUES (2, 'Pablo', 'Diaz', '5-OCT-2000', 'Asociado', 12000, NULL, NULL, NULL);
INSERT INTO faculty VALUES (3, 'Leonardo', 'Garrido', '6-OCT-2000', 'Asistente', 15000, NULL, NULL, NULL);
INSERT INTO faculty VALUES (4, 'Luis Humberto', 'Gonzalez', '8-OCT-2000', 'Asociado', 10000, NULL, NULL, NULL);
INSERT INTO faculty VALUES (5, 'Elda', 'Quiroga', '9-OCT-2000', 'Instructor', 20000, NULL, NULL, NULL);
INSERT INTO faculty VALUES(6, 'Mario', 'De la Fuente', '10-OCT-2000', 'Titular', 18000, NULL, NULL, NULL);

--Creacion de 3 clubes--
INSERT INTO campusClub VALUES (100, 'Club1', locationUdt('Garza Sada', 'A4','101'), '88808707',NULL,NULL);
INSERT INTO campusClub VALUES (101, 'Club2', locationUdt('Junco de la Vega', 'A3','301'), '88801000',NULL,NULL);
INSERT INTO campusClub VALUES (102, 'Club3', locationUdt('Garcia Roel', 'A5','202'), '83675859',NULL,NULL);

--Poniendo a los Advisors de los Clubes--
UPDATE campusClub SET Advisor= (SELECT REF(p) FROM faculty p WHERE p.PID=5) WHERE CID=100;
UPDATE campusClub SET Advisor= (SELECT REF(p) FROM faculty p WHERE p.PID=6) WHERE CID=102;
UPDATE campusClub SET Advisor= (SELECT REF(p) FROM faculty p WHERE p.PID=5) WHERE CID=101;

--INSERCION DE ESTUDIANTES--

INSERT INTO student values ('0', 'Alex', 'Gg', '12-MAR-1990', 'freshman', NULL, NULL);
INSERT INTO student values ('1', 'Charlie', 'Aa', '13-MAR-1990', 'freshman', NULL, NULL);
INSERT INTO student values ('2', 'Juan', 'Bb', '14-MAR-1990', 'freshman', NULL, NULL);

--Insertar memberOf a students--
UPDATE student SET memberOf = campusClubAux ((SELECT REF(c) FROM CampusClub c WHERE c.cId=100)) WHERE pid='0';
UPDATE student SET memberOf = campusClubAux ((SELECT REF(c) FROM CampusClub c WHERE c.cId=101)) WHERE pid='1';
UPDATE student SET memberOf = campusClubAux ((SELECT REF(c) FROM CampusClub c WHERE c.cId=102)) WHERE pid='2';

UPDATE campusClub SET members = studUdtAux (
						(SELECT REF(s) FROM Student s WHERE s.pId='0'),
						(SELECT REF(s) FROM Student s WHERE s.pId='3'),
						(SELECT REF(s) FROM Student s WHERE s.pId='6'),
						(SELECT REF(s) FROM Student s WHERE s.pId='9'),
						(SELECT REF(s) FROM Student s WHERE s.pId='27')
					    ) WHERE cId=100;
commit;