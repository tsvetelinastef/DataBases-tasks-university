
-- 1. Изведете имената, класовете и телефоните на всички ученици, които тренират футбол.
SELECT students.name, students.class, students.phone
FROM students JOIN sports ON 
students.id in (
	SELECT student_id FROM student_sport
    WHERE sportGroup_id in(
		SELECT id FROM sportGroups
        WHERE sportGroups.sport_id = sports.id
    )
)
WHERE sports.name = 'Football';


-- 2. Изведете имената на всички треньори по волейбол.
SELECT coaches.name FROM coaches JOIN sports ON coaches.id in(
	SELECT coach_id FROM sportGroups
    WHERE sport_id = sports.id  AND sports.name = 'Volleyball'
);


-- 3. Изведете името на треньора и спорта, който тренира ученик с име Илиян Иванов.
SELECT coaches.name, sports.name
FROM coaches JOIN sportGroups ON coaches.id = sportGroups.coach_id
JOIN sports ON sportGroups.sport_id = sports.id
JOIN student_sport ON student_sport.sportGroup_id = sportGroups.id
JOIN students ON student_sport.student_id = students.id
WHERE students.name = 'Iliyan Ivanov';


-- 4. Изведете сумите от платените през годините такси на учениците по месеци, но само за
-- ученици с такси по месеци над 700 лева и с треньор с ЕГН 7509041245.
SELECT  taxesPayments.year, taxespayments.month, SUM(paymentAmount) FROM students
 JOIN taxesPayments ON taxesPayments.student_id = students.id
 JOIN student_sport ON students.id=student_sport.student_id
 JOIN sportGroups ON sportGroups.id= student_sport.sportGroup_id
 JOIN coaches ON coaches.id= sportGroups.coach_id
 WHERE coaches.egn = '7509041245'
 group by taxesPayments.year, taxespayments.month
 having ( SUM(paymentAmount) > 700)
 order by students.name desc, taxesPayments.year desc;
 
 
 -- 5. Изведете броя на студентите във всяка една от групите.
SELECT COUNT(student_id), sportGroup_id
FROM student_sport
group by sportGroup_id;


-- 6. Определете двойки ученици на базата на спортната група, в която тренират, като
-- двойките не се повтарят. В двойките да участват само ученици, трениращи футбол.
-- Учениците от една двойка трябва да тренират в една и съща група.
SELECT stud1.name AS FirstStudent, stud2.name AS SecondStudent, sports.name
FROM students AS  stud1 JOIN students AS stud2 
ON stud1.id > stud2.id
JOIN student_sport ON stud1.id = student_sport.student_id
JOIN sportGroups ON student_sport.sportGroup_id = sportGroups.id
JOIN sports ON sportGroups.sport_id = sports.id
WHERE stud1.id in(
	SELECT student_id FROM student_sport
    WHERE student_sport.sportGroup_id
    in(
		SELECT sportGroup_id FROM student_sport
        WHERE student_id = stud2.id
    )
)

ORDER BY sports.name;



-- 7. Изведете имената на учениците, класовете им, местата на тренировки и името на
-- треньорите за тези ученици, чийто тренировки започват в 8.00 часа. Създайте виртуална
-- таблица с този селект.
CREATE view studs(name, class, place, coachName) AS
SELECT students.name, students.class, sportGroups.location, coaches.name 
 FROM students JOIN student_sport ON students.id = student_sport.student_id
 JOIN sportGroups on student_sport.sportGroup_id = sportGroups.id
 JOIN coaches ON sportGroups.coach_id = coaches.id
 JOIN sports ON sportGroups.sport_id = sports.id
 WHERE sportGroups.hourOfTraining = '8:00';
 
 
 -- 8. Използвайте базата данни transaction_test. Създайте трансакция, с която прехвърляте 50000 лв. от сметката в лева на 
 -- Stoyan Pavlov Pavlov в сметката в лева на Ivan Petrov Iordanov
-- при подадени само име на титуляр и вид валута.
 use transaction_test;
begin;
UPDATE customer_accounts JOIN customers ON cusomer_accounts.id = customers.id
SET amount = amount - 50000 
WHERE customers.name = 'Stoyan Pavlov Pavlov' AND currency = 'BGN';

UPDATE customer_accounts JOIN customers ON cusomer_accounts.id = customers.id
SET amount = amount + 50000 
WHERE customers.name = 'Ivan Petrov Iordanov' AND currency = 'BGN';
commit;
