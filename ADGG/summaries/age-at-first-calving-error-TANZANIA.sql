use adgg_uat;
SELECT * from (
SELECT 
core_country.name country,
country_units.name region,
core_animal.tag_id,
core_animal.name as animal_name,
breeds.label main_breed,
core_animal.birthdate,
DATE_FORMAT(replace(dt.calving_date,'null',''),'%Y-%m-%d') AS calving_date,
YEAR(dt.calving_date) calving_year,
TIMESTAMPDIFF(MONTH, core_animal.birthdate, dt.calving_date) age_at_first_calving
FROM (
	SELECT
		core_animal_event.animal_id,
		min(core_animal_event.event_date) calving_date
	FROM core_animal_event
	WHERE core_animal_event.event_type = 1 AND  (core_animal_event.lactation_number =1 OR core_animal_event.lactation_number IS NULL)
	GROUP BY core_animal_event.animal_id
) dt
LEFT JOIN core_animal ON core_animal.id = dt.animal_id
LEFT JOIN core_country ON core_country.id = core_animal.country_id
LEFT JOIN core_master_list breeds on core_animal.main_breed = breeds.value AND breeds.list_type_id = 8
LEFT JOIN core_farm on core_farm.id  = core_animal.farm_id
LEFT JOIN country_units ON country_units.id = core_farm.region_id
) x where country = 'Tanzania' and (birthdate IS NULL OR age_at_first_calving <20 );