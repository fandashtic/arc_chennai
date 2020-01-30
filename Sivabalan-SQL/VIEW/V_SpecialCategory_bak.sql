create view [dbo].[V_SpecialCategory_bak]  
([Special_Cat_Code],[CategoryType],[Description],[CreationDate],[SchemeID],[Active])  
AS  
SELECT  Special_Cat_Code,CategoryType,Description,CreationDate,SchemeID,active   
FROM   Special_Category
