
  SELECT 
  core_animal.tag_id ,
  core_animal.name as animal_name,
  replace(JSON_UNQUOTE(JSON_EXTRACT(core_animal_event.additional_attributes, '$."221"')),'null','') AS days_in_milk,
	  	  
	  ROUND(replace(JSON_UNQUOTE(JSON_EXTRACT(core_animal_event.additional_attributes, '$."59"')),'null',''),2) AS milk_am_litres,
	  ROUND(replace(JSON_UNQUOTE(JSON_EXTRACT(core_animal_event.additional_attributes, '$."68"')),'null',''),2) AS milk_mid_day,
      ROUND(replace(JSON_UNQUOTE(JSON_EXTRACT(core_animal_event.additional_attributes, '$."61"')),'null',''),2) AS milk_pm_litres,

  replace(core_animal_event.event_date,'null','') AS milk_date
 FROM core_animal_event 
 LEFT JOIN auth_users ON core_animal_event.created_by = auth_users.ID
 LEFT JOIN core_animal on core_animal.id = core_animal_event.animal_id
 WHERE (core_animal_event.event_type = 2) AND 
 core_animal_event.uuid like '%icow%';

 



