/*
1. Създайте процедура, всеки месец извършва превод от депозираната от клиента 
сума, с който се заплаща месечната такса. Нека процедурата получава като входни 
параметри id на клиента и сума за превод, ако преводът е успешен - третият изходен 
параметър от тип BIT да приема стойност 1, в противен случай 0.
*/
DELIMITER | 
DROP PROCEDURE IF EXISTS feePayment  |
CREATE PROCEDURE feePayment(IN clientID INT, IN sumOfPayment DOUBLE, OUT success BIT)

BEGIN 
	DECLARE contract int;
    SELECT contractID INTO contract
    FROM contracts
    WHERE customer_id = (
							SELECT customerID 
                            FROM customers 
                            WHERE customerID = clientID  );
START TRANSACTION;
UPDATE `cableCompany`.`accounts`
SET amount = amount - dueAmount
WHERE accountID = clientID AND amount >= sumOfPayment;
	IF(ROW_COUNT() = 0)
		THEN
           ROLLBACK;
           SELECT "Not enough funds in this account!" AS result;
	ELSE 
		INSERT INTO `cableCompany`.`payments`(`contract_id`, `paymentAmount`, `month`, `year`, `dateOfPayment`) 
	    VALUES (contract, MONTH(NOW()), YEAR(NOW()), `salaryAmount`, NOW()); 
 
           IF(ROW_COUNT()=0) 
		   THEN 
			   ROLLBACK; 
			   SELECT "Monthly fee payment successful!" AS result; 
		   ELSE 
			  COMMIT; 
		   SELECT "Successful payment of the monthly bill!" AS result; 
		   END IF; 
	   END IF; 
  END 
 | 
  DELIMITER ;

/*
2. Създайте процедура, която извършва плащания в системата за потребителите, 
депозирали суми. Ако някое плащане е неуспешно, трябва да се направи запис в 
таблица длъжници. Използвайте транзакция и курсор.
*/ 
DELIMITER | 
 DROP PROCEDURE IF EXISTS makePayments | 
 CREATE PROCEDURE makePayments() 
 BEGIN 
	DECLARE iterator INT; 
	DECLARE IdCustomer INT; 
	DECLARE IdPlan INT; 
	DECLARE IdAccount INT; 
	DECLARE sumOfPayment DOUBLE;
    
DECLARE result BIT; 
DECLARE finished int; 

DECLARE customerCursor CURSOR FOR 
	SELECT customerID, accountID, planID, SUM(plans.monthly_fee) 
	FROM customers JOIN accounts 
	ON customers.customerID = accounts.customer_id 
	JOIN contracts ON contracts.customer_id=customers.customerID 
	JOIN plans ON plans.planID = contracts.plan_id 
	WHERE contracts.customer_id = customers.customerID 
	GROUP BY customers.customerID; 
# DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SELECT 'SQL Exception'; 
DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1; 
SET finished = 0; 
OPEN customerCursor; 
	customer_loop: while( finished = 0) 
	DO 
	FETCH customerCursor INTO IdCustomer,IdAccount, IdPlan, sumOfPayment; 
		IF(finished = 1) 
		THEN 
		LEAVE customer_loop; 
		END IF; 
START TRANSACTION; 
	CALL feePayment(IdCustomer, sumOfPayment, result); 
	IF(result = 0) 
	THEN 
		INSERT INTO debtors(customer_id, plan_id, debt_amount) 
		VALUES (IdCustomer, IdPlan, sumOfPayment) 
		ON DUPLICATE KEY UPDATE 
		debt_amount = debt_amount + sumOfPayment; 
	END IF; 
	COMMIT; 
	END WHILE; 
	CLOSE customerCursor; 
	SET finished = 0; 
	SELECT 'Finished!'; 
	END; 
	| 
DELIMITER ; 
 
CALL makePayments(); 

/*
3. Създайте event, който се изпълнява на 28-я ден от всеки месец и извиква втората 
процедура.
*/
CREATE EVENT monthly_payments 
ON SCHEDULE EVERY 1 MONTH 
STARTS TIMESTAMP '2013-05-27 00:00:00' 
DO CALL processPayments();

-- =======================================================================================
-- =======================================================================================
/*
4. Създайте VIEW, което да носи информация за трите имена на клиентите, дата на 
подписване на договор, план, дължимите суми.
*/
-- by Ivan
USE cablecompany;
CREATE VIEW contracts AS
SELECT customers.firstName, customers.middleName, customers.lastName, 
 contracts.contractDate,   plan.name, plan.monthly_fee
FROM payments
JOIN contracts ON payments.contract_id = contactID
JOIN customers ON contracts.customer_id = customerID
JOIN accounts ON customersID = accounts.customer_id;

/*
5. Създайте тригер, който при добавяне на нов план, проверява дали въведената 
такса е по-малка от 10 лева. Ако е по-малка, то добавянето се прекратява, ако не, 
то се осъществява.
- Create a trigger that, when adding a new plan, checks whether the entered one
the fee is less than BGN 10. If it is smaller, the addition is stopped, if not,
it takes place.
*/

DELIMITER $$
CREATE TRIGGER  add_newPlan.plan_fee -- trigger_tutorial.trigger_item_before_insert
BEFORE INSERT
ON add_newPlan.plan_addition -- trigger_tutorial.item_inventory 
FOR EACH ROW
BEGIN
IF new.price < 10.00
THEN SET new.price = 0.00 * new.price;
END IF;
END $$ 
DELIMITER ; 

/*
6. Създайте тригер, който при добавяне на сума в клиентска сметка проверява дали 
не е въведена отрицателна сума. Ако е по-малка, то добавянето се прекратява, ако 
не, то се осъществява.
*/
-- by Ivan
USE cablecompany
DELIMITER //
CREATE TRIGGER before_accounts_insert BEFORE INSERT ON accounts
FOR EACH ROW
BEGIN
IF (NEW.amount < 0) THEN SET NEW.amount = 0; END IF;
END //
DELIMITER ;

/*
7. Създайте процедура, която при подадени имена на клиент извежда всички данни 
за клиента, както и извършените плащания.
------------------------------------------------------------------------------
CREATE PROCEDURE 
 BY name of client receive all data of client and payments 
*/


DELIMITER $$
CREATE PROCEDURE all_GetClientInfo()
BEGIN
   -- select  clients.client_egn , clients.client_iban ,clients.client_name, clients.client_middleName, clients.clint_surname,
   -- clients.client_address, clients.client_phone , clients.client_taxpayments from clients
    SELECT * from accounts 
    JOIN customerID ON
    customers.customerId = accounts.accountID
     order by client_names;
END $$
    
DELIMITER ;




