CREATE Procedure spr_DSwiseBeatwiseAverageInvoiceValue   
(@Salesman nVarchar(2550), @Beat nVarchar(2550), @DSType nVarchar(2550), 
 @ProductHierarchy nVarchar(255), @Category nVarchar(2550),  
 @FromDate DateTime, @ToDate DateTime)  
As  
  
Declare @Delimeter as Char(1)              
Set @Delimeter=Char(15)              
  
Create table #tmpDSType(SalesmanID Int,DSTypeName nvarchar(50)) 
if @DSType = N'%' or @DSType = N''          
   Insert into #tmpDSType 
   select Salesman.SalesmanID,DSTypeValue from DSType_Master,DSType_Details,Salesman
   Where Salesman.SalesmanID = DSType_Details.SalesmanID
   and DSType_Details.DSTypeID = DSType_Master.DSTypeID 
   and DSType_Master.DSTypeCtlPos = 1 
   Union
   Select SalesmanID,'' from Salesman where SalesmanID not in (select SalesmanID from DSType_Details where DSTypeCtlPos = 1)
Else        
   Insert into #tmpDSType 
   select SalesmanID,DSTypeValue from DSType_Master,DSType_Details
   Where DSType_Master.DSTypeID = DSType_Details.DSTypeID  
   and DSType_Master.DSTypeCtlPos = 1 
   and DSType_Master.DSTypeValue in (select * from dbo.sp_SplitIn2Rows(@DSType,@Delimeter)) 

Create table #tmpSalesMan(SalesmanID Int)        
if @Salesman = N'%'         
   Insert into #tmpSalesMan 
   select SalesmanID from Salesman Where SalesmanID in (select SalesmanID from #tmpDSType)
Else        
   Insert into #tmpSalesMan 
   Select SalesmanID From Salesman 
   Where Salesman_Name In (select * from dbo.sp_SplitIn2Rows(@Salesman,@Delimeter))
   and SalesmanID in (select SalesmanID from #tmpDSType)

  
Create table #tmpBeat(BeatID Int)        
if @Beat = N'%'        
   Insert into #tmpBeat select BeatID from Beat        
Else        
   Insert into #tmpBeat Select BeatID From Beat Where   
   [Description] In (select * from dbo.sp_SplitIn2Rows(@Beat,@Delimeter))  


  
Create Table #tempCategory (CategoryID int, Status int)   
Exec GetLeafCategories @ProductHierarchy, @Category  
  
--------------------------------------------  
-- Select bt.Beatid, sm.salesmanid, "CustID" = Case When inva.InvoiceType In (4) Then   
--     Case IsNull(inva.Status, 0) & 32 When 0 Then inva.CustomerID End Else inva.CustomerID End,   
-- "TotalInv" = Case When inva.InvoiceType In (1, 3) Then inva.InvoiceID End,  
-- "TotVal" = Case inva.InvoiceType When 4 Then Case IsNull(inva.Status, 0) & 32   
--      When  0 Then 0 - (inva.NetValue - inva.Freight) End  
--      Else (inva.NetValue - inva.Freight) End  
--   
-- --"AvgTotVal" = Sum(NetValue - Freight) / Case When Count(inva.InvoiceID) = 0 Then 1 Else Count(inva.InvoiceID) End  
-- From InvoiceAbstract inva, InvoiceDetail invd, Items its  
-- , Salesman sm, Beat bt Where   
-- --inva.CustomerID = bsm.CustomerID And  
-- inva.InvoiceID = invd.InvoiceID And invd.Product_Code = its.Product_Code And   
-- inva.InvoiceDate Between @FromDate And @ToDate And   
-- inva.InvoiceType In (1, 3, 4) And IsNull(inva.Status, 0) & 192 = 0 And   
-- its.CategoryID In (Select CategoryID From #tempCategory)   
-- And inva.salesmanid = sm.salesmanid and inva.beatid = bt.beatid  
-- Group By inva.CustomerID, inva.InvoiceID, inva.NetValue, inva.Freight,  
-- inva.InvoiceType, inva.Status, bt.Beatid, sm.salesmanid  
  
--------------------------------------------  
Select Cast(sm.SalesmanID As nVarchar)+ Char(15) + Cast(bt.BeatID As nVarchar), "DS Name" =  Sm.Salesman_Name,"DS Type" = [DSType], "Beat Name" = bt.[Description],   
"Total No. of Invoices" = Count([TotalInv]),   
"Total Value (%c)" = IsNull(Sum([TotVal]), 0),   
"Avg Invoice Value (%c)" = IsNull(Sum([TotVal]) / Case When Count([TotalInv]) = 0 Then 1 Else Count([TotalInv]) End, 0) From  
(Select "BeatID" = bt.Beatid, "DSType" = DS.DSTypeName, "salesmanID" = sm.salesmanid, 
"CustID" = Case When inva.InvoiceType In (4) Then   
 Case IsNull(inva.Status, 0) & 32 When 0 Then inva.CustomerID End Else inva.CustomerID End,   
 "TotalInv" = Case When inva.InvoiceType In (1, 3) Then inva.InvoiceID End,  
 "TotVal" = Case inva.InvoiceType When 4 Then Case IsNull(inva.Status, 0) & 32   
     When  0 Then 0 - (inva.NetValue - inva.Freight) End  
     Else (inva.NetValue - inva.Freight) End  
  
--"AvgTotVal" = Sum(NetValue - Freight) / Case When Count(inva.InvoiceID) = 0 Then 1 Else Count(inva.InvoiceID) End  
From InvoiceAbstract inva, InvoiceDetail invd, Items its , Salesman sm, Beat bt, #tmpDSType DS Where 
inva.InvoiceType In (1, 3, 4) And IsNull(inva.Status, 0) & 192 = 0 And    
--inva.CustomerID = bsm.CustomerID And  
inva.InvoiceID = invd.InvoiceID And invd.Product_Code = its.Product_Code And   
inva.InvoiceDate Between @FromDate And @ToDate And   
its.CategoryID In (Select CategoryID From #tempCategory)   
And inva.salesmanid = sm.salesmanid and inva.beatid = bt.beatid 
and inva.salesmanID = DS.SalesmanID 
Group By inva.CustomerID, inva.InvoiceID, inva.NetValue, inva.Freight,  
inva.InvoiceType, inva.Status, bt.Beatid, sm.salesmanid, DS.DSTypeName  
) sub,   
Salesman sm, Beat bt --, invoiceabstract inv --Beat_Salesman bsm   
Where   
sub.SalesmanID = sm.SalesmanID And sub.BeatID = bt.BeatID And   
--sub.[CustID] = inv.CustomerID --And  
sub.BeatID In (Select BeatID From #tmpBeat) And sub.SalesmanID   
In (Select SalesmanID From #tmpSalesMan) --And inv.CustomerID != N''  
--And inv.InvoiceDate Between @FromDate And @ToDate   
Group By sm.Salesman_Name,[DSType],bt.[Description],   
sm.SalesmanID, bt.BeatID   
  
  
Drop Table #tmpSalesMan  
Drop Table #tmpBeat  
Drop Table #tempCategory  

