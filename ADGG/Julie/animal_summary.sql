SELECT 
ifnull(country.name,'undefined') as country, 
ifnull(farm_types.label,'undefined') as farm_type, 
count(animal.id) total
FROM core_animal animal
LEFT JOIN  core_farm farm ON animal.farm_id  = farm.id
LEFT JOIN core_country country ON  animal.country_id = country.id 
LEFT JOIN core_master_list farm_types on farm.farm_type = farm_types.value AND farm_types.list_type_id = 2
GROUP BY animal.country_id,farm.farm_type order by 1,2;

