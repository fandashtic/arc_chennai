CREATE Procedure spr_VanLoading_OrderBooking_Detail_ITC
(
 @VanNumber NVarChar(255),
 @Beat NVarChar(510),
 @Product_Hierarchy NVarChar(256),                   
 @Category NVarChar(2550),
 @FromDate DateTime,
 @ToDate DateTime
)      
As      

Declare @Delimeter As Char(1)
Set @Delimeter = Char(15)
      
Create Table #TempCategory(CategoryID Int, Status Int)                  
Exec dbo.GetLeafCategories @Product_Hierarchy, @Category            
          
Create Table #TmpCat(Category NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #TmpBeat(BeatID Int)

Create Table #Temp
(
 RowNum Int Identity(1,1),
 Product_Code NVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
 UOM Int,
 [Description] NVarChar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,
 UOMConv Decimal(18,6)
)  
Exec sp_GetDefaultSalesUOM_ITC    

Create Table #TempSale
(
 CategoryName NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 ItemCode NVarChar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,
 ItemName NVarChar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,
 Qty Decimal(18,6),ECP Decimal(18,6),NetValue Decimal(18,6)
)

Create Table #TempFree
(
 CategoryName NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
 ItemCode NVarChar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,
 ItemName NVarChar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,
 Qty Decimal(18,6),ECP Decimal(18,6),NetValue Decimal(18,6)
)
      
If @Beat = '%'      
 Insert Into #TmpBeat Select BeatId From Beat      
Else      
 Insert Into #TmpBeat       
 Select BeatId From Beat Where Description In (Select * From dbo.sp_SplitIn2Rows(@Beat,@Delimeter))
      
If @Category = '%' And @Product_Hierarchy = '%'        
 Begin        
  Insert Into #TmpCat Select Category_Name From ItemCategories Where [Level] = 1        
 End        
Else If @Category = '%' And @Product_Hierarchy != '%'        
 Begin        
  Insert Into #TmpCat Select Category_Name From ItemCategories ITC, ItemHierarchy ITH        
  Where ITC.[Level] = ITH.hierarchyid and ITH.hierarchyname = @Product_Hierarchy        
 End        
Else              
 Begin        
  Insert Into #TmpCat Select * From dbo.sp_SplitIn2Rows(@Category,@Delimeter)              
 End        

Insert Into #TempSale(CategoryName,ItemCode,ItemName,Qty,ECP,NetValue)
Select
 C.Category_Name,I.Product_Code,I.ProductName,
 Sum(IsNull(IDT.Quantity,0)),IsNull(B.ECP,0),Sum(IsNull(IDT.Amount,0))
From
 Items I,ItemCategories C,InvoiceAbstract IA,
 InvoiceDetail IDT,#Temp UM,Batch_Products B      
Where
 I.Product_Code = IDT.Product_Code       
 And IA.InvoiceId = IDT.InvoiceId      
 And I.CategoryId = C.CategoryId      
 And IDT.Product_Code = UM.Product_Code 
 And IDT.Batch_Code = B.Batch_Code
 And I.CategoryId = C.CategoryId      
 And C.CategoryId In (Select CategoryId From #TempCategory)      
 And IA.BeatId IN (Select BeatId From #TmpBeat)      
 And IA.InvoiceDate Between @FromDate And @ToDate     
 And VanNumber Is Not Null      
 And IsNull(IA.Status,0) & 128 = 0
 And IA.VanNumber = @VanNumber
 And IsNull(IDT.SalePrice,0) <> 0
 And IA.Status & 16 = 0
-- And IsNull(IA.NewReference,'') = ''
Group By
 C.Category_Name,I.Product_Code,I.ProductName,B.ECP

Insert Into #TempSale(CategoryName,ItemCode,ItemName,Qty,ECP,NetValue)
Select
 C.Category_Name,I.Product_Code,I.ProductName,
 Sum(IsNull(IDT.Quantity,0)),IsNull(VSD.ECP,0),Sum(IsNull(IDT.Amount,0))
From
 Items I,ItemCategories C,InvoiceAbstract IA,
 InvoiceDetail IDT,#Temp UM,VanStatementDetail VSD      
Where
 I.Product_Code = IDT.Product_Code       
 And IA.InvoiceId = IDT.InvoiceId      
 And I.CategoryId = C.CategoryId      
 And IDT.Product_Code = UM.Product_Code 
 And IDT.Batch_Code = VSD.[ID]
 And I.CategoryId = C.CategoryId      
 And C.CategoryId In (Select CategoryId From #TempCategory)      
 And IA.BeatId IN (Select BeatId From #TmpBeat)      
 And IA.InvoiceDate Between @FromDate And @ToDate     
 And VanNumber Is Not Null      
 And IsNull(IA.Status,0) & 128 = 0
 And IA.VanNumber = @VanNumber
 And IsNull(IDT.SalePrice,0) <> 0
 And IA.ReferenceNumber In (Select IsNull(cast(Id as nvarchar(255)),'')  From VanStatementDetail)  
-- And IsNull(IA.NewReference,'') <> ''
Group By
 C.Category_Name,I.Product_Code,I.ProductName,VSD.ECP

Insert Into #TempFree(CategoryName,ItemCode,ItemName,Qty,ECP,NetValue)
Select
 C.Category_Name,I.Product_Code,I.ProductName,
 Sum(IsNull(IDT.Quantity,0)),IsNull(B.ECP,0),Sum(IsNull(IDT.Amount,0))
From
 Items I,ItemCategories C,InvoiceAbstract IA,
 InvoiceDetail IDT,#Temp UM,Batch_Products B      
Where
 I.Product_Code = IDT.Product_Code       
 And IA.InvoiceId = IDT.InvoiceId      
 And I.CategoryId = C.CategoryId      
 And IDT.Product_Code = UM.Product_Code 
 And IDT.Batch_Code = B.Batch_Code  
 And I.CategoryId = C.CategoryId      
 And C.CategoryId In (Select CategoryId From #TempCategory)      
 And IA.BeatId IN (Select BeatId From #TmpBeat)      
 And IA.InvoiceDate Between @FromDate And @ToDate     
 And VanNumber Is Not Null      
 And IsNull(IA.Status,0) & 128 = 0     
 And IA.VanNumber = @VanNumber   
 And IsNull(IDT.SalePrice,0) = 0
 And IA.Status & 16 = 0
-- And IsNull(IA.NewReference,'') = ''
Group By
 C.Category_Name,I.Product_Code,I.ProductName,B.ECP

Insert Into #TempFree(CategoryName,ItemCode,ItemName,Qty,ECP,NetValue)
Select
 C.Category_Name,I.Product_Code,I.ProductName,
 Sum(IsNull(IDT.Quantity,0)),IsNull(VSD.ECP,0),Sum(IsNull(IDT.Amount,0))
From
 Items I,ItemCategories C,InvoiceAbstract IA,
 InvoiceDetail IDT,#Temp UM,VanStatementDetail VSD
Where
 I.Product_Code = IDT.Product_Code       
 And IA.InvoiceId = IDT.InvoiceId      
 And I.CategoryId = C.CategoryId      
 And IDT.Product_Code = UM.Product_Code 
 And IDT.Batch_Code = VSD.[ID] 
 And I.CategoryId = C.CategoryId      
 And C.CategoryId In (Select CategoryId From #TempCategory)      
 And IA.BeatId IN (Select BeatId From #TmpBeat)      
 And IA.InvoiceDate Between @FromDate And @ToDate     
 And VanNumber Is Not Null      
 And IsNull(IA.Status,0) & 128 = 0     
 And IA.VanNumber = @VanNumber   
 And IsNull(IDT.SalePrice,0) = 0
 And IA.ReferenceNumber In (Select IsNull(cast(Id as nvarchar(255)),'')  From VanStatementDetail)  
-- And IsNull(IA.NewReference,'') <> ''
Group By
 C.Category_Name,I.Product_Code,I.ProductName,VSD.ECP

Select [CategoryName] = CategoryName, 
 [ItemCode] = ItemCode, [ItemName] = ItemName, 
 [Qty] = sum(Qty), [ECP] = ECP, [NetValue] = sum(NetValue)
Into #TempSaleone From #TempSale
Group By CategoryName, ItemCode, ItemName, ECP

Select [CategoryName] = CategoryName, 
 [ItemCode] = ItemCode, [ItemName] = ItemName, 
 [Qty] = sum(Qty), [ECP] = ECP, [NetValue] = sum(NetValue)
Into #TempFreeone From #TempFree
Group By CategoryName, ItemCode, ItemName, ECP

Select
 IsNull(TS.ItemCode,''),"Category Name" = IsNull(TS.CategoryName,''),
 "Item Code" = IsNull(TS.ItemCode,''),"Item Name" = IsNull(TS.ItemName,''),
 "Quantity In UOM1" =
  Cast((Substring(dbo.GetReportQtyAsMultiple_ITC(TS.ItemCode,
  Sum(IsNull(TS.Qty,0) ),3),1,CharIndex(',', dbo.GetReportQtyAsMultiple_ITC(TS.ItemCode,Sum(IsNull(TS.Qty,0) ),3)) -1)) As Decimal(18,6)),
 "UOM1 Description" =
  Substring(dbo.GetReportQtyAsMultiple_ITC(TS.ItemCode,Sum(IsNull(TS.Qty,0) ),3),CharIndex(',',dbo.GetReportQtyAsMultiple_ITC(TS.ItemCode,Sum(IsNull(TS.Qty,0) ),3)) +1 ,
  DataLength(dbo.GetReportQtyAsMultiple_ITC(TS.ItemCode,Sum(IsNull(TS.Qty,0) ),3)) - CharIndex(',', dbo.GetReportQtyAsMultiple_ITC(TS.ItemCode,Sum(IsNull(TS.Qty,0) ),3)) ),
 "Quantity in UOM2" =
  Cast((Substring(dbo.GetReportQtyAsMultiple_ITC(TS.ItemCode,Sum(IsNull(TS.Qty,0) ),2),1,CharIndex(',', dbo.GetReportQtyAsMultiple_ITC(TS.ItemCode,Sum(IsNull(TS.Qty,0) ),2)) -1)) As Decimal(18,6)),
 "UOM 2 Description" = 
  Substring(dbo.GetReportQtyAsMultiple_ITC(TS.ItemCode,Sum(IsNull(TS.Qty,0) ),2),CharIndex(',',dbo.GetReportQtyAsMultiple_ITC(TS.ItemCode,Sum(IsNull(TS.Qty,0) ),2)) +1 ,
  DataLength(dbo.GetReportQtyAsMultiple_ITC(TS.ItemCode,Sum(IsNull(TS.Qty,0) ),2)) - CharIndex(',', dbo.GetReportQtyAsMultiple_ITC(TS.ItemCode,Sum(IsNull(TS.Qty,0) ),2)) ),
 "Free Qty" = Cast(Sum(IsNull(TF.Qty,0)/IsNull(T.UOMConv,0)) As Decimal(18,6)),
 "Free Qty UOM" = IsNull(T.[Description],0),
 "Weight(Kg)" = Cast(Sum((IsNull(TS.Qty,0) + IsNull(TF.Qty,0)) * IsNull(ITS.ConversionFactor,0)) As Decimal(18,6)),
 "UOM 2 MRP (%c)" = Cast(IsNull(TS.ECP,0) * IsNull(ITS.UOM2_Conversion,0) As Decimal(18,6)),
 "Value (%c)" = Cast(Sum(TS.NetValue)As Decimal(18,6))
From
 #Temp T
 Inner Join #TempSaleone TS On T.Product_Code = TS.ItemCode
 Left Outer Join #TempFreeone TF On TS.ItemCode = TF.ItemCode
 Inner Join Items ITS On TS.ItemCode = ITS.Product_Code
 Group By
 T.[Description],TS.ItemCode,TS.CategoryName,TS.ItemName,TS.ECP, ITS.UOM2_Conversion

Union All

Select
 IsNull(TF.ItemCode,''),"Category Name" = IsNull(TF.CategoryName,''),
 "Item Code" = IsNull(TF.ItemCode,''),"Item Name" = IsNull(TF.ItemName,''),
 "Quantity In UOM1" = Cast(0 As Decimal(18, 6)),
--   Substring(dbo.GetReportQtyAsMultiple_ITC(TF.ItemCode,
--   Sum(IsNull(TF.Qty,0)),3),1,CharIndex(',', dbo.GetReportQtyAsMultiple_ITC(TF.ItemCode,Sum(IsNull(TF.Qty,0)),3)) -1),
 "UOM1 Description" =
  Substring(dbo.GetReportQtyAsMultiple_ITC(TF.ItemCode,Sum(IsNull(TF.Qty,0)),3),CharIndex(',',dbo.GetReportQtyAsMultiple_ITC(TF.ItemCode,Sum(IsNull(TF.Qty,0)),3)) +1 ,
  DataLength(dbo.GetReportQtyAsMultiple_ITC(TF.ItemCode,Sum(IsNull(TF.Qty,0)),3)) - CharIndex(',', dbo.GetReportQtyAsMultiple_ITC(TF.ItemCode,Sum(IsNull(TF.Qty,0)),3)) ),
 "Quantity in UOM2" = Cast(0 As Decimal(18, 6)),
--  Substring(dbo.GetReportQtyAsMultiple_ITC(TF.ItemCode,Sum(IsNull(TF.Qty,0)),2),1,CharIndex(',', dbo.GetReportQtyAsMultiple_ITC(TF.ItemCode,Sum(IsNull(TF.Qty,0)),2)) -1),
 "UOM 2 Description" = 
  Substring(dbo.GetReportQtyAsMultiple_ITC(TF.ItemCode,Sum(IsNull(TF.Qty,0)),2),CharIndex(',',dbo.GetReportQtyAsMultiple_ITC(TF.ItemCode,Sum(IsNull(TF.Qty,0)),2)) +1 ,
  DataLength(dbo.GetReportQtyAsMultiple_ITC(TF.ItemCode,Sum(IsNull(TF.Qty,0)),2)) - CharIndex(',', dbo.GetReportQtyAsMultiple_ITC(TF.ItemCode,Sum(IsNull(TF.Qty,0)),2)) ),
 "Free Qty" = Sum(IsNull(TF.Qty,0)/T.UOMConv),
 "Free Qty UOM" = IsNull(T.[Description],0),
 "Weight(Kg)" = Sum(IsNull(TF.Qty,0) * IsNull(ITS.ConversionFactor,0)),
 "UOM 2 MRP (%c)" = Sum(IsNull(TF.ECP,0) * IsNull(ITS.UOM2_Conversion,0)),
 "Value (%c)" = Sum(TF.NetValue)
From
 #Temp T,#TempFreeone TF,Items ITS
Where 
 T.Product_Code = TF.ItemCode
 And TF.ItemCode = ITS.Product_Code
 And TF.ItemCode Not In (Select ItemCode From #TempSaleone)
Group By
 T.[Description],TF.ItemCode,TF.CategoryName,TF.ItemName,TF.ECP

Drop Table #TempCategory  
Drop Table #TmpBeat  
Drop Table #Temp  
Drop Table #TmpCat
Drop Table #TempSale
Drop Table #TempFree

