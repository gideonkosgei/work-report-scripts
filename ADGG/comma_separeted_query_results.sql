(SELECT' id,name, username,phone')
UNION
(SELECT  concat(id,',',name,',', username,',',phone) FROM auth_users)