CREATE Procedure sp_get_splCategoryForVan
(
@SERVERDATE as DATETIME,
@Additional_No_of_Days as int = 0
)
As
BEGIN            
DECLARE @FirstDay Int        
SET @FirstDay = @@DATEFIRST          
SET DATEFIRST 7

Select Special_Cat_Code,CategoryType,Description,Special_Category.SchemeID,Schemes.SchemeName,Schemes.SchemeType,Schemes.Promptonly,Schemes.message           
From Special_Category,Schemes           
Where Special_Category.Active=1            
and schemes.schemetype in (18,84) 
and Schemes.Active=1 and Special_Category.schemeID<>0 and Schemes.SchemeID=Special_Category.SchemeID             
and @SERVERDATE between Schemes.ValidFrom and Dateadd(d, @Additional_No_of_Days, Schemes.ValidTo)                
and (Isnull(HappyScheme,0)=0 or (Isnull(HappyScheme,0)=1             
and ( CONVERT(nvarchar,ToHour,108)=N'00:00:00' or CONVERT(nvarchar,@Serverdate,108) between CONVERT(nvarchar,FromHour,108) and CONVERT(nvarchar,ToHour,108))            
and (ToDayMonth=0 or DAY(@Serverdate) between FromDayMonth and ToDayMonth)            
and (ToWeekDay =-1 or (DATEPART(DW,@Serverdate)-1) between FromWeekDay and ToWeekDay)))              

SET DATEFIRST @FirstDay        
END
