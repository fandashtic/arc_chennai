Create Procedure spr_DSwiseBeatwiseAverageInvoiceValue_Detail
(@SB nVarchar(255), @ProductHierarchy nVarchar(255), @Category nVarchar(2550),
 @FromDate DateTime, @ToDate DateTime)
As
Declare @SalmID Int
Declare @BeatID Int
Declare @Fin Int
Declare @Delimeter as Char(1)            
Set @Delimeter=Char(15)            

Set @Fin = CharIndex(Char(15), @SB, 1)
Set @SalmID = Substring(@SB, 1, @Fin - 1)
Set @BeatID = Substring(@SB, @Fin + 1, Len(@SB))
--Select @SalmID, @BeatID
Declare @Continue int      
Declare @CategoryID int      
Set @Continue = 1      

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

-- Select Count([Cou]) From (Select "Cou" = Count(Distinct UOM.[Description]) From 
-- #temp4, Items its, InvoiceAbstract inva, InvoiceDetail invd, UOM Where 
-- #temp4.LeafID = its.CategoryID And invd.Product_Code = its.Product_Code And 
-- inva.InvoiceID = invd.InvoiceID And UOM.UOM = Its.UOM And
-- inva.InvoiceDate Between @FromDate And @ToDate And 
-- inva.InvoiceType In (1, 3) And IsNull(inva.Status, 0) & 192 = 0 
-- Group By UOM.[Description]) cu

--select * from #temp4
If IsNull((Select Count([Cou]) From (Select  "Cou" = Count(Distinct UOM.[Description]) From   
#temp4, Items its, InvoiceAbstract inva, InvoiceDetail invd, UOM, beat_salesman bsal Where   
bsal.CustomerID = inva.customerid And 
#temp4.LeafID = its.CategoryID And invd.Product_Code = its.Product_Code And   
inva.InvoiceID = invd.InvoiceID And UOM.UOM = Its.UOM And  
inva.InvoiceDate Between @FromDate And @ToDate And   
inva.InvoiceType In (1, 3) And IsNull(inva.Status, 0) & 192 = 0   
and bsal.beatid = @BeatID And bsal.salesmanid = @SalmID
Group By UOM.[Description]
) cu  
), 0) = 1  
Begin
	Select [Category], "Product Category" = [Category], "No. of Invoices" = Count([Inv]), 
	"UOM" = [Desc], "Qty" = Sum([Qty]), "Value (%c)" = Sum([Amt]) From (
	Select "BeatID" = bt.Beatid, "SalesmanID" = sm.salesmanid, "Cust" = inva.CustomerID, "Category" = #temp4.Parent, 
	"Inv" = Case When inva.InvoiceType In (1, 3) Then inva.InvoiceID End, 
	"Desc" = UOM.[Description], 
	"Qty" = Sum(Case inva.InvoiceType When 4 Then 
	Case inva.Status & 32 When 0 Then 0 - invd.Quantity End Else invd.Quantity End), 
	"Amt" = Sum(Case inva.InvoiceType When 4 Then 
	Case inva.Status & 32 When 0 Then 0 - invd.Amount End Else invd.Amount End) From 
	#temp4, Items its, InvoiceAbstract inva, InvoiceDetail invd, UOM, 
	Beat bt, salesman sm
	Where 
	#temp4.LeafID = its.CategoryID And invd.Product_Code = its.Product_Code And 
	inva.InvoiceID = invd.InvoiceID And UOM.UOM = Its.UOM And 
	inva.InvoiceDate Between @FromDate And @ToDate And 
	inva.InvoiceType In (1, 3, 4) And IsNull(inva.Status, 0) & 192 = 0 And
	Case inva.InvoiceType When 4 Then IsNull(inva.Status, 0) & 32 Else 0 End = 0 
	and inva.beatid = bt.beatid and inva.salesmanid = sm.salesmanid
	Group By #temp4.Parent, inva.InvoiceID, UOM.[Description], inva.CustomerID, 
	inva.InvoiceType, inva.Status, bt.Beatid, sm.salesmanid) 
	sub --beat_salesman bsm
	Where --sub.[Cust] = bsm.CustomerID And 
	sub.SalesmanID = @SalmID 
	And sub.BeatID = @BeatID Group By [Category], [Desc]
--, invd.Quantity, invd.Amount 
End
Else
Begin
	Select [Category], "Product Category" = [Category], "No. of Invoices" = Count([Inv]), 
	"Value (%c)" = Sum([Amt]) From (
	Select "BeatID" = bt.Beatid, "SalesmanID" = sm.salesmanid, "Cust" = inva.CustomerID, "Category" = #temp4.Parent, 
	"Inv" = Case When inva.InvoiceType In (1, 3) Then inva.InvoiceID End, 
	"Amt" = Sum(Case inva.InvoiceType When 4 Then 
	Case inva.Status & 32 When 0 Then 0 - invd.Amount End Else invd.Amount End) From 
	#temp4, Items its, InvoiceAbstract inva, InvoiceDetail invd, UOM, 
	Beat bt, salesman sm
	Where 
	#temp4.LeafID = its.CategoryID And invd.Product_Code = its.Product_Code And 
	inva.InvoiceID = invd.InvoiceID And UOM.UOM = Its.UOM And
	inva.InvoiceDate Between @FromDate And @ToDate And 
	inva.InvoiceType In (1, 3, 4) And IsNull(inva.Status, 0) & 192 = 0 And
	Case inva.InvoiceType When 4 Then IsNull(inva.Status, 0) & 32 Else 0 End = 0 
	and inva.beatid = bt.beatid and inva.salesmanid = sm.salesmanid
	Group By #temp4.Parent, inva.InvoiceID, inva.CustomerID, 
	inva.InvoiceType, inva.Status, bt.Beatid, sm.salesmanid)

	sub --, Salesman sm, Beat bt beat_salesman bsm
	Where --sub.[Cust] = bsm.CustomerID And 
	sub.SalesmanID = @SalmID 
	And sub.BeatID = @BeatID Group By [Category]
 End

-- Select UOM.[Description] From 
-- #temp4, Items its, InvoiceAbstract inva, InvoiceDetail invd, UOM Where 
-- #temp4.LeafID = its.CategoryID And invd.Product_Code = its.Product_Code And 
-- inva.InvoiceID = invd.InvoiceID And UOM.UOM = Its.UOM And
-- inva.InvoiceDate Between @FromDate And @ToDate And 
-- inva.InvoiceType In (1, 3) And IsNull(inva.Status, 0) & 192 = 0 
-- Group By UOM.[Description]

--And 
--its.CategoryID In (Select CategoryID From #tempCategory)


Drop Table #tmpCat
Drop Table #temp2
Drop Table #temp3
Drop Table #temp4

