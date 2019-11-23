/* -------------------------------------------------------------------------
** BEFORE INSERT ROW TRIGGER
**      Initializing MemberOf.
** -------------------------------------------------------------------------*/
CREATE OR REPLACE TRIGGER student_insert
    BEFORE INSERT ON student
    FOR EACH ROW
BEGIN
    :NEW.memberOf := campusclub_array();
END;
/

/* ---------------------------------------------------------------------------
** To add or remove a student as a member of a campus club, use the procedures 
** addMembersAssociation or removeMembersAssociation, respectively.
** -------------------------------------------------------------------------*/


/* -------------------------------------------------------------------------
** BEFORE DELETE ROW TRIGGER
**      Remove the person object the student inherits (maintain mandatory
**       inheritance property).
** -------------------------------------------------------------------------*/
CREATE OR REPLACE TRIGGER student_rowdelete
    BEFORE DELETE ON student
    FOR EACH ROW
DECLARE
	c_obj    campusclub_t;
	clubID	 NUMBER;
BEGIN
    FOR i IN 1..:OLD.memberOf.COUNT LOOP
	SELECT DEREF(:OLD.memberOf(i)) INTO c_obj FROM DUAL;
	SELECT c_obj.cid INTO clubID FROM DUAL;
    	INSERT INTO CLUB_TEMP VALUES(clubID);
    END LOOP;

    --Remove person
    DELETE person p WHERE REF(p) = :OLD.super;
END student_rowdelete;
/
SHOW ERRORS;


/* -------------------------------------------------------------------------
** AFTER DELETE STATEMENT TRIGGER
**      Remove the student from all club memberships.
** -------------------------------------------------------------------------*/
CREATE OR REPLACE TRIGGER student_delete
    AFTER DELETE ON student
BEGIN
    --Remove invalid REFs from campusclub.members
    FOR rec IN (SELECT cid FROM club_temp) LOOP
        DELETE FROM
            TABLE(SELECT c.members FROM campusclub c WHERE c.cid = rec.cid ) t
        WHERE t.COLUMN_VALUE IS DANGLING;
    END LOOP;

    DELETE club_temp;
END student_delete;
/
SHOW ERRORS;
