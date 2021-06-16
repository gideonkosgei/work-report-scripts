
DELIMITER $$
CREATE  PROCEDURE `sp_rpt_overall_summaries`(_rpt_code int,_date_form date, _date_to date)
BEGIN 
	/*
		 code	report name
        ----	--------------
        1      Animal registration 
        2	   Cow monitoring -> Daily Milk yield
        3	   Cow monitoring -> Milk Quality Parameters -> Milk fat
        4	   Cow monitoring -> Milk Quality Parameters -> Milk protein
        5	   Cow monitoring -> Milk Quality Parameters -> Milk somatic cell count
        6	   Cow monitoring -> Milk Quality Parameters -> Milk urea
		7	   Cow monitoring -> Milk Quality Parameters -> Milk lactose
		8	   Cow monitoring -> weight 
        9 	   Cow monitoring -> Health 
        10 	   Calf Monitoring -> weight 
        11 	   Calf Monitoring -> Health 
        12	   Exit records 
        13	   Artificial insemination 
        14     Pregnancy diagnosis 
        15     synchronization 
        16 	   Still births / abortions      
	*/
    
    SET @uuid = uuid();
	SET @sql = NULL;
	SET @rpt_name =  null; 
    SET @event_type =  null;
    SET @animal_type =  null;    
    
    /* Handle invalid report codes */
    IF _rpt_code NOT IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16) THEN
		SELECT 'Report Code Does Not Exists' as message;
    END IF;
    
    CASE _rpt_code     
	   WHEN 1 THEN		   
		   SET @rpt_name =  'Animal registration'; 
	   WHEN 2 THEN
		   SET @event_type = 2;
		   SET @rpt_name =  'Cow monitoring -> Daily Milk yield';
	   WHEN 3 THEN
			SET @event_type = 2;
			SET @rpt_name =  ' Cow monitoring -> Milk Quality Parameters -> Milk fat';
	   WHEN 4 THEN
			SET @event_type = 2;
			SET @rpt_name =  'Cow monitoring -> Milk Quality Parameters -> Milk protein'; 
	   WHEN 5 THEN
			SET @event_type = 2;
			SET @rpt_name =  'Cow monitoring -> Milk Quality Parameters -> Milk somatic cell count'; 
	   WHEN 6 THEN
			SET @event_type = 2;
			SET @rpt_name =  'Cow monitoring -> Milk Quality Parameters -> Milk urea'; 
	   WHEN 7 THEN
			SET @event_type = 2;
			SET @rpt_name =  'Cow monitoring -> Milk Quality Parameters -> Milk lactose';  
       WHEN 8 THEN
			SET @event_type = 6;
			SET @rpt_name =  'Cow monitoring -> weight';           
       WHEN 9 THEN			
			SET @rpt_name =  'Cow monitoring -> Health';			
	   WHEN 10 THEN
			SET @event_type = 6;
			SET @rpt_name =  'Calf Monitoring -> weight';
	  WHEN 11 THEN			
			SET @rpt_name =  'Calf Monitoring -> health';
	  WHEN 12 THEN
		   SET @event_type = 9;
		   SET @rpt_name =  'Exit records'; 	
	  WHEN 13 THEN
		   SET @event_type = 3;
		   SET @rpt_name =  'Artificial insemination';     
	  WHEN 14 THEN
		   SET @event_type = 4;
		   SET @rpt_name =  'Pregnancy diagnosis'; 
	  WHEN 15 THEN
		   SET @event_type = 5;
		   SET @rpt_name =  'synchronization';
	  WHEN 16 THEN
		 SET @event_type = 1;
		 SET @rpt_name =  'Still births / abortions';            
	ELSE
		   SET @event_type = 2;
		   SET @rpt_name =  'Cow monitoring -> Daily Milk yield';                
	END CASE;
	    
	CREATE  TEMPORARY  TABLE  IF NOT EXISTS temp_animal_stats (
		country_id int,
		report_code int,
		report_name varchar(250),            
		country varchar(250), 
		animal_type_id int,
		animal_type varchar(250), 			
		sub_total int,
		grand_total int,
		uuid varchar(200)
	); 
   
    CREATE  TEMPORARY  TABLE  IF NOT EXISTS temp_animal_stats_raw (
		country_id int,
        report_code int,
		report_name varchar(250),            
		country varchar(250), 
		animal_id int,
        farm_id int,
		param_value decimal,			
		uuid varchar(200)
	); 
         
	CREATE  TEMPORARY  TABLE  IF NOT EXISTS temp_country_totals (
		country_id int,           
		grand_total int,
		uuid varchar(200)
	);        
	
	CREATE  TEMPORARY  TABLE  IF NOT EXISTS temp_farm_count (
		country_id int,          
		grand_total int,
		uuid varchar(200)
	); 
	
    CREATE  TEMPORARY  TABLE  IF NOT EXISTS temp_animal_count (
		country_id int,          
		grand_total int,
		uuid varchar(200)
	); 
	
    CREATE  TEMPORARY  TABLE  IF NOT EXISTS temp_animal_event_stats (
			country_id int,
			report_code int,
            report_name varchar(250),            
            country varchar(250), 
            event_type_id int,
			event_type varchar(250),
            farm_total int, 			
            sub_total int,
            grand_total int,
			uuid varchar(200)
		); 
     	
    IF _rpt_code IN(1,12,16) THEN   
      
        IF _rpt_code = 1 THEN
        
			INSERT INTO temp_animal_stats(country_id,report_code,report_name,country,animal_type_id, animal_type, sub_total, uuid)
			SELECT anim.country_id,_rpt_code,@rpt_name,cnt.name country, anim.animal_type animal_type_id, REPLACE(lst.label," ","_") animal_type, ifnull(count(anim.id),0) sub_total, @uuid
			FROM core_animal anim
			LEFT JOIN core_master_list lst ON  anim.animal_type = lst.value AND lst.list_type_id = 62
			LEFT JOIN core_country cnt ON anim.country_id = cnt.id
			WHERE anim.reg_date BETWEEN _date_form AND _date_to
			GROUP BY anim.country_id, anim.animal_type ;
            
			INSERT INTO temp_farm_count (country_id,grand_total,uuid) 
            SELECT a.country_id,count(a.farm_id),@uuid FROM (             
				SELECT distinct animal.country_id, animal.farm_id							
				FROM core_animal animal 
				WHERE reg_date BETWEEN _date_form AND _date_to
            ) a GROUP BY a.country_id;  
        
        END IF;
        
        IF _rpt_code = 12 THEN
			
			INSERT INTO temp_animal_stats(country_id,report_code,report_name,country,animal_type_id, animal_type, sub_total, uuid)
			SELECT anim.country_id,_rpt_code,@rpt_name,cnt.name country, anim.animal_type animal_type_id, REPLACE(lst.label," ","_") animal_type, ifnull(count(evnt.animal_id),0) sub_total, @uuid
			FROM core_animal_event  evnt
            LEFT JOIN core_animal anim ON evnt.animal_id = anim.id
			LEFT JOIN core_master_list lst ON  anim.animal_type = lst.value AND lst.list_type_id = 62
			LEFT JOIN core_country cnt ON anim.country_id = cnt.id
			WHERE evnt.event_type = @event_type AND evnt.event_date BETWEEN _date_form AND _date_to 
			GROUP BY anim.country_id, anim.animal_type ;
            
            INSERT INTO temp_farm_count (country_id,grand_total,uuid) 
            SELECT a.country_id,count(a.farm_id),@uuid FROM (             
				SELECT distinct animal.country_id, animal.farm_id
				FROM core_animal_event evnt				
				LEFT JOIN core_animal animal on evnt.animal_id  = animal.id
				WHERE evnt.event_type = @event_type AND evnt.event_date BETWEEN _date_form AND _date_to
            ) a GROUP BY a.country_id; 
            
        END IF;
        
		IF _rpt_code = 16 THEN
			
			INSERT INTO temp_animal_stats(country_id,report_code,report_name,country,animal_type_id, animal_type, sub_total, uuid)
			SELECT anim.country_id,_rpt_code,@rpt_name,cnt.name country, anim.animal_type animal_type_id, REPLACE(lst.label," ","_") animal_type, ifnull(count(evnt.animal_id),0) sub_total, @uuid
			FROM core_animal_event  evnt
            LEFT JOIN core_animal anim ON evnt.animal_id = anim.id
			LEFT JOIN core_master_list lst ON  anim.animal_type = lst.value
			LEFT JOIN core_country cnt ON anim.country_id = cnt.id
			WHERE 
				lst.list_type_id = 62 AND 
                evnt.event_type = @event_type AND
                JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."16"')) IN (3,4) AND
				evnt.event_date BETWEEN _date_form AND _date_to 				
			GROUP BY anim.country_id, anim.animal_type ;
            
            INSERT INTO temp_farm_count (country_id,grand_total,uuid) 
            SELECT a.country_id,count(a.farm_id),@uuid FROM (             
				SELECT distinct animal.country_id, animal.farm_id
				FROM core_animal_event evnt				
				LEFT JOIN core_animal animal on evnt.animal_id  = animal.id
				WHERE evnt.event_type = @event_type AND 
                JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."69"')) IN (3,4) AND
                evnt.event_date BETWEEN _date_form AND _date_to
            ) a GROUP BY a.country_id;             
        END IF; 
        
		IF EXISTS (SELECT * FROM temp_animal_stats WHERE uuid = @uuid) THEN
        
			INSERT INTO temp_country_totals(country_id,grand_total,uuid)
			SELECT country_id, sum(sub_total),uuid 
			FROM temp_animal_stats WHERE uuid =  @uuid		   
			GROUP BY country_id;
			
			UPDATE temp_animal_stats
			INNER JOIN temp_country_totals       
			ON temp_animal_stats.country_id = temp_country_totals.country_id   AND temp_animal_stats.uuid = temp_country_totals.uuid
			SET temp_animal_stats.grand_total = temp_country_totals.grand_total
            WHERE temp_animal_stats.uuid = @uuid AND temp_country_totals.uuid = @uuid;
						
			SELECT
			  GROUP_CONCAT(DISTINCT CONCAT("max(case when animal_type = '",animal_type,"' then sub_total end) ",animal_type)) 		
			  INTO @sql 
			FROM  temp_animal_stats WHERE uuid = @uuid;         
			
			SET @sql = CONCAT("
			SELECT stats.report_code,stats.report_name,stats.country Country, farms.grand_total Farms, ", @sql,",stats.grand_total Total_Animals
			FROM temp_animal_stats stats
			LEFT JOIN temp_farm_count farms ON stats.country_id = farms.country_id  AND farms.uuid ='", @uuid,"'	
			WHERE stats.uuid ='", @uuid,"'  GROUP BY stats.country_id
			");         
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;            
			
			DELETE FROM temp_animal_stats WHERE uuid = @uuid;
			DELETE FROM temp_country_totals WHERE uuid = @uuid; 
            DELETE FROM temp_farm_count WHERE uuid = @uuid; 
            
        ELSE
            IF _rpt_code IN (1,12) THEN
				SELECT _rpt_code report_code, @rpt_name report, null Country, null Farms, null Bull, null Cow, null Female_Calf,null heifer,null Male_calf, null Total_Animals;
		    ELSE
				SELECT _rpt_code report_code, @rpt_name report , null Country, null Farms, null Cow, null Total_Animals;
            END IF;
        END IF;        
    
    END IF;
             
    IF _rpt_code IN(9,11) THEN   
      		
        IF _rpt_code = 9 THEN			
			INSERT INTO temp_animal_event_stats(country_id,report_code,report_name,country,event_type_id, event_type, sub_total, uuid)
			SELECT 
				evnt.country_id, 
				_rpt_code, 
				@rpt_name, 
				cnt.name country, 
				evnt.event_type, 
				CASE 
					WHEN evnt.event_type = 12 THEN "Vaccination" 
					WHEN evnt.event_type = 13 THEN "Parasite_Infection"
					WHEN evnt.event_type = 14 THEN "Injury"
				END,
                ifnull(count(evnt.animal_id),0),
				@uuid
			FROM core_animal_event evnt	
            LEFT JOIN core_animal anim ON evnt.animal_id = anim.id
			LEFT JOIN core_country cnt ON evnt.country_id = cnt.id
			WHERE evnt.event_type IN (12,13,14) AND anim.animal_type IN (1,2,5) AND evnt.event_date BETWEEN _date_form AND _date_to
			GROUP BY evnt.country_id, evnt.event_type ;
                        
            INSERT INTO temp_farm_count (country_id,grand_total,uuid)
            SELECT a.country_id,count(a.farm_id),@uuid FROM (             
				SELECT distinct animal.country_id, animal.farm_id
				FROM core_animal_event evnt				
				LEFT JOIN core_animal animal on evnt.animal_id  = animal.id
				WHERE evnt.event_type IN (12,13,14) AND animal.animal_type IN (1,2,5) AND evnt.event_date BETWEEN _date_form AND _date_to
            ) a GROUP BY a.country_id;           
           
        END IF;
        
        IF _rpt_code = 11 THEN			
			INSERT INTO temp_animal_event_stats(country_id,report_code,report_name,country,event_type_id, event_type, sub_total, uuid)
			SELECT 
				evnt.country_id, 
				_rpt_code, 
				@rpt_name, 
				cnt.name country, 
				evnt.event_type, 
				CASE 
					WHEN evnt.event_type = 12 THEN "Vaccination" 
					WHEN evnt.event_type = 13 THEN "Parasite_Infection"
					WHEN evnt.event_type = 14 THEN "Injury"
				END,
                ifnull(count(evnt.animal_id),0),
				@uuid
			FROM core_animal_event evnt	
            LEFT JOIN core_animal anim ON evnt.animal_id = anim.id
			LEFT JOIN core_country cnt ON evnt.country_id = cnt.id
			WHERE evnt.event_type IN (12,13,14) AND anim.animal_type IN (3,4) AND evnt.event_date BETWEEN _date_form AND _date_to
			GROUP BY evnt.country_id, evnt.event_type ;
                        
            INSERT INTO temp_farm_count (country_id,grand_total,uuid)
            SELECT a.country_id,count(a.farm_id),@uuid FROM (             
				SELECT distinct animal.country_id, animal.farm_id
				FROM core_animal_event evnt				
				LEFT JOIN core_animal animal on evnt.animal_id  = animal.id
				WHERE evnt.event_type IN (12,13,14) AND animal.animal_type IN (3,4) AND evnt.event_date BETWEEN _date_form AND _date_to
            ) a GROUP BY a.country_id;           
           
        END IF;
               
		IF EXISTS (SELECT * FROM temp_animal_event_stats WHERE uuid =@uuid) THEN
        
			INSERT INTO temp_country_totals(country_id,grand_total,uuid)
			SELECT country_id, sum(sub_total),uuid 
			FROM temp_animal_event_stats WHERE uuid =  @uuid		   
			GROUP BY country_id;
			
			UPDATE temp_animal_event_stats
			LEFT JOIN temp_country_totals            
			ON temp_animal_event_stats.country_id = temp_country_totals.country_id AND temp_animal_event_stats.uuid = @uuid
            LEFT JOIN temp_farm_count 
            ON  temp_animal_event_stats.country_id = temp_farm_count.country_id AND temp_farm_count.uuid = temp_country_totals.uuid
			SET temp_animal_event_stats.grand_total = temp_country_totals.grand_total, 
            temp_animal_event_stats.farm_total = temp_farm_count.grand_total;
			
			SELECT
			  GROUP_CONCAT(DISTINCT CONCAT("max(case when event_type = '",event_type,"' then sub_total end) ",event_type)) 		
			  INTO @sql 
			FROM  temp_animal_event_stats WHERE uuid = @uuid;         
			
			SET @sql = CONCAT("
			SELECT  stats.report_code, stats.report_name, stats.country Country,stats.farm_total Farms, ", @sql,",grand_total Total
			FROM temp_animal_event_stats stats			 
			WHERE stats.uuid ='", @uuid,"'  GROUP BY stats.country_id
			");             
            
			PREPARE stmt FROM @sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;            
			
			DELETE FROM temp_animal_stats WHERE uuid = @uuid;
			DELETE FROM temp_country_totals WHERE uuid = @uuid; 
            DELETE FROM temp_farm_count WHERE uuid = @uuid; 
            
        ELSE
            IF _rpt_code IN (1,12) THEN
				SELECT _rpt_code report_code, @rpt_name report, null Country, null Total_Farms, null Bull, null Cow, null Female_Calf,null heifer,null Male_calf, null Total_Animals;
		    ELSE
				SELECT _rpt_code report_code, @rpt_name report , null Country, null Total_Farms, null Cow, null Total_Animals;
            END IF;
        END IF;        
    
    END IF;
    	
    IF _rpt_code = 8 THEN
		SELECT
            _rpt_code report_code,
            @rpt_name report_name,
            ctr.name Country,
            farms.farms Farms,
            animal.animals Animals,
            COUNT(evnt.id) Records,
            ROUND(MIN(cast(replace(JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."136"')),'null',0) as decimal (10,2))),2) Minimum,   
			ROUND(MAX(cast(replace(JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."136"')),'null',0) as decimal (10,2))),2) Maximum, 		
			ROUND(AVG(cast(replace(JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."136"')),'null',0) as decimal (10,2))),2) Mean,   
			ROUND(STDDEV(cast(replace(JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."136"')),'null',0) as decimal (10,2))),2) Std             
       FROM core_animal_event evnt	 
       LEFT JOIN core_country ctr ON evnt.country_id = ctr.id
       LEFT JOIN core_animal  ON evnt.animal_id = core_animal.id
       LEFT JOIN ( -- get distinct animals 
		   SELECT a.country_id, COUNT(a.animal_id) animals FROM 
		   (SELECT DISTINCT evnt.country_id,evnt.animal_id FROM core_animal_event evnt LEFT JOIN core_animal anim ON evnt.animal_id = anim.id   WHERE evnt.event_type = @event_type AND anim.animal_type IN (1,2,5) AND evnt.event_date BETWEEN _date_form AND _date_to AND JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."136"')) > 0) a
		   GROUP BY a.country_id
       ) animal ON evnt.country_id = animal.country_id
       LEFT JOIN ( -- get distinct farms
			   SELECT a.country_id, COUNT(a.farm_id) farms FROM 
			( 
				SELECT DISTINCT evnt.country_id, anim.farm_id 
				FROM core_animal_event evnt
				LEFT JOIN core_animal anim on evnt.animal_id = anim.id
				WHERE evnt.event_type = @event_type AND anim.animal_type IN (1,2,5) AND evnt.event_date BETWEEN _date_form AND _date_to AND JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."136"')) > 0
			) a
			GROUP BY a.country_id
	  ) farms on evnt.country_id  = farms.country_id
	   WHERE     
	   evnt.event_type = @event_type AND 
       core_animal.animal_type IN (1,2,5) AND
	   evnt.event_date BETWEEN _date_form AND _date_to AND
	   JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."136"')) > 0
	  GROUP BY evnt.country_id;
		
	END IF;
    
    IF _rpt_code = 10 THEN
		SELECT
            _rpt_code report_code,
            @rpt_name report_name,
            ctr.name Country,
            farms.farms Farms,
            animal.animals Animals,
            COUNT(evnt.id) Records,
            ROUND(MIN(cast(replace(JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."136"')),'null',0)  as decimal (10,2))),2) Minimum,   
			ROUND(MAX(cast(replace(JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."136"')),'null',0) as decimal (10,2))),2) Maximum, 		
			ROUND(AVG(cast(replace(JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."136"')),'null',0) as decimal (10,2))) ,2)Mean,   
			ROUND(STDDEV(cast(replace(JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."136"')),'null',0) as decimal (10,2))),2) Std 
            
       FROM core_animal_event evnt	 
       LEFT JOIN core_country ctr ON evnt.country_id = ctr.id
       LEFT JOIN core_animal  ON evnt.animal_id = core_animal.id
       LEFT JOIN (
		    SELECT a.country_id, COUNT(a.animal_id) animals FROM 
		   (SELECT DISTINCT evnt.country_id,evnt.animal_id FROM core_animal_event evnt LEFT JOIN core_animal anim ON evnt.animal_id = anim.id   WHERE evnt.event_type = @event_type AND anim.animal_type IN (3,4) AND evnt.event_date BETWEEN _date_form AND _date_to AND JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."136"')) > 0) a
		   GROUP BY a.country_id
       ) animal ON evnt.country_id = animal.country_id
       LEFT JOIN (
			   SELECT a.country_id, COUNT(a.farm_id) farms FROM 
			( 
				SELECT DISTINCT evnt.country_id, anim.farm_id 
				FROM core_animal_event evnt
				LEFT JOIN core_animal anim on evnt.animal_id = anim.id
				WHERE evnt.event_type = @event_type AND anim.animal_type IN (3,4) AND evnt.event_date BETWEEN _date_form AND _date_to AND JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."136"')) > 0
			) a
			GROUP BY a.country_id
	  ) farms on evnt.country_id  = farms.country_id
	   WHERE     
	   evnt.event_type = @event_type AND 
       core_animal.animal_type IN (3,4) AND
	   evnt.event_date BETWEEN _date_form AND _date_to AND
	   JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."136"')) > 0
	  GROUP BY evnt.country_id;
		
	END IF;
    
    IF _rpt_code IN(13,14,15) THEN  			
		SELECT
            _rpt_code report_code,
            @rpt_name report_name,
            ctr.name Country,
            farms.farms Farms,
            animal.animals Animals,
            COUNT(evnt.id) Records            
       FROM core_animal_event evnt	 
       LEFT JOIN core_country ctr ON evnt.country_id = ctr.id
       LEFT JOIN (
		   SELECT a.country_id, COUNT(a.animal_id) animals FROM 
		   (SELECT DISTINCT country_id,animal_id FROM core_animal_event  WHERE event_type = @event_type AND event_date BETWEEN _date_form AND _date_to) a
		   GROUP BY a.country_id
       ) animal ON evnt.country_id = animal.country_id
       LEFT JOIN (
			   SELECT a.country_id, COUNT(a.farm_id) farms FROM 
			( 
				SELECT DISTINCT evnt.country_id, anim.farm_id 
				FROM core_animal_event evnt
				LEFT JOIN core_animal anim on evnt.animal_id = anim.id
				WHERE evnt.event_type = @event_type AND evnt.event_date BETWEEN _date_form AND _date_to
			) a
			GROUP BY a.country_id
	  ) farms on evnt.country_id  = farms.country_id
	   WHERE     
	   evnt.event_type = @event_type AND evnt.event_date BETWEEN _date_form AND _date_to	
	  GROUP BY evnt.country_id;
    END IF;
        
    IF _rpt_code IN(2,3,4,5,6,7) THEN 
		
         INSERT INTO temp_animal_stats_raw(report_code, report_name,country_id,country,animal_id,farm_id,param_value,uuid)
		 SELECT 
			 _rpt_code,
			 @rpt_name,
			 animal.country_id, 
			 country.name, 
			 animal.id,
			 animal.farm_id,            
			 CASE
				WHEN _rpt_code = 2 THEN 
					replace(JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."61"')),'null',0)+ replace(JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."68"')),'null',0)+replace(JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."59"')),'null',0)
				WHEN _rpt_code = 3 THEN 
					replace(JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."63"')),'null',0)  
				WHEN _rpt_code = 4 THEN 
					replace(JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."64"')),'null',0)   
			    WHEN _rpt_code = 5 THEN 
					replace(JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."66"')),'null',0)   
				WHEN _rpt_code = 6 THEN 
					replace(JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."67"')),'null',0)   
				WHEN _rpt_code = 7 THEN 
					replace(JSON_UNQUOTE(JSON_EXTRACT(evnt.additional_attributes, '$."65"')),'null',0) 
             END,   
			 @uuid 
		 FROM  core_animal_event evnt 
         LEFT JOIN core_animal animal on evnt.animal_id  = animal.id
         LEFT JOIN core_country country on animal.country_id = country.id
         WHERE evnt.event_type = @event_type AND evnt.event_date BETWEEN _date_form AND _date_to; 
         
         DELETE FROM temp_animal_stats_raw WHERE param_value = 0 AND uuid = @uuid;
         
         INSERT INTO temp_farm_count (country_id,grand_total,uuid) 
		 SELECT a.country_id,count(a.farm_id),@uuid FROM (             
			SELECT distinct country_id, farm_id							
			FROM temp_animal_stats_raw WHERE uuid = @uuid				
		 ) a GROUP BY a.country_id;
         
		 INSERT INTO temp_animal_count (country_id,grand_total,uuid) 
		 SELECT a.country_id,count(a.animal_id),@uuid FROM (             
			SELECT distinct country_id, animal_id							
			FROM temp_animal_stats_raw WHERE uuid = @uuid				
		 ) a GROUP BY a.country_id;
         
         INSERT INTO temp_country_totals (country_id,grand_total,uuid) 
		 SELECT country_id,count(animal_id),@uuid   
	     FROM temp_animal_stats_raw WHERE uuid = @uuid				
		 GROUP BY country_id;         
         
         SELECT 
			 raw.report_code,
			 raw.report_name,
			 raw.country,
             farm.grand_total Farms,
             animals.grand_total Animals,
             rec.grand_total Records,
			 ROUND(MIN(CAST(param_value AS decimal)),2) Minimum,
			 ROUND(MAX(CAST(param_value AS decimal)),2) Maximum,
			 ROUND(AVG(CAST(param_value AS decimal)),2) Mean,
			 ROUND(STDDEV(CAST(param_value AS decimal)),2) Std
         FROM temp_animal_stats_raw raw
         LEFT JOIN temp_farm_count farm ON raw.country_id  = farm.country_id AND raw.uuid = farm.uuid
         LEFT JOIN temp_animal_count animals ON raw.country_id  = animals.country_id AND raw.uuid = animals.uuid
		 LEFT JOIN temp_country_totals rec ON raw.country_id  = rec.country_id AND raw.uuid = rec.uuid         
         WHERE raw.uuid = @uuid
         GROUP BY raw.country_id;
                 
         DELETE FROM temp_animal_stats_raw WHERE uuid =@uuid;  
         DELETE FROM temp_country_totals WHERE uuid =@uuid;
         DELETE FROM temp_animal_count WHERE uuid =@uuid;
         DELETE FROM temp_farm_count WHERE uuid =@uuid;
         
    END IF;
END $$
DELIMITER ;