USE adgg_uat;
SELECT 
ifnull(country.name,'undefined') as country, ifnull(farm_types.label,'undefined') as farm_type, count(farm.id) total
FROM core_farm farm
LEFT JOIN core_country country ON  farm.country_id = country.id 
LEFT JOIN core_master_list farm_types on farm.farm_type = farm_types.value AND farm_types.list_type_id = 2
GROUP BY country_id,farm_type order by 1,2;