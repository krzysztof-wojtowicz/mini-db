-- Tworzenie bazy danych edu_courses
CREATE DATABASE edu_courses;
GO

USE edu_courses;
GO

-- Tworzenie tabeli users_user
CREATE TABLE users_user (
                            user_id INT IDENTITY(1,1) NOT NULL,
                            email NVARCHAR(255) NOT NULL,
                            first_name NVARCHAR(200) NOT NULL,
                            last_name NVARCHAR(200) NOT NULL,
                            is_active BIT NOT NULL,
                            age INT,
                            CONSTRAINT PK_users_user PRIMARY KEY (user_id)
);

-- Tworzenie tabeli course
CREATE TABLE course (
                        course_id INT IDENTITY(1,1) NOT NULL,
                        course_name NVARCHAR(100) NOT NULL,
                        base_price MONEY NOT NULL,
                        planned_groups_amount INT DEFAULT 1,
                        date_start DATE,
                        date_end DATE,
                        is_active BIT DEFAULT 1,
                        CONSTRAINT PK_course PRIMARY KEY (course_id)
);

-- Tworzenie tabeli group (wymaga nawiasow kwadratowych bo to slowo kluczowe)
CREATE TABLE [group] (
                         group_id INT IDENTITY(1,1) NOT NULL,
                         group_type NVARCHAR(25) DEFAULT 'zajeciowa',
                         course_id INT NOT NULL,
                         max_group_capacity INT,
                         CONSTRAINT PK_group PRIMARY KEY (group_id),
                         CONSTRAINT FK_group_course FOREIGN KEY (course_id) REFERENCES course(course_id)
);

-- Tworzenie tabeli group_timetable
CREATE TABLE group_timetable (
                                 group_id INT NOT NULL,
                                 room NVARCHAR(10),
                                 datetime_start DATETIME,
                                 datetime_end DATETIME,
                                 CONSTRAINT FK_timetable_group FOREIGN KEY (group_id) REFERENCES [group](group_id)
);

-- Tworzenie tabeli course_enrollment
CREATE TABLE course_enrollment (
                                   user_id INT NOT NULL,
                                   group_id INT NOT NULL,
                                   enrollment_date DATETIME,
                                   total_cost MONEY,
                                   discount_type VARCHAR(100) DEFAULT 'bezwarunkowy',
                                   discount_value MONEY,
                                   is_completed BIT DEFAULT 0,
                                   is_dropped BIT DEFAULT 0,
                                   CONSTRAINT PK_course_enrollment PRIMARY KEY (user_id, group_id),
                                   CONSTRAINT FK_enrollment_user FOREIGN KEY (user_id) REFERENCES users_user(user_id),
                                   CONSTRAINT FK_enrollment_group FOREIGN KEY (group_id) REFERENCES [group](group_id)
);