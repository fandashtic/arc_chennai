select * from Customer_CategoryGroups
select * from Customer_Groups
--select * from Customer Where Company_Name  like '%counter%' -- ARC003

select * from Customer_Mappings where CustomerId = 'ARC003'
--Update Customer_Mappings set CategoryGroupId = 3, GroupId = 13 where CustomerId = 'ARC003'

select * from syscomments where text like '%HH%'

select * from sys.objects where object_id in (select id from syscomments where text like '%tbl_SKUOPT_int%') order by type_desc

select top 10 * from Tmp_SKUOPT_DailySKU with (nolock) where ProductCode in (select Product_Code from V_ARC_Items where CategoryGroup = 'GR4')
select * from Tmp_SKUOPT_DailySKU
select * from tbl_SKUOpt_Monthly Where GroupName = 'GR4'
SELECT * FROM WDSKUList
SELECT TOP 1 ID,EFFECTIVEFROMDATE,'GR4' CATEGORYGROUP,ZMAX,ZMIN,FORM,Active,AlertStatus,getdate() CreationDate,getdate() modifiedDate,MonthFlag FROM WDSKUList

select * from V_ARC_Items where CategoryGroup = 'GR4'
 select * From tbl_SKUOPT_int  

sp_helptext Sp_SKUOPT_Daily_Int
sp_helptext Sp_SKUOPT_MonthdataPosted
sp_helptext Sp_SKUOPT_DataPosting
sp_helptext FN_SKUOPT_DailySKU

sp_helptext Sp_SKUOPT_DataPosting
sp_helptext Sp_SKUOPT_Daily_Int
sp_helptext Sp_SKUOPT_Check
sp_helptext Sp_SKUOPT_DailyData

Exec Sp_SKUOPT_DailyData '01-Mar-2020'

sp_helptext V_DailySKU

select * from tbl_mERP_ConfigAbstract where ScreenName like '%GOGREENPRINT%'
--Update tbl_mERP_ConfigAbstract set Flag = 1 where ScreenName like '%GOGREENPRINT%'

123456

Select TOP 10 *FROM V_ARC_Sale_ItemDetails SR WITH (NOLOCK) 

select SONumber from InvoiceAbstract where GSTFullDocID = 'I/19-20/1954'


select * From tbl_SKUOPT_int

select * from Beat