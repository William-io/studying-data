/*
  Criação das Tabelas
*/
/* Estado  */
CREATE TABLE states (
  state_id NUMBER CONSTRAINT states_id_nn NOT NULL,
  state_name VARCHAR2(25)
);
CREATE UNIQUE INDEX reg_id_pk
ON states (state_id);
ALTER TABLE states
ADD CONSTRAINT reg_id_pk
PRIMARY KEY (state_id);

/* Municipio */
CREATE TABLE counties (
  county_id CHAR(2) CONSTRAINT  county_id_nn NOT NULL,
  county_name VARCHAR2(40),
  state_id NUMBER,
  CONSTRAINT county_c_id_pk PRIMARY KEY (county_id)
)
ORGANIZATION INDEX;
ALTER TABLE counties
ADD CONSTRAINT countr_reg_fk
FOREIGN KEY (state_id)
REFERENCES states(state_id);

/* Localizacao/bairro */
CREATE TABLE locations (
  location_id    NUMBER(4),
  street_address VARCHAR2(40),
  postal_code    VARCHAR2(12),
  city       VARCHAR2(30) CONSTRAINT loc_city_nn  NOT NULL,
  state_province VARCHAR2(25),
  county_id     CHAR(2)
);
CREATE UNIQUE INDEX loc_id_pk
ON locations (location_id);
ALTER TABLE locations
ADD (
    CONSTRAINT loc_id_pk PRIMARY KEY (location_id),
    CONSTRAINT loc_c_id_fk FOREIGN KEY (county_id) REFERENCES counties(county_id)
);
CREATE SEQUENCE locations_seq
  START WITH     3300
  INCREMENT BY   100
  MAXVALUE       9900
  NOCACHE
  NOCYCLE;
/* categories */

CREATE TABLE categories (
  category_id    NUMBER(4),
  category_title  VARCHAR2(30) CONSTRAINT  dept_name_nn  NOT NULL,
  manager_id       NUMBER(6),
  location_id      NUMBER(4)
);
CREATE UNIQUE INDEX dept_id_pk
ON categories (category_id) ;
ALTER TABLE categories
ADD (
  CONSTRAINT dept_id_pk PRIMARY KEY (category_id),
  CONSTRAINT dept_loc_fk FOREIGN KEY (location_id) REFERENCES locations (location_id)
);
CREATE SEQUENCE categories_seq
  START WITH     280
  INCREMENT BY   10
  MAXVALUE       9990
  NOCACHE
  NOCYCLE;

/* courses */
CREATE TABLE courses (
  course_id         VARCHAR2(10),
  course_title      VARCHAR2(35) CONSTRAINT course_title_nn  NOT NULL,
  min_price     NUMBER(6),
  max_price     NUMBER(6)
);
CREATE UNIQUE INDEX course_id_pk
ON courses (course_id) ;
ALTER TABLE courses
ADD (
  CONSTRAINT course_id_pk PRIMARY KEY(course_id)
);

/* users */
CREATE TABLE users (
  user_id    NUMBER(6),
  first_name     VARCHAR2(20),
  last_name      VARCHAR2(25) CONSTRAINT us_last_name_nn  NOT NULL,
  email          VARCHAR2(25) CONSTRAINT us_email_nn  NOT NULL,
  phone_number   VARCHAR2(20),
  hire_date      DATE CONSTRAINT us_hire_date_nn  NOT NULL,
  course_id         VARCHAR2(10) CONSTRAINT us_course_nn  NOT NULL,
  spending         NUMBER(8,2),
  commission_pct NUMBER(2,2),
  manager_id     NUMBER(6),
  category_id  NUMBER(4),
  CONSTRAINT     us_spending_min CHECK (spending > 0),
  CONSTRAINT     us_email_uk UNIQUE (email)
);
CREATE UNIQUE INDEX us_us_id_pk
ON users (user_id);

ALTER TABLE users
ADD (
  CONSTRAINT us_us_id_pk
    PRIMARY KEY (user_id),
  CONSTRAINT us_dept_fk
    FOREIGN KEY (category_id) REFERENCES categories,
  CONSTRAINT us_course_fk
    FOREIGN KEY (course_id) REFERENCES courses (course_id),
  CONSTRAINT us_manager_fk
    FOREIGN KEY (manager_id) REFERENCES users (user_id)
);
/* Alter Tables */
ALTER TABLE categories
ADD (
  CONSTRAINT dept_mgr_fk
    FOREIGN KEY (manager_id)
    REFERENCES users (user_id)
);
CREATE SEQUENCE users_seq
  START WITH     207
  INCREMENT BY   1
  NOCACHE
  NOCYCLE;

/* course History */
CREATE TABLE course_history (
  user_id       NUMBER(6) CONSTRAINT    cour_user_nn  NOT NULL,
  start_date    DATE CONSTRAINT    cour_start_date_nn  NOT NULL,
  end_date      DATE CONSTRAINT    cour_end_date_nn  NOT NULL,
  course_id     VARCHAR2(10) CONSTRAINT    cour_course_nn  NOT NULL,
  category_id NUMBER(4),
  CONSTRAINT    cour_date_interval CHECK (end_date > start_date)
);
CREATE UNIQUE INDEX cour_us_id_st_date_pk
ON course_history (user_id, start_date);
ALTER TABLE course_history
ADD (
  CONSTRAINT cour_us_id_st_date_pk
    PRIMARY KEY (user_id, start_date),
  CONSTRAINT     cour_course_fk
    FOREIGN KEY (course_id) REFERENCES courses,
  CONSTRAINT     cour_us_fk
    FOREIGN KEY (user_id) REFERENCES users,
  CONSTRAINT     cour_dept_fk
    FOREIGN KEY (category_id) REFERENCES categories
);


CREATE OR REPLACE VIEW us_details_view
  (user_id,
   course_id,
   manager_id,
   category_id,
   location_id,
   county_id,
   first_name,
   last_name,
   spending,
   commission_pct,
   category_title,
   course_title,
   city,
   state_province,
   county_name,
   state_name)
AS
SELECT
  e.user_id,
  e.course_id,
  e.manager_id,
  e.category_id,
  d.location_id,
  l.county_id,
  e.first_name,
  e.last_name,
  e.spending,
  e.commission_pct,
  d.category_title,
  j.course_title,
  l.city,
  l.state_province,
  c.county_name,
  r.state_name
FROM
  users e
  INNER JOIN categories d ON e.category_id = d.category_id
  INNER JOIN courses j ON j.course_id = e.course_id
  INNER JOIN locations l ON d.location_id = l.location_id
  INNER JOIN counties c ON l.county_id = c.county_id
  INNER JOIN states r ON c.state_id = r.state_id
WITH READ ONLY;
COMMIT;
