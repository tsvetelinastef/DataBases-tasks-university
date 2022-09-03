(select s.name Sport, sg.location as Place from sports as s
left join sportGroups as sg on s.id = sg.sport_id)
union
(select sports.name, sportGroups.location from sports
right join sportGroups on sports.id = sportGroups.sport_id);

select firstStud.name as Student1, secondStud.name as Student2, sports.name as Sport
from students as firstStud join students as secondStud 
on firstStud.id < secondStud.id
join sports on (firstStud.id in (select student_id from student_sport where sportGroup_id in
(select id from sportGroups where sportGroups.sport_id = sports.id)
and
(secondStud.id in (select student_id from student_sport where sportGroup_id in
(select id from sportGroups where sportGroups.sport_id = sport.id)))))

where firstStud.id in (select student_id from student_sport where sportGroup_id in
(select sportGroup_id from student_sport where student_id = secondStud.id))
order by sport;

select group_id , sum(paymentAmount) as payment
from taxesPayments
group by group_id
having payment > 11000;

INSERT INTO students(name, egn, address, phone, class)
VALUES ('Ivan Ivanov Ivanov', '9207186371', 'Sofia-Serdika', '0888892950', '10');

select * from students
order by students.name;

delete from students where students.egn = 9207186371;

select students.name, sports.name from students
join student_sport on student.id = student_sport.student_id
join sportGroups on student_sport.sportGroup_id = sportgroups.id
join sports on sportgroups.sport_id = sport_id;

select students.name, student_sport.sportGroup_id from students join student_sport 
on students.id = student_sport.student_id;

select cocaches.name from coaches 
join sportgroups on coaches.id = sportgroups.coach_id
join sports on sport.name = "volleyball";

select location, hourOfTraining, dayofweek from sportGroups
where sport_id = 2;  
