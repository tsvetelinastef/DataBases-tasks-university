-- 1. Създайте процедура, с която по подадено име на треньор се
-- извеждат името на спорта, мястото, часът и денят на тренировка,
-- както и имената и телефоните на учениците, които тренират.

#drop procedure if exists getSportInfo;
DELIMITER |
CREATE procedure getSportInfo(IN coachName varchar(255))
BEGIN
SELECT sports.name as sportName, sportGroups.location, sportGroups.dayOfWeek, sportGroups.hourOfTraining, students.name as studentName, students.phone
FROM sports JOIN sportGroups
ON sports.id = sportGroups.sport_id JOIN student_sport
ON sportGroups.id = student_sport.sportGroup_id JOIN students
ON student_sport.student_id = students.id JOIN coaches
ON sportGroups.coach_id = coaches.id
WHERE coaches.name = coachName;
END;
|
DELIMITER ;

CALL getSportInfo('Georgi Todorov Iordanov');


-- 2
-- 2. Създайте процедура, с която по подадено id на спорт се
-- извеждат: името на спорта, имената на учениците, които тренират
-- и имената на треньорите, които водят тренировките по този спорт.
#DROP procedure if exists getSportInfoByGivenSportId;
DELIMITER |
CREATE procedure getSportInfoByGivenSportId(IN sportId int)
BEGIN
SELECT sports.name as sportName, students.name as studentName, coaches.name as coachName FROM sports JOIN sportGroups
ON  sports.id = sportGroups.sport_id JOIN coaches ON sportGroups.coach_id = coaches.id JOIN student_sport
ON sportGroups.id = student_sport.sportGroup_id JOIN students ON student_sport.student_id = students.id
WHERE  sports.id = sportId;
END;
|
DELIMITER ; 

CALL getSportInfoByGivenSportId(1);

-- 3
-- 3. Създайте процедура, която по подадено име на студент и година
-- извежда средната сума на платените от него такси.
USE school_sport_clubs;
DROP procedure if exists getSportInfoByGivenStudentNameAndYear;
DELIMITER |
Create procedure getSportInfoByGivenStudentNameAndYear(In studentName VARCHAR(255), IN year int)
BEGIN
SELECT students.name as studentName, avg(taxesPayments.paymentAmount) FROM students  JOIN taxesPayments
ON students.id = taxesPayments.student_id WHERE taxesPayments.year = year
AND students.name = studentName;
END;
|
DELIMITER ; 

SELECT students.name as studentName , avg(taxesPayments.paymentAmount)

CALL getSportInfoByGivenStudentNameAndYear('Ivan Ivanov Todorov', 2021) ;

-- 4
-- 4. Използвайте базата данни transaction_test. Създайте процедура за прехвърляне на пари от една сметка в друга. Нека процедурата
-- да извежда съобщение за грешка ако няма достатъчно пари, за да се осъществи успешно трансакцията или ако трансакцията е
-- неуспешна. За целта може да използвате функцията ROW_COUNT() която връща броя на засегнатите редове след последната Update
-- или Delete заявка. Процедурата да получава като параметри ID на сметката от която се прехвърля, ID на сметката на получателя и
-- сумата, която трябва да се преведе.
USE transaction_test;
DELIMITER $
DROP procedure if exists moneyTransfer $
CREATE procedure moneyTransfer(IN accountId1 int, IN accountId2 int, IN money int)
BEGIN

start transaction;
	UPDATE customer_accounts set customer_accounts.amount = customer_accounts.amount - money
    WHERE customer_accounts.id = accountId1;
	UPDATE customer_accounts set customer_accounts.amount = customer_accounts.amount + money
    UPDATE ----
    WHERE customer_accounts.id = accountId2;
    if 
    (
		row_count() = 0
    )
    then
    SELECT "Error";
	rollback;
    END IF;

END $
DELIMITER ;

CALL moneyTransfer(1, 2, 500);

-- =====================================================================================================================


