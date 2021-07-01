USE adgg_uat;
SELECT
 substring_index(`core_farm`.`farmer_name`, ' ', 1) `farmer_firstname`,  
 substring(`core_farm`.`farmer_name` from instr(`core_farm`.`farmer_name`, ' ') + 1) `farmer_othnames`,
 CASE
    WHEN isnull( `core_farm`.`phone`) OR `core_farm`.`phone` ='' THEN `core_farm`.`phone`    
    ELSE 
		CASE
			WHEN CHAR_LENGTH(`core_farm`.`phone`) > 12 THEN CONCAT('0',SUBSTRING(`core_farm`.`phone`, 5)) 
            WHEN CHAR_LENGTH(`core_farm`.`phone`) = 12 THEN CONCAT('0',SUBSTRING(`core_farm`.`phone`, 4))
            WHEN CHAR_LENGTH(`core_farm`.`phone`) = 10 THEN CONCAT('0',SUBSTRING(`core_farm`.`phone`, 2))
            ELSE `core_farm`.`phone`
		END    
	END `farmer_mobile`,
    `core_farm`.`id` `farmer_uniqueid`,
    `core_farm`.`gender_code` `farmer_gender_code`,
	ifnull(`core_farm`.`reg_date`,DATE_FORMAT(`core_farm`.`created_at`,'%Y-%m-%d')) `registration_date`
 FROM `core_farm` 
 LEFT JOIN `core_country` ON `core_farm`.`country_id` = `core_country`.	`id`
 LEFT JOIN `country_units` `region` ON `core_farm`.`region_id` = `region`.`id` 
 LEFT JOIN `country_units` `district` ON `core_farm`.`district_id` = `district`.`id`
 LEFT JOIN `country_units` `ward` ON `core_farm`.`ward_id` = `ward`.`id` 
 LEFT JOIN `country_units` `village` ON `core_farm`.`village_id` = `village`.`id` 
 WHERE core_farm.uuid like '%icow%';
 

 



