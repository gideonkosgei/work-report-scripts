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
	null as colours_count,
	JSON_UNQUOTE(JSON_EXTRACT(`core_animal`.`additional_attributes`, '$."254"')) AS `animal_color_code1`,
	null AS `animal_color_code2`,		
	null as animal_color_code3,
    null animal_color_desc1,
    null  animal_color_desc2,		
	null animal_color_desc3,
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
 WHERE  (`core_animal`.`country_id` = '11') LIMIT 100;
 


