set serveroutput on;
drop table autogen;
drop table votes;
drop table uploads;
drop table shortcut;
drop table users;

create table users(
  id number not null,
  name varchar(10) not null,
  pass varchar(10) not null,
  date_created date,
  PRIMARY KEY(id)
);

create table shortcut(
  id number not null,
  name varchar(10) not null,
  upload_date date,
  UPLOADER NUMBER,
  PRIMARY KEY (id),
  foreign key (uploader) references users(id)
);

CREATE TABLE uploads(
  users number,
  shortcut number,
  uploaded date,
  FOREIGN KEY (users) REFERENCES users(id),
  FOREIGN KEY (shortcut) REFERENCES shortcut(id)
);

CREATE TABLE votes(
  users number,
  shortcut number,
  upvote number
);

CREATE TABLE autogen(
  shortcut number,
  users number
);

CREATE OR REPLACE TRIGGER IDENTITY_ON_USER
    AFTER INSERT ON USERS
    FOR EACH ROW
DECLARE
    USER_ID AUTOGEN.USERS%TYPE;
BEGIN
    SELECT USERS INTO USER_ID FROM AUTOGEN;
    USER_ID := USER_ID + 1;
    UPDATE AUTOGEN SET USERS = USER_ID;
END;

CREATE OR REPLACE TRIGGER IDENTITY_ON_SHORTCUT
    AFTER INSERT ON SHORTCUT
    FOR EACH ROW
DECLARE
    USER_ID AUTOGEN.SHORTCUT%TYPE;
BEGIN
    SELECT SHORTCUT INTO USER_ID FROM AUTOGEN;
    USER_ID := USER_ID + 1;
    UPDATE AUTOGEN SET SHORTCUT = USER_ID;   
    INSERT INTO UPLOADS(USERS, SHORTCUT) VALUES(:NEW.UPLOADER, :NEW.ID);
END;

-- CREATE or REPLACE PROCEDURE ADD_SHORTCUT (uploader_id IN NUMBER, s_name in VARCHAR)
--  IS
--    shortcut_id autogen.shortcut%type;
--  BEGIN
--    SELECT shortcut INTO shortcut_id FROM AUTOGEN;
--
--    INSERT INTO SHORTCUT (ID, UPLOAD_DATE, name) VALUES (
--      shortcut_id, current_date, s_name
--    );
--    INSERT INTO UPLOADS (USERS, SHORTCUT, uploaded) VALUES (uploader_id, shortcut_id, current_date);
--    commit;
--    dbms_output.put_line('Shortcut Added');
--END ADD_SHORTCUT;
--
-- CREATE or REPLACE PROCEDURE get_shortcuts (u_name varchar)
--  IS
--    type names is varray(50) of shortcut.name%type;
--    type ids is varray(50) of shortcut.id%type;
--
--    s_ids ids := ids();
--    s_names names := names();
--    s_id shortcut.id%type;
--    u_id users.id%type;
--    s_name shortcut.name%type;
--
--    counter number := 0;
--
--    cursor shortcut_cursor is
--      select s.id, s.name from shortcut s, users u, uploads up where u.name = u_name and u.id = up.users and s.id = up.shortcut;
--
--
--  BEGIN
--    select id into u_id from users where name = u_name;
--    
--    open shortcut_cursor;
--    loop
--      counter := counter+1;
--      fetch shortcut_cursor into s_id, s_name;
--      exit when shortcut_cursor%notfound;
--      s_ids.extend;
--      s_ids(counter) := s_id;
--      s_names.extend;
--      s_names(counter) := s_name;
--    end loop;
--    close shortcut_cursor;
--
--    for n in 1..s_ids.count loop
--      dbms_output.put_line('ID : ' || s_ids(n) || ' , NAME : ' || s_names(n));
--    end loop;
--
--  END get_shortcuts;
--  
--   CREATE or REPLACE PROCEDURE shortcut_rep (s_id number)
--  IS
--    up number;
--    down number;
--  BEGIN
--    select count(users) into up from votes where shortcut = s_id and upvote = 1;
--    select count(users) into down from votes where shortcut = s_id and upvote = 0;
--
--    dbms_output.put_line('UPVOTES : ' || up);
--    dbms_output.put_line('DOWNVOTES : ' || down);
--    dbms_output.put_line('TOTAL REPUTATION : ' || (up - down));
--
--END shortcut_rep;
--
-- CREATE or REPLACE PROCEDURE sign_up (u_name varchar, u_pass varchar)
--  IS
--    u_id autogen.users%type;
--  BEGIN
--    SELECT users INTO u_id FROM AUTOGEN;
--
--    insert into users(ID, name, pass, date_created) values(
--        u_id, u_name, u_pass, CURRENT_DATE
--    );
--    commit;
--    dbms_output.put_line('Signed up');
--END sign_up;

 CREATE or REPLACE PROCEDURE upvote (u_id number, s_id number, up_down number)
  IS
  BEGIN
    insert into votes(users, shortcut, upvote) values(
        u_id, s_id, up_down
    );


    IF up_down = 1 THEN dbms_output.put_line('upvoted');
    ELSE dbms_output.put_line('downvoted');
    end if;
END upvote;

insert into autogen(shortcut, users) values(1,1);

 CREATE or REPLACE PROCEDURE get_shortcuts (u_name varchar)
  IS
    type names is varray(50) of shortcut.name%type;
    type ids is varray(50) of shortcut.id%type;

    s_ids ids := ids();
    s_names names := names();
    s_id shortcut.id%type;
    u_id users.id%type;
    s_name shortcut.name%type;

    counter number := 0;

    cursor shortcut_cursor is
      select s.id, s.name from shortcut s, users u, uploads up where u.name = u_name and u.id = up.users and s.id = up.shortcut;


  BEGIN
    select id into u_id from users where name = u_name;
    
    open shortcut_cursor;
    loop
      counter := counter+1;
      fetch shortcut_cursor into s_id, s_name;
      exit when shortcut_cursor%notfound;
      s_ids.extend;
      s_ids(counter) := s_id;
      s_names.extend;
      s_names(counter) := s_name;
    end loop;
    close shortcut_cursor;

    for n in 1..s_ids.count loop
      dbms_output.put_line('ID : ' || s_ids(n) || ' , NAME : ' || s_names(n));
    end loop;

  END get_shortcuts;



 CREATE or REPLACE PROCEDURE shortcut_rep (s_id number)
  IS
    up number;
    down number;
  BEGIN
    select count(users) into up from votes where shortcut = s_id and upvote = 1;
    select count(users) into down from votes where shortcut = s_id and upvote = 0;

    dbms_output.put_line('UPVOTES : ' || up);
    dbms_output.put_line('DOWNVOTES : ' || down);
    dbms_output.put_line('TOTAL REPUTATION : ' || (up - down));

END shortcut_rep;



BEGIN
    insert into users(id, name, pass) values((select users from autogen), 'user1', 'pass1');
    insert into users(id, name, pass) values((select users from autogen), 'user2', 'pass2');
    insert into users(id, name, pass) values((select users from autogen), 'user3', 'pass3');
    insert into users(id, name, pass) values((select users from autogen), 'user4', 'pass4');
    insert into users(id, name, pass) values((select users from autogen), 'user5', 'pass5');
    insert into users(id, name, pass) values((select users from autogen), 'user6', 'pass6');
    insert into users(id, name, pass) values((select users from autogen), 'user7', 'pass7');
    insert into users(id, name, pass) values((select users from autogen), 'user8', 'pass8');
    insert into users(id, name, pass) values((select users from autogen), 'user9', 'pass9');
    insert into users(id, name, pass) values((select users from autogen), 'user10', 'pass10');

    insert into shortcut(uploader, name, id) values(1, 'short1_1', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(1, 'short1_2', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(1, 'short1_3', (select shortcut from autogen));

    insert into shortcut(uploader, name, id) values(2, 'short2_1', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(2, 'short2_2', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(2, 'short2_3', (select shortcut from autogen));

    insert into shortcut(uploader, name, id) values(3, 'short3_1', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(3, 'short3_2', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(3, 'short3_3', (select shortcut from autogen));

    insert into shortcut(uploader, name, id) values(4, 'short4_1', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(4, 'short4_2', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(4, 'short4_3', (select shortcut from autogen));

    insert into shortcut(uploader, name, id) values(5, 'short5_1', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(5, 'short5_2', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(5, 'short5_3', (select shortcut from autogen));

    insert into shortcut(uploader, name, id) values(6, 'short6_1', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(6, 'short6_2', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(6, 'short6_3', (select shortcut from autogen));

    insert into shortcut(uploader, name, id) values(7, 'short7_1', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(7, 'short7_2', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(7, 'short7_3', (select shortcut from autogen));

    insert into shortcut(uploader, name, id) values(8, 'short8_1', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(8, 'short8_2', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(8, 'short8_3', (select shortcut from autogen));

    insert into shortcut(uploader, name, id) values(9, 'short9_1', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(9, 'short9_2', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(9, 'short9_3', (select shortcut from autogen));

    insert into shortcut(uploader, name, id) values(10, 'short10_1', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(10, 'short10_2', (select shortcut from autogen));
    insert into shortcut(uploader, name, id) values(10, 'short10_3', (select shortcut from autogen));

    upvote(1,2,1);
    upvote(1,3,0);

    upvote(2,3,1);
    upvote(2,4,0);

    upvote(3,4,1);
    upvote(3,5,0);

    upvote(4,5,1);
    upvote(4,6,0);

    upvote(5,6,1);
    upvote(5,7,0);

    upvote(6,7,1);
    upvote(6,8,0);

    upvote(7,8,1);
    upvote(7,9,0);

    upvote(8,9,1);
    upvote(8,10,0);

    upvote(9,10,1);
    upvote(9,1,0);

    upvote(10,1,1);
    upvote(10,2,0);
    
    commit;

    get_shortcuts('user1');
    shortcut_rep(4);
END;
/