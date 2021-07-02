use adgg_uat;
SELECT
`core_animal`.`tag_id` AS `Animal_animalTagID`,
ifnull((SELECT list.label  FROM  core_master_list list WHERE ((list.list_type_id = 3) AND (list.value = `core_animal`.`sex`))),`core_animal`.`sex`) AS sex,
ifnull(`core_animal`.`reg_date`,   DATE_FORMAT(`core_animal`.`created_at`,'%Y-%m-%d') )  AS `Animal_registrationDate`, 
JSON_UNQUOTE(JSON_EXTRACT(`core_animal`.`additional_attributes`, '$."251"')) AS `Animal_purchaseCost`, 
`core_animal`.`name` AS `Animal_animalName`,  
ifnull((SELECT list.label  FROM  core_master_list list WHERE ((list.list_type_id = 8) AND (list.value = `core_animal`.`main_breed`))),`core_animal`.`main_breed`) AS main_breed, 
 `core_animal`.`birthdate` AS `Animal_dateofBirth`,  
 ifnull((SELECT list.label  FROM  core_master_list list WHERE ((list.list_type_id = 62) AND (list.value = `core_animal`.`animal_type`))),'Uncategorized') AS animalType
			
FROM `core_animal` 
LEFT JOIN core_farm  ON core_animal.farm_id = core_farm.id
WHERE `core_animal`.`country_id` = '11' and `core_animal`.`uuid` like '%icow%'