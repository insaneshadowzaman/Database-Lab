-- set serveroutput on;
drop table autogen;
drop table votes;
drop table uploads;
drop table shortcut;
drop table users;

create table users (
  email        varchar(30) PRIMARY KEY,
  name         varchar(30) not null,
  pass         varchar(30) not null,
  date_created date
);

create table shortcut (
  id            number      PRIMARY KEY,
  name          varchar(30) not null,
  description   varchar(200) null,
  upload_date   date,
  uploader      varchar(30),
  reputation    number default 0,
  foreign key   (uploader) references users(email) ON DELETE CASCADE
);

CREATE TABLE uploads (
  users    varchar(30),
  shortcut number primary key,
  FOREIGN KEY (users) REFERENCES users (email) ON DELETE CASCADE,
  FOREIGN KEY (shortcut) REFERENCES shortcut (id) ON DELETE CASCADE
);

CREATE TABLE votes (
  users    varchar(30),
  shortcut number,
  upvote   number,
  FOREIGN KEY (USERS) REFERENCES USERS (EMAIL) ON DELETE CASCADE,
  FOREIGN KEY (SHORTCUT) REFERENCES SHORTCUT (ID) ON DELETE CASCADE,
  CONSTRAINT VOTES_USERS_SHORTCUT_PK PRIMARY KEY (USERS,SHORTCUT)
);

CREATE TABLE autogen (
  shortcut number PRIMARY KEY
);

CREATE OR REPLACE TRIGGER TOTAL_VOTES_COUNT
  AFTER INSERT
  ON VOTES
  FOR EACH ROW
  DECLARE
    rep number;
  BEGIN
    SELECT reputation
    INTO rep
    FROM shortcut where id = :new.shortcut;
    if :new.upvote = 1 then
        rep := rep + 1;
    else
        rep := rep - 1;
    end if;
    update shortcut set reputation = rep where id = :new.shortcut;
  END;

CREATE OR REPLACE TRIGGER IDENTITY_ON_SHORTCUT
  AFTER INSERT
  ON SHORTCUT
  FOR EACH ROW
  DECLARE
    S_ID AUTOGEN.SHORTCUT%TYPE;
  BEGIN
    SELECT SHORTCUT
    INTO S_ID
    FROM AUTOGEN;
    S_ID := S_ID + 1;
    UPDATE AUTOGEN
    SET SHORTCUT = S_ID;
    INSERT INTO UPLOADS (USERS, SHORTCUT) VALUES (:NEW.UPLOADER, :NEW.ID);
  END;

insert into autogen (shortcut) values (1);

CREATE or REPLACE PROCEDURE get_shortcuts(u_name varchar)
IS
  type names is varray (50) of shortcut.name%type;
  type ids is varray (50) of shortcut.id%type;

  s_ids   ids := ids();
  s_names names := names();
  s_id    shortcut.id%type;
  u_id    users.email%type;
  s_name  shortcut.name%type;

  counter number := 0;

  cursor shortcut_cursor is
    select
      s.id,
      s.name
    from shortcut s, users u, uploads up
    where u.name = u_name and u.email = up.users and s.id = up.shortcut;


  BEGIN
    select email
    into u_id
    from users
    where name = u_name;

    open shortcut_cursor;
    loop
      counter := counter + 1;
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


CREATE or REPLACE PROCEDURE shortcut_rep(s_id number)
IS
  up   number;
  down number;
  BEGIN
    select count(users)
    into up
    from votes
    where shortcut = s_id and upvote = 1;
    select count(users)
    into down
    from votes
    where shortcut = s_id and upvote = 0;

    dbms_output.put_line('UPVOTES : ' || up);
    dbms_output.put_line('DOWNVOTES : ' || down);
    dbms_output.put_line('TOTAL REPUTATION : ' || (up - down));

  END shortcut_rep;

declare
  f     utl_file.file_type;
  line  varchar(1000);
  name1 varchar(30);
  pass1 varchar(30);
  email1 varchar(30);
begin
  f := utl_file.fopen('DATABASE', 'file_raw.csv', 'r');
  if utl_file.is_open(f)
  then
    utl_file.get_line(f, line, 1000);
    loop begin
      utl_file.get_line(f, line, 1000);
      if line is null
      then exit;
      end if;
      name1 := regexp_substr(line, '[^,]+', 1, 1);
      pass1 := regexp_substr(line, '[^,]+', 1, 2);
      email1 := regexp_substr(line, '[^,]+', 1, 3);
      insert into users (name, pass, date_created, email) values (name1, pass1, sysdate, email1);
      exception when no_data_found
      then exit;
    end;
    end loop;
    commit;
  end if;
  utl_file.fclose(f);
end;


  /*
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
*/

  insert into shortcut (uploader, name, description, id, upload_date) values ('a@gmail', 'short1_1', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('a@gmail', 'short1_2', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('a@gmail', 'short1_3', 'description', (select shortcut
                                                                                 from autogen), sysdate);

  insert into shortcut (uploader, name, description, id, upload_date) values ('b@gmail', 'short2_1', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('b@gmail', 'short2_2', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('b@gmail', 'short2_3', 'description', (select shortcut
                                                                                 from autogen), sysdate);

  insert into shortcut (uploader, name, description, id, upload_date) values ('c@gmail', 'short3_1', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('c@gmail', 'short3_2', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('c@gmail', 'short3_3', 'description', (select shortcut
                                                                                 from autogen), sysdate);

  insert into shortcut (uploader, name, description, id, upload_date) values ('d@gmail', 'short4_1', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('d@gmail', 'short4_2', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('d@gmail', 'short4_3', 'description', (select shortcut
                                                                                 from autogen), sysdate);

  insert into shortcut (uploader, name, description, id, upload_date) values ('e@gmail', 'short5_1', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('e@gmail', 'short5_2', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('e@gmail', 'short5_3', 'description', (select shortcut
                                                                                 from autogen), sysdate);

  insert into shortcut (uploader, name, description, id, upload_date) values ('f@gmail', 'short6_1', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('f@gmail', 'short6_2', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('f@gmail', 'short6_3', 'description', (select shortcut
                                                                                 from autogen), sysdate);

  insert into shortcut (uploader, name, description, id, upload_date) values ('g@gmail', 'short7_1', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('g@gmail', 'short7_2', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('g@gmail', 'short7_3', 'description', (select shortcut
                                                                                 from autogen), sysdate);

  insert into shortcut (uploader, name, description, id, upload_date) values ('h@gmail', 'short8_1', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('h@gmail', 'short8_2', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('h@gmail', 'short8_3', 'description', (select shortcut
                                                                                 from autogen), sysdate);

  insert into shortcut (uploader, name, description, id, upload_date) values ('i@gmail', 'short9_1', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('i@gmail', 'short9_2', 'description', (select shortcut
                                                                                 from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('i@gmail', 'short9_3', 'description', (select shortcut
                                                                                 from autogen), sysdate);

  insert into shortcut (uploader, name, description, id, upload_date) values ('j@gmail', 'short10_1', 'description', (select shortcut
                                                                                   from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('j@gmail', 'short10_2', 'description', (select shortcut
                                                                                   from autogen), sysdate);
  insert into shortcut (uploader, name, description, id, upload_date) values ('j@gmail', 'short10_3', 'description', (select shortcut
                                                                                   from autogen), sysdate);

insert into votes (users, shortcut, upvote) values (
  'a@gmail', 2, 1
);
insert into votes (users, shortcut, upvote) values (
  'a@gmail', 3, 0
);

insert into votes (users, shortcut, upvote) values (
  'b@gmail', 3, 1
);
insert into votes (users, shortcut, upvote) values (
  'b@gmail', 4, 0
);

insert into votes (users, shortcut, upvote) values (
  'c@gmail', 4, 1
);
insert into votes (users, shortcut, upvote) values (
  'c@gmail', 5, 0
);

insert into votes (users, shortcut, upvote) values (
  'd@gmail', 5, 1
);
insert into votes (users, shortcut, upvote) values (
  'd@gmail', 6, 0
);

insert into votes (users, shortcut, upvote) values (
  'e@gmail', 6, 1
);
insert into votes (users, shortcut, upvote) values (
  'e@gmail', 7, 0
);

insert into votes (users, shortcut, upvote) values (
  'f@gmail', 7, 1
);
insert into votes (users, shortcut, upvote) values (
  'f@gmail', 8, 0
);

insert into votes (users, shortcut, upvote) values (
  'g@gmail', 8, 1
);
insert into votes (users, shortcut, upvote) values (
  'g@gmail', 9, 0
);

insert into votes (users, shortcut, upvote) values (
  'h@gmail', 9, 1
);
insert into votes (users, shortcut, upvote) values (
  'h@gmail', 10, 0
);

insert into votes (users, shortcut, upvote) values (
  'i@gmail', 10, 1
);
insert into votes (users, shortcut, upvote) values (
  'i@gmail', 1, 0
);

insert into votes (users, shortcut, upvote) values (
  'j@gmail', 1, 1
);
insert into votes (users, shortcut, upvote) values (
  'j@gmail', 2, 0
);

commit;

begin
  get_shortcuts('user1');
  shortcut_rep(4);
END;

declare
  f utl_file.file_type;
  cursor c is select *
              from shortcut;

begin
  f := utl_file.fopen('DATABASE', 'file_out.csv', 'w');
  utl_file.put_line(f, 'ID' || ',' || 'NAME' || ',' || 'UPLOAD_DATE' || ',' || 'UPLOADER');
  for c_record in c
  loop
    utl_file.put_line(f,
                      c_record.id || ',' || c_record.name || ',' || c_record.upload_date || ',' || c_record.UPLOADER);
  end loop;

  utl_file.fclose(f);
end;
/