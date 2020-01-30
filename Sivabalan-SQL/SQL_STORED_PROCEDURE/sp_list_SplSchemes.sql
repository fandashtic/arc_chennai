CREATE PROCEDURE sp_list_SplSchemes      
AS      
SELECT SchemeID, SchemeName FROM Schemes 
WHERE SchemeType IN (18,19,20,21,22,81,82,84,97,98,99,100)   
AND Active = 1 
