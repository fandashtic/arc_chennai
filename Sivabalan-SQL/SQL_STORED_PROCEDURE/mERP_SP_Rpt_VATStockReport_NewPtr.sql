Create Procedure mERP_SP_Rpt_VATStockReport_NewPtr(@Date nVarchar(25))
AS
BEGIN
SET DATEFORMAT DMY
/* Variable Declarations */
Declare @ProductHierarchy nvarchar(100)
Declare @CategoryGroup nvarchar(10)
Declare @WDCode nVarchar(255)  
Declare @WDDest nVarchar(255)  
Declare @CompaniesToUploadCode nVarchar(255) 

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload    
Select Top 1 @WDCode = RegisteredOwner From Setup         

If @CompaniesToUploadCode='ITC001'    
	Set @WDDest= @WDCode    
Else    
Begin    
	Set @WDDest= @WDCode    
	Set @WDCode= @CompaniesToUploadCode    
End    

/* Table Declarations */
Create table #tmpMfr(Manufacturer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
Create Table #tempCategory (CategoryID Int, Status Int)           
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)      
Create Table #tempItems (CategoryID Int , Product_Code nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)                 
Create Table #temp2 (IDS Int IDENTITY(1, 1), CatID Int)        
Create Table #temp3 (CatID Int, Status Int)        
Create Table #temp4 (LeafID Int, CatID Int, Parent nVarChar(250) COLLATE SQL_Latin1_General_CP1_CI_AS)   

Insert into #tmpMfr select Manufacturer_Name from Manufacturer    

Set @CategoryGroup='%'
Set @ProductHierarchy = (select distinct HierarchyName from ItemHierarchy where HierarchyID = 2)   
/*2 is for Division*/
Exec Sp_GetCGLeafCat_ITC @CategoryGroup, @ProductHierarchy, '%'   

Insert Into #TempItems select CategoryID,Product_Code from Items   
where CategoryID in (Select Distinct CategoryID from #TempCategory)      


Declare @Counter Int        
Set @Counter = 1     

-- Logic similar to Available Book Stock Report
-- Procedure for ITC Sorting logic    
Exec sp_CatLevelwise_ItemSorting    
  
-- =================================================== 
-- Code to find the category name according to hierarchy for the Items
Declare @ContinueA int            
Declare @CategoryID1 int            
Set @ContinueA = 1              

Insert InTo #temp2   
Select CatID From dbo.fn_GetCatFrmCG_ITC(@CategoryGroup,@ProductHierarchy,Default)       

Declare @Continue2 Int      
Declare @Inc Int      
Declare @TCat Int      
Set @Inc = 1      
Set @Continue2 = IsNull((Select Count(*) From #temp2), 0)      

While @Inc <= @Continue2      
Begin      
	Insert InTo #temp3 Select CatID, 0 From #temp2 Where IDS = @Inc      
	Select @TCat = CatID From #temp2 Where IDS = @Inc      
	While @ContinueA > 0          
	Begin          
		Declare Parent Cursor Keyset For          
		Select CatID From #temp3  Where Status = 0          
		Open Parent          
		Fetch From Parent Into @CategoryID1    
		While @@Fetch_Status = 0          
		Begin          
			Insert into #temp3 Select CategoryID, 0 From ItemCategories           
			Where ParentID = @CategoryID1          
			If @@RowCount > 0           
				Update #temp3 Set Status = 1 Where CatID = @CategoryID1          
			Else             
				Update #temp3 Set Status = 2 Where CatID = @CategoryID1          

			Fetch Next From Parent Into @CategoryID1          
		End     
		Close Parent          
		DeAllocate Parent          
		Select @ContinueA = Count(*) From #temp3 Where Status = 0          
	End          
	Delete #temp3 Where Status not in  (0, 2)  

	Insert InTo #temp4 Select CatID, @TCat,     
	(Select Category_Name From ItemCategories where CategoryID = @TCat) From #temp3      
	Delete #temp3      
	Set @ContinueA = 1      
	Set @Inc = @Inc + 1      
End   

Create table #Temp_Batch_Products_new
(
  Batch_Code int,
  PTR_new decimal(18,6)
)
insert into #Temp_Batch_Products_new
select Batch_Code,PTR from batch_products_PTRUpdateCG1


Select #tempCategory1.[IDs],@WDCode as "WDCode", @WDDest as "WD Dest", Items.Product_code as [Item Code],
Items.ProductName as [Item Name],#temp4.Parent as [Category],UOM.Description as [UOM],isnull(Batch_Products_GST_Backup.Batch_Number,'') as [Batch],
isnull(Batch_Products_GST_Backup.PTS,0) as [Net PTS Excl Tax],isnull(Batch_Products_GST_Backup.PTR,0) as [PTR Excl Tax],
isnull(Batch_Products_GST_Backup.MRPPerPack,0) as [MRP Per Pack],Batch_Products_GST_Backup.TaxSuffered AS 'Purchase Tax Rate',
Sum(case when  isnull(Damage,0)=0 then isnull(quantity,0) Else 0 end) as [Saleable Qty] 
,case when TaxType=1 then 'LST' 
when TaxType=2 then 'CST'
when TaxType=3 then 'FLST'
else '' end AS 'Tax Type',
case when isnull(TOQ,0)=0 then 'No' else 'Yes' end as'TOQ',
Sum(case when isnull(Damage,0)<>0 then isnull(quantity,0) Else 0 end) as [Damage Qty],Items.HSNNumber as [HSNNumber],PTR_new AS [NEW PTR]
--,Sum(isnull(Damage,0)) as Damage
From Items, ItemCategories, #temp4, Manufacturer, #tempCategory1, #tmpMfr, #tempItems,Uom,Batch_Products_GST_Backup,#Temp_Batch_Products_new
Where                                  
Items.CategoryID = ItemCategories.CategoryID                               
And #temp4.LeafID = Items.CategoryID     
And Items.CategoryID = #tempCategory1.CategoryID                        
And ItemCategories.Active = 1      
And Items.Active = 1  
And Items.ManufacturerID = Manufacturer.ManufacturerID     
And Manufacturer.Manufacturer_Name = #tmpMfr.Manufacturer  
And Items.Product_Code = #tempItems.Product_Code 
And Uom.Uom = Items.UOM 
And Batch_Products_GST_Backup.Product_code = Items.Product_Code
AND #Temp_Batch_Products_new.Batch_Code=Batch_Products_GST_Backup.Batch_Code
/*Quantity should be greater than zero and Non-Damage Stock*/
And isnull(Quantity,0)>0
--And isnull(Damage,0)=0

Group by Items.Product_code,Items.ProductName,#temp4.Parent,UOM.Description,Batch_Products_GST_Backup.Batch_Number,
Batch_Products_GST_Backup.PTS,Batch_Products_GST_Backup.PTR,Batch_Products_GST_Backup.MRPPerPack,
Batch_Products_GST_Backup.TaxSuffered,#tempCategory1.[IDs],#Temp_Batch_Products_new.PTR_new,
Batch_Products_GST_Backup.TaxType,Batch_Products_GST_Backup.TOQ,Batch_Products_GST_Backup.Damage,Items.HSNNumber
Order By #tempCategory1.[IDs],Items.Product_Code  

Drop table #tmpMfr
Drop Table #tempCategory
Drop table #tempCategory1
Drop Table #tempItems
Drop Table #temp2
Drop Table #temp3
Drop Table #temp4
DROP TABLE #Temp_Batch_Products_new
END
