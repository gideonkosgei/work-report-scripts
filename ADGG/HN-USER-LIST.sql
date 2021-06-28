use adgg_uat;
SELECT 
	id,	name,username,	
    CASE
    WHEN isnull(phone) OR phone ='' THEN phone    
    ELSE 
		CASE
			WHEN CHAR_LENGTH(phone) > 12 THEN SUBSTRING(phone, 5) 
            WHEN CHAR_LENGTH(phone) = 12 THEN SUBSTRING(phone, 4)
            WHEN CHAR_LENGTH(phone) = 10 THEN SUBSTRING(phone, 2)
            ELSE phone
		END    
	END phone
FROM auth_users;