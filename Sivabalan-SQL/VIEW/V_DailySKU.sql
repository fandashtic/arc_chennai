CREATE VIEW [dbo].[V_DailySKU]
AS 
Select Cast(CustomerID as nvarchar(15)) CustomerID, Cast(ProductCode as nvarchar(15)) as SysSKUCode, Cast(Flag as nvarchar(1)) Flag From dbo.FN_SKUOPT_DailySKU()
Union
Select Distinct Cast(CustomerID as nvarchar(15)) CustomerID, Cast(SKU as nvarchar(15)) as SysSKUCode, Cast('I' as nvarchar(1)) as SKUType From tbl_SKUOpt_Incremental Where isnull(Status,0)=1
