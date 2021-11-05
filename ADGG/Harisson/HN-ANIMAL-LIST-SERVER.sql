SELECT 
concat_ws('',ifnull(activities_country,'null'), ',', ifnull(country_name,'null'), ',',ifnull(activities_region,'null'), ',',ifnull(region_name,'null'), ',',ifnull(activities_zone,'null'), ',',ifnull(zone_name,'null'), ',',ifnull(ward_code,'null'), ',',ifnull(ward_name,'null'), ',',ifnull(village_code,'null'), ',',ifnull(village_name,'null'), ',',ifnull(farmer_code,'null'), ',',ifnull(farmer_firstname,'null'), ',',ifnull(farmer_othnames,'null'), ',',ifnull(farmer_name,'null'), ',',ifnull(farmer_uniqueid,'null'), ',',ifnull(farmer_mobile,'null'), ',',ifnull(farmer_farmtype_des,'null'), ',',ifnull(animal_code,'null'), ',',ifnull(animal_actualtagid,'null'), ',',ifnull(animal_name,'null'), ',',ifnull(animal_regdate,'null'), ',',ifnull(animal_actualdob,'null'), ',',ifnull(animal_type_code_registration,'null'), ',',ifnull(animal_type_des_registration,'null'), ',',ifnull(animal_current_type_code,'null'), ',',ifnull(animal_current_type_des,'null'), ',',ifnull(animal_group_code,'null'), ',',ifnull(animal_group_name,'null')) 
AS 'activities_country,country_name,activities_region,region_name,activities_zone,zone_name,ward_code,ward_name,village_code,village_name,farmer_code,farmer_firstname,farmer_othnames,farmer_name,farmer_uniqueid,farmer_mobile,farmer_farmtype_des,animal_code,animal_actualtagid,animal_name,animal_regdate,animal_actualdob,animal_type_code_registration,animal_type_des_registration,animal_current_type_code,animal_current_type_des,animal_group_code,animal_group_name' 
FROM (
SELECT
 `core_country`.`code` `activities_country`, 
 `core_country`.`name` AS `country_name`, 
 `region`.`code` AS `activities_region`,
 `region`.`name` AS `region_name`,
 `district`.`code` AS `activities_zone`,
 `district`.`name` AS `zone_name`, 
 `ward`.`code` AS `ward_code`, 
 `ward`.`name` AS `ward_name`,
 `village`.`code` AS `village_code`, 
 `village`.`name` AS `village_name`, 
 `core_animal`.`farm_id` AS `farmer_code`,
 substring_index(`core_farm`.`farmer_name`, ' ', 1) `farmer_firstname`,  
 substring(`core_farm`.`farmer_name` from instr(`core_farm`.`farmer_name`, ' ') + 1) `farmer_othnames`,
 `core_farm`.`farmer_name` AS `farmer_name`,
 `core_farm`.`id` AS `farmer_uniqueid`,
 
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
   `core_farm`.`farm_type` AS `farmer_farmtype_des`, 
   `core_animal`.`id` AS `animal_code`,   	
   `core_animal`.`tag_id` AS `animal_actualtagid`,   
   `core_animal`.`name` AS `animal_name`, 	
	ifnull(`core_animal`.`reg_date`,DATE_FORMAT(`core_animal`.`created_at`,'%Y-%m-%d')) `animal_regdate`,
	`core_animal`.`birthdate` AS `animal_actualdob`,
    `core_animal`.`animal_type` AS `animal_type_code_registration`,
      anim_type.label AS animal_type_des_registration,	
	 `core_animal`.`animal_type` AS `animal_current_type_code`,
	  anim_type.label AS animal_current_type_des,
	 NULL animal_group_code	,
	 NULL animal_group_name   
  
 FROM `core_animal` 
 LEFT JOIN `core_farm` ON `core_animal`.`farm_id` = `core_farm`.`id`
 LEFT JOIN `core_country` ON `core_animal`.`country_id` = `core_country`.`id`
 LEFT JOIN `country_units` `region` ON `core_animal`.`region_id` = `region`.`id` 
 LEFT JOIN `country_units` `district` ON `core_animal`.`district_id` = `district`.`id`
 LEFT JOIN `country_units` `ward` ON `core_animal`.`ward_id` = `ward`.`id` 
 LEFT JOIN `country_units` `village` ON `core_animal`.`village_id` = `village`.`id`
 LEFT JOIN core_master_list anim_type on core_animal.animal_type = anim_type.value AND anim_type.list_type_id = 62
 LEFT JOIN core_master_list colors on core_animal.animal_type = colors.value AND colors.list_type_id = 83
 WHERE  (`core_animal`.`country_id` = '11')) x;
 


