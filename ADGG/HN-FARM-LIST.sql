use adgg_uat;
SELECT core_farm.country_id country_code,  core_country.name country_name,
core_farm.region_id region_code, 
(SELECT `unit`.`name`  FROM `country_units` `unit` WHERE `unit`.`id` = `core_farm`.`region_id`) AS `region_name`,
core_farm.district_id zone_code, 
  (SELECT `unit`.`name`  FROM `country_units` `unit` WHERE `unit`.`id` = `core_farm`.`district_id`) AS `zone_name`,
core_farm.ward_id ward_code, 
  (SELECT `unit`.`name`  FROM `country_units` `unit` WHERE `unit`.`id` = `core_farm`.`ward_id`) AS `ward_name`,
core_farm.village_id village_code,
   (SELECT `unit`.`name`  FROM `country_units` `unit` WHERE `unit`.`id` = `core_farm`.`village_id`) AS `village_name`,
core_farm.code farmer_code, core_farm.farmer_name farmer_firstname,farmer_othnames,
CASE
    WHEN isnull(core_farm.phone) OR core_farm.phone ='' THEN core_farm.phone    
    ELSE 
		CASE
			WHEN CHAR_LENGTH(core_farm.phone) > 12 THEN SUBSTRING(core_farm.phone, 5) 
            WHEN CHAR_LENGTH(core_farm.phone) = 12 THEN SUBSTRING(core_farm.phone, 4)
            WHEN CHAR_LENGTH(core_farm.phone) = 10 THEN SUBSTRING(core_farm.phone, 2)
            ELSE core_farm.phone
		END    
	END farmer_mobile,
core_farm.id farmer_uniqueid,core_farm.gender_code farmer_gender_code,
ifnull(core_farm.reg_date,	DATE_FORMAT(core_farm.created_at,'%Y-%m-%d')) farmer_profiledate

FROM core_farm 
LEFT JOIN core_country ON core_farm.country_id = core_country.id
WHERE country_id = 11;





