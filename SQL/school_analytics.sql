create database school_analytics;
use school_analytics;
CREATE TABLE students (
     student_id VARCHAR(50) PRIMARY KEY,
     student_name VARCHAR(100) NOT NULL,
     gender VARCHAR(10),
     class VARCHAR(20),
     city VARCHAR(50)
);

CREATE TABLE subjects (
    subject_id VARCHAR(50) PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL
);

CREATE TABLE exams (
    exam_id VARCHAR(50) PRIMARY KEY,
    exam_name VARCHAR(100) NOT NULL,
    exam_date DATE
);

CREATE TABLE teachers (
    teacher_id VARCHAR(50) PRIMARY KEY,
    teacher_name VARCHAR(100) NOT NULL,
    subject_specialization VARCHAR(100),
    class VARCHAR(20)
);

CREATE TABLE marks (
    student_id VARCHAR(50),
    subject_id VARCHAR(50),
    exam_id VARCHAR(50),
    marks INTEGER,

    PRIMARY KEY (student_id, subject_id, exam_id),

    FOREIGN KEY (student_id)
        REFERENCES students(student_id),

    FOREIGN KEY (subject_id)
        REFERENCES subjects(subject_id),

    FOREIGN KEY (exam_id)
        REFERENCES exams(exam_id)
);

CREATE TABLE attendance (
    student_id VARCHAR(50),
    attendance_date VARCHAR(50), -- Temporarily text to safely accept "General" data
    status VARCHAR(20),
    PRIMARY KEY (student_id, attendance_date)
);

alter table marks
modify column marks int;

alter table attendance
modify column attendance_date date;

alter table exams
modify column exam_date date;

SELECT * FROM students;
SELECT * FROM subjects;
SELECT * FROM exams;
SELECT * FROM teachers;
SELECT * FROM marks;
SELECT * FROM attendance;

-- Show total number of students in the school
select count(*) as total_students
from students;

-- Find average marks of each subject
select 
s.subject_id,s.subject_name,avg(m.marks) as avg_marks
from marks m
join subjects s
on m.subject_id = s.subject_id
group by subject_id
order by avg_marks;

-- Show each student with their marks in all subjects
select st.student_name,su.subject_name,m.marks
from students st
join marks m
on m.student_id = st.student_id
join subjects su
on su.subject_id = m.subject_id
order by st.student_name,su.subject_name;

-- Find total marks obtained by each student
select 
st.student_id,st.student_name,sum(m.marks) as total_marks
from marks m
join students st
on m.student_id = st.student_id
group by st.student_id,st.student_name
order by total_marks;

-- Find the highest marks in each subject
select su.subject_id,su.subject_name,max(m.marks) as highest_marks
from marks m
join subjects su
on m.subject_id = su.subject_id
group by su.subject_id,su.subject_name
order by highest_marks desc;

-- Show students who scored more than 80 in any subject
select st.student_name,su.subject_name,m.marks
from students st
join marks m
on m.student_id = st.student_id
join subjects su
on su.subject_id = m.subject_id
where m.marks > 80
order by m.marks desc;

-- Find average marks per student
select st.student_id,st.student_name,avg(m.marks) as avg_marks
from marks m
join students st
on m.student_id = st.student_id
group by st.student_id,st.student_name
order by avg_marks desc;

-- Show subject-wise performance (average marks per subject)
select su.subject_id,su.subject_name,avg(m.marks) as avg_marks_per_subject
from marks m
join subjects su
on m.subject_id = su.subject_id
group by su.subject_id,su.subject_name
order by avg_marks_per_subject desc;

-- Find students who are failing (less than 40 marks in any subject)
select st.student_id,st.student_name,su.subject_name,m.marks 
from students st
join marks m
on st.student_id = m.student_id
join subjects su
on su.subject_id = m.subject_id
where m.marks < 40;

-- Show attendance percentage of each student
select 
st.student_id,st.student_name,round(count(case when a.status in ('Present','Late') then 1 end)*100.00/nullif(count(a.attendance_date),0),2) as attendance_percentage
from attendance a
join students st
on a.student_id = st.student_id
group by st.student_id,st.student_name
order by attendance_percentage desc;

-- Find students whose marks are above class average
select 
st.student_id,st.student_name,m.marks
from students st 
join marks m
on st.student_id = m.student_id
where m.marks > (select avg(marks)
from marks)
order by m.marks desc;

-- Show top 5 students based on total marks.
select st.student_id,st.student_name,sum(m.marks) as total_marks
from students st
join marks m
on st.student_id = m.student_id
group by st.student_id,st.student_name
order by total_marks desc
limit 5;

-- Find subjects where average marks are below 50
select su.subject_id,su.subject_name, avg(m.marks) as avg_marks
from subjects su
join marks m
on su.subject_id = m.subject_id
group by  su.subject_id,su.subject_name
having avg_marks < 50
order by avg_marks desc;

-- Rank students based on total marks (highest to lowest)
select st.student_id,st.student_name,
sum(m.marks),rank() over(order by sum(m.marks) desc) as student_rank
from students st
join marks m
on st. student_id = m.student_id
group by st.student_id,st.student_name ;

-- Show each student’s rank per subject
select su.subject_id , su.subject_name,st.student_id,st.student_name,m.marks as subject_marks,
rank() over(partition by su.subject_id order by m.marks desc)
from students st
join marks m 
on st.student_id=m.student_id
join subjects su
on su.subject_id = m.subject_id;

-- Find the difference between a student’s marks and class average (per subject)
select su.subject_id,su.subject_name,st.student_id,st.student_name,m.marks,
avg(m.marks) over(partition by su.subject_id) as avg_marks,
m.marks - avg(m.marks) over(partition by su.subject_id ) as difference_from_avg 
from students st
join marks m
on st.student_id = m.student_id
join subjects su
on su.subject_id = m.subject_id;









