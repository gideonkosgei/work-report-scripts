SELECT 
concat_ws('',ifnull(id,'null'), ',',ifnull(name,'null'), ',',ifnull(username,'null'),',',ifnull(phone,'null'))
as 'id,name,username,phone'
 FROM (
SELECT 
	id,	name,username,	
    CASE
    WHEN isnull(phone) OR phone ='' THEN phone    
    ELSE 
		CASE
			WHEN CHAR_LENGTH(phone) > 12 THEN CONCAT('0',SUBSTRING(phone, 5)) 
            WHEN CHAR_LENGTH(phone) = 12 THEN CONCAT('0',SUBSTRING(phone, 4)) 
            WHEN CHAR_LENGTH(phone) = 10 THEN CONCAT('0',SUBSTRING(phone, 2))
            ELSE phone
		END    
	END phone
FROM auth_users) x;