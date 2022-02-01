-- create tables for all the csv files
use kiva;

drop table if exists  `kiva`.`region_ready`;
CREATE TABLE IF NOT EXISTS `kiva`.`region_ready`(
	`region` VARCHAR(70) CHARACTER SET 'utf8' NOT NULL,
	`country` VARCHAR(40) CHARACTER SET 'utf8' NOT NULL,
	`iso` VARCHAR(3) CHARACTER SET 'utf8' NULL DEFAULT NULL,
    `lat` DECIMAL(9,6) NULL DEFAULT NULL,
    `lon` DECIMAL(9,6) NULL DEFAULT NULL,
	`world_region` VARCHAR(30) CHARACTER SET 'utf8' NULL DEFAULT NULL,
	`mpi` FLOAT NULL DEFAULT NULL,
	`currency` VARCHAR(5) CHARACTER SET 'utf8' NULL DEFAULT NULL,
	PRIMARY KEY (`region` ,`country`));
    
insert into region_ready (region,country, iso, lat, lon, world_region,
	mpi) select region,country, iso, lat, lon, world_region,
	mpi from mpi_region_locations;
    

drop table if exists `kiva`.`loan_lender_details_ready`;

CREATE TABLE IF NOT EXISTS `kiva`.`loan_lender_details_ready`(
	`posted_time` VARCHAR(30) NULL DEFAULT NULL,
    `disbursed_time` VARCHAR(30) NULL DEFAULT NULL,
	`funded_time` VARCHAR(30) NULL DEFAULT NULL,
    `term_in_months`FLOAT NULL DEFAULT NULL,
	`lender_count` INT(10) NULL DEFAULT NULL,
	`loan_date` VARCHAR(20) NULL DEFAULT NULL,
    `loan_id` INT(10) NOT NULL,
    CONSTRAINT `loan_id_fk` FOREIGN KEY (`loan_id`) REFERENCES `kiva`.`loan_ready` (`loan_id`)
-- 	ENGINE = InnoDB
-- 	DEFAULT CHARACTER SET = utf8mb4
-- 	COLLATE = utf8mb4_0900_ai_ci
);

insert into loan_lender_details_ready (posted_time, disbursed_time, funded_time,
	term_in_months, lender_count, loan_date,loan_id)
    select posted_time, disbursed_time, funded_time,
	term_in_months, lender_count, loan_date,loan_id from loan;

drop table if exists `kiva`.`loan_themes_by_region_ready`;
CREATE TABLE IF NOT EXISTS `kiva`.`loan_themes_by_region_ready`(
	`partner_id` INT(3) NOT NULL,
	`field_partner_name` VARCHAR(81) CHARACTER SET 'utf8' NULL DEFAULT NULL,
	`country` VARCHAR(40) CHARACTER SET 'utf8' NULL DEFAULT NULL,
	`forkiva` VARCHAR(5) CHARACTER SET 'utf8' NULL DEFAULT NULL,
    `loan_theme_id` VARCHAR(15),
    `location_name` VARCHAR(100),
    `amount` INT(10), 
    PRIMARY KEY  (`partner_id`, `location_name`,`loan_theme_id`, `amount`)
-- 	ENGINE = InnoDB
-- 	DEFAULT CHARACTER SET = utf8mb4
-- 	COLLATE = utf8mb4_0900_ai_ci
);

-- Error Code: 1062. Duplicate entry '386-karatina, Kenya-a1050000006ppRj-500' for key 'PRIMARY'


delete from loan_themes_by_region where partner_id = 386 and location_name='karatina, Kenya' and loan_theme_id='a1050000006ppRj';
Select * from loan_themes_by_region where partner_id = 386 and location_name='karatina, Kenya' and loan_theme_id='a1050000006ppRj';

insert into loan_themes_by_region_ready (partner_id, field_partner_name, country, forkiva,location_name,loan_theme_id,amount)
	select partner_id, field_partner_name, country , forkiva , location_name , loan_theme_id,amount from loan_themes_by_region;

drop table if exists kiva.loan_theme_ids_ready;
CREATE TABLE IF NOT EXISTS `kiva`.`loan_theme_ids_ready`(
	`loan_id` INT(10) NOT NULL,
    `loan_theme_id` VARCHAR(25) CHARACTER SET 'utf8' NULL DEFAULT NULL,
	`loan_theme_type` VARCHAR(50) CHARACTER SET 'utf8' NULL DEFAULT NULL,
	`partner_id` INT(3) NULL DEFAULT NULL,
	PRIMARY KEY (`loan_id`)-- ,
-- 	CONSTRAINT `partner_id_fk` FOREIGN KEY (`partner_id`) REFERENCES `kiva`.`loan_themes_by_region` (`partner_id`)
--     ON DELETE CASCADE
--     ON UPDATE CASCADE-- ,
-- 	ENGINE = InnoDB
-- 	DEFAULT CHARACTER SET = utf8mb4
-- 	COLLATE = utf8mb4_0900_ai_ci
);

insert into loan_theme_ids_ready ( loan_id, loan_theme_id, loan_theme_type, partner_id ) select id, loan_theme_id, loan_theme_type, partner_id  from  loan_them_ids;

drop table if exists `kiva`.`loan_ready`;
CREATE TABLE IF NOT EXISTS `kiva`.`loan_ready`(
	`loan_id` INT(10) NOT NULL,
    `funded_amount` FLOAT NULL DEFAULT NULL,
    `loan_amount` FLOAT NULL DEFAULT NULL,
	`activity` VARCHAR(35) CHARACTER SET 'utf8' NULL DEFAULT NULL,
    `partner_id` INT(3) NULL DEFAULT NULL,
    `borrower_genders` VARCHAR(400) CHARACTER SET 'utf8' NULL DEFAULT NULL,
	`repayment_interval` VARCHAR(10) CHARACTER SET 'utf8' NULL DEFAULT NULL,
	`region` VARCHAR(50) CHARACTER SET 'utf8' NULL DEFAULT NULL,
	`country` VARCHAR(40) CHARACTER SET 'utf8' NULL DEFAULT NULL,
    PRIMARY KEY (`loan_id`)
	-- CONSTRAINT `region_country_fk` FOREIGN KEY (`region`, `country`) REFERENCES `kiva`.`region_ready` (`region`, `country`)
    
	
	-- ENGINE = InnoDB
-- 	DEFAULT CHARACTER SET = utf8mb4
-- 	COLLATE = utf8mb4_0900_ai_ci
);

insert into loan_ready (loan_id, funded_amount, loan_amount, activity, partner_id, borrower_genders, repayment_interval, region, country) select 
	loan_id, funded_amount, loan_amount, activity, partner_id, borrower_genders, repayment_interval, region, country from loan;

drop table if exists `kiva`.`category_ready`;
CREATE TABLE IF NOT EXISTS `kiva`.`category_ready`(
	`sector` VARCHAR(20) CHARACTER SET 'utf8'  ,
	`loan_use` VARCHAR(800) CHARACTER SET 'utf8',
    `loan_id`INT(10) NOT NULL,
	-- PRIMARY KEY (`sector`,`loan_use`)-- ,
      CONSTRAINT `loan_id_fk1` FOREIGN KEY (`loan_id`) REFERENCES `kiva`.`loan_ready` (`loan_id`)
--     ON DELETE CASCADE
--     ON UPDATE CASCADE-- ,
-- 	ENGINE = InnoDB
-- 	DEFAULT CHARACTER SET = utf8mb4
-- 	COLLATE = utf8mb4_0900_ai_ci
);
 insert into `kiva`.`category_ready` (loan_id,sector,loan_use) select loan_id,sector,loan_use from kiva.loan;

 -- triggers and stored procedures 
drop trigger if exists checkCountry
DELIMITER $$
CREATE TRIGGER checkCountry
BEFORE INSERT ON kiva.loan_ready
FOR EACH ROW
BEGIN
IF (loan.country = 'Crimea' or loan.country = 'Cuba' or 
loan.country = 'Iran' or loan.country = 'Syria' or 
loan.country = 'North Korea' or loan.country = 'Sudan') THEN 
	signal sqlstate '51000' set message_text =  'cannot insert record as the residents of the country are restricted ';
END IF;
END;
$$
Delimiter ;
use kiva;
insert into loan_ready (loan_id, country) values ('6666', 'Poland'); 
	
DELIMITER $$
CREATE PROCEDURE loan_themes()
BEGIN 
	INSERT INTO loan_themes_by_region_ready (
    partner_id, field_partner_name, country, forkiva,location_name,loan_theme_id,amount)
	SELECT partner_id, field_partner_name, country , forkiva , location_name , 
    loan_theme_id,amount FROM loan_themes_by_region;
END $$
DELIMITER ;
call loan_themes();

DELIMITER $$
CREATE PROCEDURE region_ready()
BEGIN 
	INSERT INTO region_ready (region,country, iso, lat, lon, world_region,
	mpi) SELECT region,country, iso, lat, lon, world_region,
	mpi FROM mpi_region_locations;
END $$
DELIMITER ;

call region_ready();

DELIMITER $$
DROP TRIGGER IF EXISTS country_delete;
GO
CREATE TRIGGER country_delete 
ON kiva.loan_ready INSTEAD OF DELETE
AS BEGIN
    DECLARE @id INT;
    DECLARE @count INT;
    SELECT @id = id FROM DELETED;
    SELECT @count = COUNT(*) FROM kiva.region WHERE country = @id;
    IF @count = 0
        DELETE FROM kiva.loan WHERE country = @id;
    ELSE
        signal sqlstate '45000' set message_text =  'cannot delete - country is referenced in other tables';
END;
$$

DELIMITER $$
DROP TRIGGER IF EXISTS country_delete;
GO
CREATE TRIGGER country_delete 
ON kiva.loan_ready INSTEAD OF DELETE
AS BEGIN
    DECLARE @id INT;
    DECLARE @count INT;
    SELECT @id = id FROM DELETED;
    SELECT @count = COUNT(*) FROM kiva.region WHERE country = @id;
    IF @count = 0
        DELETE FROM kiva.loan WHERE country = @id;
    ELSE
        signal sqlstate '45000' set message_text =  'cannot delete - country is referenced in other tables';
END;
$$

delimiter;

-- stored procedures for the kiva data
DELIMITER $$
CREATE PROCEDURE load_data_into_loan()
BEGIN      
       insert into kiva.loan_ready (
		loan_id, 	
        funded_amount, 
        loan_amount, 
        activity, 
        partner_id, 
        borrower_genders, 
        repayment_interval, 
        region, 
        country) select 
		loan_id, 
        funded_amount, 
        loan_amount, 
        activity, 
        partner_id, 
        borrower_genders, 
        repayment_interval, 
        region, country 
        from kiva.loan;
END $$
DELIMITER ;

call load_data_into_loan();


DELIMITER $$
CREATE PROCEDURE load_data_into_loan_lender_details_ready()
BEGIN 
	INSERT INTO loan_lender_details_ready(posted_time, disbursed_time, 
    funded_time, term_in_months, lender_count, loan_date, loan_id)
    select posted_time, disbursed_time, funded_time,
	term_in_months, lender_count, loan_date,loan_id from loan;
END $$
DELIMITER ;

call load_data_into_loan_lender_details_ready();





DELIMITER //

CREATE PROCEDURE GetLoanDetails()
BEGIN
	SELECT *  FROM loan_ready;
END //

DELIMITER ;

call GetLoanDetails();


call Locations();




DROP PROCEDURE Locations;

-- sql code and queries

SELECT * FROM kiva.loan_ready where loan_amount between 500 and 1500;
use kiva;
select count(loan_amount),loan_amount from loan_ready group by loan_amount order by count(loan_amount) desc;

select * from kiva.region_ready where country in('Yemen','Egypt','Madagascar') order by country desc;

select * from loan_theme_ids_ready where loan_theme_type<>'General';

use kiva;
select  loan_ready.loan_id,loan_ready.partner_id,loan_ready.activity, loan_theme_ids_ready.loan_theme_type 
	from loan_ready 
    join 
	loan_theme_ids_ready on loan_ready.loan_id = loan_theme_ids_ready.loan_id 
    where loan_ready.activity like '%food%' and loan_theme_type<>'General';
    
    select count(loan_ready.activity) as cnt ,loan_ready.activity from loan_ready
		join loan_lender_details_ready
        on loan_ready.loan_id = loan_lender_details_ready.loan_id
        where loan_lender_details_ready.term_in_months>10
        group by loan_ready.activity
        having cnt>10
        order by cnt;
        
        