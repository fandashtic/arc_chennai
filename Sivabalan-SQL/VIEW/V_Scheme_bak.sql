CREATE VIEW V_Scheme_bak  
([SchemeID], [SchemeName], [SchemeType], [ValidFrom], [ValidTo], [SchemeDescription], [HasSlabs], [CreationDate],   
[ModifiedDate], [Customer], [Active])  
AS   
SELECT  SchemeID, SchemeName, SchemeType, ValidFrom, ValidTo, SchemeDescription, HasSlabs, CreationDate,   
ModifiedDate, Customer, Active FROM Schemes   
WHERE SchemeType in (1, 2, 3,17, 18, 19, 20, 33, 34, 35, 49, 50, 51, 52, 65, 81, 82, 83, 84)
