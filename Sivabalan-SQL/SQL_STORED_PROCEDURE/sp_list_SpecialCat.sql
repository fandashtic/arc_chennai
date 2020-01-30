CREATE procedure [dbo].[sp_list_SpecialCat]  AS

SELECT Special_Category.Special_Cat_Code, Special_Category.Description, 
Special_Category.SchemeID, Schemes.SchemeName 
FROM Special_Category, Schemes
WHERE Special_Category.SchemeID *= Schemes.SchemeID AND Special_Category.Active = 1 
AND Schemes.Active = 1
