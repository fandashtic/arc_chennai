CREATE Procedure spr_CategorywiseSKUwiseDSwiseBeatwiseNonProductiveOutlets  
(@ProductHierarchy nVarchar(255), @Category nVarchar(2550),   
 @ItemCode nVarChar(2550), @Salesman nVarchar(2550),   
 @Beat nVarchar(2550), @Merchandise nVarchar(2550), @FromDate DateTime, @ToDate DateTime)  
AS  
Declare @Delimeter as Char(1)              
Set @Delimeter=Char(15)              
  
Declare @Continue int        
Declare @CategoryID int        
Set @Continue = 1     

Create Table #tmpMerchandise(MerchandiseType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)  

If @Merchandise = N'%'    
 Insert InTo #tmpMerchandise
 Select Merchandise.Merchandise,Isnull(CustMerchandise.CustomerID,'') From Merchandise left outer join CustMerchandise
 on Merchandise.MerchandiseID = CustMerchandise.MerchandiseID
 Union
 Select '', Customer.CustomerID From customer
 Where CustomerID not in (Select customerID from CustMerchandise)
Else    
 Insert into #tmpMerchandise 
 Select Merchandise.Merchandise,Isnull(CustMerchandise.CustomerID,'') From Merchandise,CustMerchandise
 Where Merchandise.MerchandiseID = CustMerchandise.MerchandiseID
 and Merchandise.merchandise in (select * from dbo.sp_SplitIn2Rows(@Merchandise, @Delimeter)) 
      
  
Create Table #tmpProd(product_code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
If @ItemCode = N'%'    
 Insert InTo #tmpProd Select Product_code From Items    
Else    
 Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)    
  
Create table #tmpSalesMan(SalesmanID Int)        
if @Salesman = N'%'         
   Insert into #tmpSalesMan select SalesmanID from Salesman        
Else        
   Insert into #tmpSalesMan Select SalesmanID From Salesman Where   
   Salesman_Name In (select * from dbo.sp_SplitIn2Rows(@Salesman,@Delimeter))  
  
Create table #tmpBeat(BeatID Int)        
if @Beat = N'%'        
   Insert into #tmpBeat select BeatID from Beat        
Else        
   Insert into #tmpBeat Select BeatID From Beat Where   
   [Description] In (select * from dbo.sp_SplitIn2Rows(@Beat,@Delimeter))  
  
Create table #tmpCat(Category nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
If @Category = N'%' And @ProductHierarchy = N'%'    
Begin    
    
   Insert into #tmpCat select Category_Name from ItemCategories Where [level] = 1    
    
End    
Else If @Category = N'%' And @ProductHierarchy != N'%'    
Begin    
    
 Insert InTo #tmpCat select Category_Name From itemcategories itc, itemhierarchy ith    
 where itc.[level] = ith.hierarchyid and ith.hierarchyname = @ProductHierarchy    
    
End    
Else          
Begin    
    
   Insert into #tmpCat select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter)          
  
End    
  
Create Table #temp2 (IDS Int IDENTITY(1, 1), CatID Int)    
Create Table #temp3 (CatID Int, Status Int)    
Create Table #temp4 (IDS Int IDENTITY(1, 1), LeafID Int, CatID Int, Parent nVarChar(250) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create Table #temp5 (ItemCode nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, LeafID Int, CatID Int, Parent nVarChar(250) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Insert InTo #temp2 Select CategoryID     
From ItemCategories      
Where ItemCategories.Category_Name In (Select Category from #tmpCat)      
  
Declare @Continue2 Int    
Declare @Inc Int    
Declare @TCat Int    
Set @Inc = 1    
Set @Continue2 = IsNull((Select Count(*) From #temp2), 0)    
  
While @Inc <= @Continue2    
Begin    
Insert InTo #temp3 Select CatID, 0 From #temp2 Where IDS = @Inc    
Select @TCat = CatID From #temp2 Where IDS = @Inc    
While @Continue > 0        
Begin        
 Declare Parent Cursor Keyset For        
 Select CatID From #temp3  Where Status = 0        
 Open Parent        
 Fetch From Parent Into @CategoryID        
 While @@Fetch_Status = 0        
Begin        
    
  Insert into #temp3    
  Select CategoryID, 0 From ItemCategories         
  Where ParentID = @CategoryID        
    
  If @@RowCount > 0         
   Update #temp3 Set Status = 1 Where CatID = @CategoryID        
  Else        
   Update #temp3 Set Status = 2 Where CatID = @CategoryID        
  Fetch Next From Parent Into @CategoryID        
 End        
 Close Parent        
 DeAllocate Parent        
 Select @Continue = Count(*) From #temp3 Where Status = 0        
End        
Delete #temp3 Where Status not in  (0, 2)        
Insert InTo #temp4 Select CatID, @TCat,     
(Select Category_Name From ItemCategories where CategoryID = @TCat)    
From #temp3    
Delete #temp3    
Set @Continue = 1    
Set @Inc = @Inc + 1    
End    
  
Insert InTo #temp5 Select Product_Code, LeafID, CatID, Parent From #temp4, Items   
Where #temp4.LeafID = Items.CategoryID  
--Select BeatID, SalesmanID, CustomerID From Beat_Salesman  
-- Declare @NewCount Int  
-- Declare @NewCatName nVarchar(255)  
-- Select @NewCount = Count(*) From #temp5  
-- Set @Inc = 1  
-- Create Table #tempCategory (CategoryID int, Status int)                    
-- While @Inc <= @NewCount  
-- Begin  
--  Select @NewCatName = Parent From #temp5 Where IDS = @Inc  
--  Exec GetLeafCategories '%', @NewCatName  
--  Set @Inc = @Inc + 1  
--   
-- End  
  
--select * from #temp4  
--select * from #temp5 Order By CatID  
--select * from #tempCategory  
select distinct BeatID,SalesmanID,CustomerID into #tmpBeatSalesman from Beat_Salesman  
  
Select ItemCode, "Category" = Parent, "Item Name" = ProductName,   
"No Of Customers Not Invoiced" = IsNull((Select Count(bs.CustomerID) From   
Customer cus, #tmpBeatSalesman bs
Where cus.CustomerID = bs.CustomerID 
And Cus.CustomerID in (select CustomerID from  #tmpMerchandise)
And cus.Active = 1 And bs.CustomerID Not In   
(Select CustomerID From InvoiceAbstract inva, InvoiceDetail invd   
Where inva.InvoiceID = invd.InvoiceID And   
InvoiceDate Between @FromDate And @ToDate And   
InvoiceType In (1, 3) And IsNull(Status, 0) & 192 = 0   
And invd.Product_Code = #temp5.ItemCode)  
And BeatID In (Select BeatID From #tmpBeat) And SalesmanID   
In (Select SalesmanID From #tmpSalesMan) And bs.CustomerID != N''), 0)  
From #temp5, Items Where Items.Product_Code = #temp5.ItemCode And   
#temp5.ItemCode In (Select product_code From #tmpProd)  
--   
--Drop Table #tempCategory  
Drop Table #tmpBeatSalesman  
Drop Table #tmpProd  
Drop Table #tmpSalesMan  
Drop Table #tmpBeat  
Drop Table #temp2  
Drop Table #temp3  
Drop Table #temp4  
Drop Table #temp5  
