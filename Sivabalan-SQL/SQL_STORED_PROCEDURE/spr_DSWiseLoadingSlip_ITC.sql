CREATE Procedure spr_DSWiseLoadingSlip_ITC    
(        
 @SalesMan NVarChar(4000),    
 @Beat NVarChar(4000),        
 @FromDate DateTime,    
 @ToDate DateTime,
 @DocPrefix NVarChar(100),        
 @FromInvoice NVarChar(510),    
 @ToInvoice NVarChar(510),    
 @UOM nVarChar(20)     
)                  
As                  
Set DateFormat DMY
Declare @Delimeter  Char(1), @IPrefix as nVarchar(255) ,@IAPrefix as nVarchar(255)                          
Set @Delimeter=Char(15)    
                  
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)      
exec sp_CatLevelwise_ItemSorting    
    
Create Table #DocPreFix (DocPreFix nVarChar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create Table #TmpSalesMan(SalesManId Int)    
Create Table #TmpBeat(BeatID Int)    
  
Create Table #TempInvNo(SalInvNo int)  
Create Table #TempDocID(DocID int)  
Create Table #TmpSRInvoiceID(GSTReference NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    

Create Table #temp(Product_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,  
     Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
     Sub_Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
     Market_SKU nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)  
  
Insert Into #temp(Product_Code, Category, Sub_Category, Market_SKU)  
Select  
 Distinct I.Product_Code, IC1.Category_Name,  
 IC2.Category_Name, IC3.Category_Name    
From  
 ItemCategories IC1, ItemCategories IC2, ItemCategories IC3, Items I  
Where  
 IC1.CategoryID = IC2.ParentID  
 And IC2.CategoryID = IC3.ParentID   
 And IC1.Level = 2  
 And I.CategoryID = IC3.CategoryID  
Order By  
 I.Product_Code, IC1.Category_Name, IC2.Category_Name, IC3.Category_Name  
    
Create Table #TempSale        
(        
 ItemCode NVarChar(30)COLLATE SQL_Latin1_General_CP1_CI_AS,        
 ItemName NVarChar(510)COLLATE SQL_Latin1_General_CP1_CI_AS,        
 BatchNo NVarChar(256)COLLATE SQL_Latin1_General_CP1_CI_AS,        
 Qty Decimal(18,6),    
 Free Decimal(18,6),    
 SchDisc Decimal(18,6),    
 Disc Decimal(18,6),    
 Tax Decimal(18,6),    
 NetValue Decimal(18,6),    
 Conversion decimal(18,6),    
-- ECP Decimal(18,6),    
 MRPPerPack Decimal(18,6),
 SRSQty Decimal(18,6),    
 SRDQty Decimal(18,6)    
)    
  
Select @IPrefix = Prefix from voucherprefix where tranid = N'INVOICE'  
Select @IAPrefix = Prefix from voucherprefix where tranid = N'INVOICE AMENDMENT'                
if @DocPreFix = '%'    
begin    
 Insert Into #DocPreFix     
 Select DocumentType From TransactionDocNumber     
 Where TransactionType In (1, 3)    
 Insert Into #DocPreFix Values ('')    
End    
Else    
 Insert Into #DocPreFix    
 Select DocumentType From TransactionDocNumber    
 Where TransactionType = 1 And DocumentType = @DocPreFix    
     
If @SalesMan = '%'                  
 Insert Into #TmpSalesMan                   
 Select Distinct SalesManID From SalesMan                  
Else                  
 Insert Into #TmpSalesMan                   
 Select Distinct SalesManId From SalesMan     
 Where SalesMan_Name In (Select * From Dbo.sp_SplitIn2Rows(@SalesMan,@Delimeter))    
                  

If @Beat = '%'                   
 Insert Into #TmpBeat                  
 Select Distinct BeatId From Beat                  
Else                  
 Insert Into #TmpBeat                   
 Select BeatId From Beat Where Description In ( Select * From Dbo.sp_SplitIn2Rows(@Beat,@Delimeter))                                      
                  
IF @FromInvoice = '%' SET @FromInvoice = '0'                    
IF @ToInvoice = '%' SET @ToInvoice = '2147483647'                    
  --Added for GST begin  
Insert Into #TmpSRInvoiceID  
Select IsNull(GSTFullDocID,0)
From InvoiceAbstract IA  
Where        
 Isnull(IA.Status,0) & 128 = 0  
 And Isnull(IA.InvoiceType,0) in (1,3)  
 And IA.InvoiceDate Between @FromDate And @ToDate  
 And ISNULL(GSTDocID,0) Between dbo.GetTrueVal(@FromInvoice) And dbo.GetTrueVal(@ToInvoice)                  
 And Isnull(IA.DocSerIAlType,'') in (Select DocPrefix from #DocPreFix)       
 And Isnull(IA.SalesmanID,0) in (Select SalesManId From #TmpSalesMan)                  
 And Isnull(IA.BeatId,0) In (Select BeatId From #TmpBeat)  
 And IsNull(IA.GSTFlag,0) = 1  
 
 --Added for GST end
Insert Into #TempInvNo  
Select DocumentID
From InvoiceAbstract IA  
Where        
 Isnull(IA.Status,0) & 128 = 0  
 And Isnull(IA.InvoiceType,0) in (1,3)  
 And IA.InvoiceDate Between @FromDate And @ToDate  
 And dbo.GetTrueVal(Case When (IsNull(Ia.DocReference,'') = ''  Or PATINDEX(N'%[^0-9]%',Reverse(IsNull(IA.DocReference,''))) < 1) Then IA.DocReference    
 Else Reverse(Left(Reverse(IsNull(IA.DocReference,'')),PATINDEX(N'%[^0-9]%',Reverse(IsNull(IA.DocReference,'')))-1)) End)     
 Between dbo.GetTrueVal(@FromInvoice) And dbo.GetTrueVal(@ToInvoice)                  
 And Isnull(IA.DocSerIAlType,'') in (Select DocPrefix from #DocPreFix)       
 And Isnull(IA.SalesmanID,0) in (Select SalesManId From #TmpSalesMan)                  
 And Isnull(IA.BeatId,0) In (Select BeatId From #TmpBeat) 
 And IsNull(IA.GSTFlag,0) = 0 

Insert Into #TempDocID  
Select  Isnull(dbo.GetTrueVal(CollectionDetail.OriginalID),0) From CollectionDetail, InvoiceAbstract   
 Where Isnull(InvoiceAbstract.Status,0) & 128 = 0  
 And ISnull(InvoiceAbstract.PaymentDetails,0)=CollectionDetail.CollectionID        
 And Isnull(CollectionDetail.DocumentType,0)=1 And Isnull(InvoiceAbstract.InvoiceType,0) in (1,3)        
 And InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE  
  And IsNull(InvoiceAbstract.GSTFlag,0) = 0 

Insert Into #TmpSRInvoiceID 
Select  Isnull(CollectionDetail.OriginalID,'') From CollectionDetail, InvoiceAbstract   
 Where Isnull(InvoiceAbstract.Status,0) & 128 = 0  
 And ISnull(InvoiceAbstract.PaymentDetails,0)=CollectionDetail.CollectionID        
 And Isnull(CollectionDetail.DocumentType,0)=1 And Isnull(InvoiceAbstract.InvoiceType,0) in (1,3)        
 And InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE 
 And IsNull(InvoiceAbstract.GSTFlag ,0) = 1
 
Insert Into #TempSale    
-- (ItemCode,ItemName,BatchNo,Qty,Free,SchDisc,Disc,Tax,NetValue,Conversion,ECP,SRSQty,SRDQty)    
  (ItemCode,ItemName,BatchNo,Qty,Free,SchDisc,Disc,Tax,NetValue,Conversion,MRPPerPack,SRSQty,SRDQty)    
Select    
 I.Product_Code,    
 ProductName,    
 IDT.Batch_Number,        
 Sum(Case IA.InvoiceType when 4 then 0 Else (Case IDT.SalePrice When 0 then 0 Else IsNull(IDT.Quantity,0) End) End),    
 Sum(Case IA.InvoiceType When 4 Then 0 Else (Case IDT.SalePrice When 0 Then IsNull(IDT.Quantity,0) Else 0 End) End),    
 Sum(Case IA.InvoiceType When 4 Then 0 Else (IDT.SchemeDiscAmount+IDT.SplCatDiscAmount)+((((IDT.Quantity*IDT.SalePrice)-IDT.DiscountValue)* IA.SchemeDiscountPercentage)/100) End),    
 Sum(Case IA.InvoiceType When 4 Then 0 Else (IDT.DiscountValue-(IDT.SchemeDiscAmount+IDT.SplCatDiscAmount))+((((IDT.Quantity*IDT.SalePrice)-IDT.DiscountValue) * (IA.DiscountPercentage+IA.AdditionalDiscount-IA.SchemeDiscountPercentage))/100) End),    
 Sum(Case IA.InvoiceType When 4 Then 0 Else (IDT.STPayable+IDT.CSTPayable) End),     
 Sum(Case IA.InvoiceType When 4 Then 0 Else IsNull(IDT.Amount,0) End),    
 Max(I.ConversionFactor),    
 --B.ECP,
--(Case Max(isNull(IDT.Batch_Code,0)) When 0 Then
--		(Select Max(Ecp) From Batch_Products  Where Product_Code = I.Product_Code)
--      Else
--		(Select Max(Ecp) From Batch_Products  Where Product_Code = I.Product_Code 
--		And Batch_Number = IDT.Batch_Number And Batch_Code = Max(isNull(IDT.Batch_Code,0)))
--End) 'ECP',
--(Case Max(isNull(IDT.Batch_Code,0)) When 0 Then
--		(Select Max(MRPPerPack) From Batch_Products  Where Product_Code = I.Product_Code)
--      Else
--		(Select Max(MRPPerPack) From Batch_Products  Where Product_Code = I.Product_Code 
--		And Batch_Number = IDT.Batch_Number And Batch_Code = Max(isNull(IDT.Batch_Code,0)))
--End) 'MRPPerPack',

Case IsNull(IDT.MRPPerPack,0) when 0 Then Isnull(I.MRPPerPack,0) Else IsNull(IDT.MRPPerPack,0) End 'MRPPerPack',
 
 Sum(Case IA.InvoiceType When 4 Then (Case IA.Status & 32 When 0 then IsNull(IDT.Quantity,0) Else 0 End) Else 0 End),    
 Sum(Case IA.InvoiceType When 4 Then (Case IA.Status & 32 When 0 Then 0 Else IsNull(IDT.Quantity,0) End) Else 0 End)    
From        
 Items I, InvoiceAbstract IA,InvoiceDetail IDT--,Batch_Products B                   
Where        
I.Product_Code = IDT.Product_Code                  
And IA.InvoiceId = IDT.InvoiceId            
--And B.Batch_Code = IDT.Batch_Code
And IA.InvoiceDate Between @FromDate And @ToDate                
And dbo.GetTrueVal(Case When (IsNull(Ia.DocReference,'') = ''  Or PATINDEX(N'%[^0-9]%',Reverse(IsNull(IA.DocReference,''))) < 1) Then IA.DocReference    
Else Reverse(Left(Reverse(IsNull(IA.DocReference,'')),PATINDEX(N'%[^0-9]%',Reverse(IsNull(IA.DocReference,'')))-1)) End)     
Between dbo.GetTrueVal(@FromInvoice) And dbo.GetTrueVal(@ToInvoice)                  
And Isnull(IA.DocSerIAlType,'') in (Select DocPrefix from #DocPreFix)       
And IA.SalesmanID in (Select SalesManId From #TmpSalesMan)                  
And IA.BeatId In (Select BeatId From #TmpBeat)                  
And (
	(IA.InvoiceType in (1,3)) 
	OR 
	( IA.InvoiceType = 4 And IsNull(ReferenceNumber,'')<>'' And IA.ReferenceNumber In (Select GSTReference From #TmpSRInvoiceID Where GSTReference = IA.ReferenceNumber) )
	OR
	(IA.GSTFullDocID in (Select GSTReference From #TmpSRInvoiceID Where GSTReference = IA.ReferenceNumber))
	OR 
	(IA.InvoiceType = 4 And IsNull(ReferenceNumber,'')<>'' And dbo.GetTrueVal_ITC(ReferenceNumber) in (Select SalInvNo from #TempInvNo where SalInvNo = dbo.GetTrueVal_ITC(ReferenceNumber)) Or DocumentID In(Select DocID From #TempDocID) )
	)  
And IA.Status & 128 = 0        
And IA.Status & 16 = 0        
Group By    
I.Product_Code, ProductName, IDT.Batch_Number,ECP,IDT.MRPPerPack,I.MRPPerPack    
     
Insert Into #TempSale    
-- (ItemCode,ItemName,BatchNo,Qty,Free,SchDisc,Disc,Tax,NetValue,Conversion,ECP,SRSQty,SRDQty)    
  (ItemCode,ItemName,BatchNo,Qty,Free,SchDisc,Disc,Tax,NetValue,Conversion,MRPPerPack,SRSQty,SRDQty)    
Select        
 I.Product_Code,    
 ProductName,    
 IDT.Batch_Number,        
 Sum(Case IA.InvoiceType when 4 then 0 Else (Case IDT.SalePrice When 0 then 0 Else IsNull(IDT.Quantity,0) End) End),    
 Sum(Case IA.InvoiceType When 4 Then 0 Else (Case IDT.SalePrice When 0 Then IsNull(IDT.Quantity,0) Else 0 End) End),    
 Sum(Case IA.InvoiceType When 4 Then 0 Else (IDT.SchemeDiscAmount+IDT.SplCatDiscAmount)+((((IDT.Quantity*IDT.SalePrice)-IDT.DiscountValue)* IA.SchemeDiscountPercentage)/100) End),    
 Sum(Case IA.InvoiceType When 4 Then 0 Else (IDT.DiscountValue-(IDT.SchemeDiscAmount+IDT.SplCatDiscAmount))+((((IDT.Quantity*IDT.SalePrice)-IDT.DiscountValue) * (IA.DiscountPercentage+IA.AdditionalDiscount-IA.SchemeDiscountPercentage))/100) End),    
 Sum(Case IA.InvoiceType When 4 Then 0 Else (IDT.STPayable+IDT.CSTPayable) End),     
 Sum(Case IA.InvoiceType When 4 Then 0 Else IsNull(IDT.Amount,0) End),    
 Max(I.ConversionFactor),    
-- VSD.ECP,    
 VSD.MRPPerPack,    
 Sum(Case IA.InvoiceType When 4 Then (Case IA.Status & 32 When 0 then IsNull(IDT.Quantity,0) Else 0 End) Else 0 End),    
 Sum(Case IA.InvoiceType When 4 Then (Case IA.Status & 32 When 0 Then 0 Else IsNull(IDT.Quantity,0) End) Else 0 End)     
From        
 Items I, InvoiceAbstract IA,InvoiceDetail IDT,VanStatementDetail VSD    
Where        
 I.Product_Code = IDT.Product_Code    
 And IA.InvoiceId = IDT.InvoiceId    
 And VSD.[ID] = IDT.Batch_Code    
-- And I.Product_Code = VSD.Product_Code    
 And IA.InvoiceDate Between @FromDate And @ToDate    
 And dbo.GetTrueVal(Case When (IsNull(Ia.DocReference,'') = ''  Or PATINDEX(N'%[^0-9]%',Reverse(IsNull(IA.DocReference,''))) < 1) Then IA.DocReference    
 Else Reverse(Left(Reverse(IsNull(IA.DocReference,' ')),PATINDEX(N'%[^0-9]%',Reverse(IsNull(IA.DocReference,' ')))-1)) End)     
 Between dbo.GetTrueVal(@FromInvoice) And dbo.GetTrueVal(@ToInvoice)                  
 And Isnull(IA.DocSerIAlType,'') in (Select DocPrefix from #DocPreFix)    
 And IA.SalesmanID in (Select SalesManId From #TmpSalesMan)                  
 And IA.BeatId In (Select BeatId From #TmpBeat)                  
 And (
	(IA.InvoiceType in (1,3)) 
	OR 
	( IA.InvoiceType = 4 And IsNull(ReferenceNumber,'')<>'' And IA.ReferenceNumber In (Select GSTReference From #TmpSRInvoiceID Where GSTReference = IA.ReferenceNumber) )
	OR
	(IA.GSTFullDocID in (Select GSTReference From #TmpSRInvoiceID Where GSTReference = IA.ReferenceNumber))
	OR
	(IA.InvoiceType = 4 And IsNull(ReferenceNumber,'')<>'' And dbo.GetTrueVal_ITC(ReferenceNumber)in (Select SalInvNo from #TempInvNo where SalInvNo = dbo.GetTrueVal_ITC(ReferenceNumber)) Or DocumentID In(Select DocId From #TempDocID) )
	)  
 And IA.Status & 128 = 0        
And IA.Status & 16 <> 0        
 And IA.ReferenceNumber In (Select IsNull(cast(DocSerial as nvarchar(255)),'')  From VanStatementDetail)          
Group By    
-- I.Product_Code, ProductName, IDT.Batch_Number, VSD.ECP     
I.Product_Code, ProductName, IDT.Batch_Number, VSD.MRPPerPack     

If @UOM = 'UOM1 & UOM2'    
 Select "ID" = IsNull(TS.ItemCode,''), 
"Category" = temp.Category, "Sub Category" = temp.Sub_Category, 
 "Item Code" = IsNull(TS.ItemCode,''),    
 "Item Name" = IsNull(TS.ItemName,''),    
 "Batch" = IsNull(TS.BatchNo,''),    
 "Qty In CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(TS.ItemCode,Sum(IsNull(TS.Qty,0)),1),    
 "Qty In PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(TS.ItemCode,Sum(IsNull(TS.Qty,0)),2),    
 "Free Qty In PAC" = Sum(IsNull(Free,0)) / (Case Max(I.UOM2_Conversion) When 0 Then 1 Else Max(I.UOM2_Conversion) End),    
 "Total CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(TS.ItemCode,Sum(IsNull(TS.Qty,0)+IsNull(TS.Free,0)),1),    
 "Total PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(TS.ItemCode,Sum(IsNull(TS.Qty,0)+IsNull(TS.Free,0)),2),    
 "Sch. Disc" = Sum(IsNull(SchDisc,0)),"Discount" = Sum(IsNull(Disc,0)),"VAT/Tax" = Sum(IsNull(Tax,0)),    
 "Total Value" = Sum(IsNull(NetValue,0)),"Weight(Kg)" = Sum(IsNull(Qty,0)+IsNull(Free,0)) * Max(TS.Conversion),    
 --"MRP Per PAC" = Cast(TS.ECP * IsNull(Max(I.UOM2_Conversion),0) AS Decimal(18,6)), 
 "MRP Per Pack" = Max(isnull(TS.MRPPerPack,0)),
 "Return Salable PAC" = Sum(IsNull(SRSQty,0)) / (Case Max(I.UOM2_Conversion) When 0 Then 1 Else Max(I.UOM2_Conversion) End),    
 "Return Damage PAC"  = Sum(IsNull(SRDQty,0)) / (Case Max(I.UOM2_Conversion) When 0 Then 1 Else Max(I.UOM2_Conversion) End)    
 From #TempSale TS , Items I,#tempCategory1 ISort , #temp temp   
 Where I.Product_Code = TS.ItemCode    
  And   I.CategoryID = ISort.CategoryID 
	and I.Product_Code = temp.Product_Code
-- Group By TS.ItemCode,TS.ItemName,TS.BatchNo,TS.ECP,ISort.IDS, temp.Category, temp.Sub_Category    
Group By TS.ItemCode,TS.ItemName,TS.BatchNo,TS.MRPPerPack,ISort.IDS, temp.Category, temp.Sub_Category, TS.MRPPerPack    
 Order By ISort.IDS
Else    
 Select "ID" = IsNull(TS.ItemCode,''), 
"Category" = temp.Category, "Sub Category" = temp.Sub_Category,
"Item Code" = IsNull(TS.ItemCode,''),    
 "Item Name" = IsNull(TS.ItemName,''),    
 "UOM" = (Select Description from UOM where UOM = (Case @UOM When 'UOM1' Then Max(I.UOM1) When 'UOM2' Then Max(I.UOM2) Else Max(I.UOM) End)),    
 "Batch" = IsNull(TS.BatchNo,''),    
 "Qty" = Sum(IsNull(Qty,0)) / (Case @UOM When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 then 1 Else Max(I.UOM1_Conversion) End) When 'UOM2' Then (Case Max(I.UOM2_Conversion) When 0 Then 1 Else Max(I.UOM2_Conversion) End) Else 1 End),    
 "Free" = Sum(IsNull(Free,0)) / (Case @UOM When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 then 1 Else Max(I.UOM1_Conversion) End) When 'UOM2' Then (Case Max(I.UOM2_Conversion) When 0 Then 1 Else Max(I.UOM2_Conversion) End) Else 1 End),     
 "Total Qty" = Sum(IsNull(Qty,0)+IsNull(Free,0)) / (Case @UOM When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 then 1 Else Max(I.UOM1_Conversion) End) When 'UOM2' Then (Case Max(I.UOM2_Conversion) When 0 Then 1 Else Max(I.UOM2_Conversion) End) Else 1 
  
End),    
 "Sch. Disc" = Sum(IsNull(SchDisc,0)),"Discount" = Sum(IsNull(Disc,0)),"VAT/Tax" = Sum(IsNull(Tax,0)),    
 "Total Value" = Sum(IsNull(NetValue,0)),"Weight(Kg)" = Sum(IsNull(Qty,0)+IsNull(Free,0)) * Max(TS.Conversion),    
 --"MRP Per PAC" = Cast(TS.ECP * IsNull(Max(I.UOM2_Conversion),0) AS Decimal(18,6)),    
 "MRP Per Pack" = Max(isnull(TS.MRPPerPack,0)),   
 "Return Salable" = Sum(IsNull(SRSQty,0)) / (Case @UOM When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 then 1 Else Max(I.UOM1_Conversion) End) When 'UOM2' Then (Case Max(I.UOM2_Conversion) When 0 Then 1 Else Max(I.UOM2_Conversion) End) Else 1 End),  
  
 "Return Damaged" = Sum(IsNull(SRDQty,0)) / (Case @UOM When 'UOM1' Then (Case Max(I.UOM1_Conversion) When 0 then 1 Else Max(I.UOM1_Conversion) End) When 'UOM2' Then (Case Max(I.UOM2_Conversion) When 0 Then 1 Else Max(I.UOM2_Conversion) End) Else 1 End)   
 
 From #TempSale TS , Items I,#tempCategory1 ISort  , #temp temp   
 Where I.Product_Code = TS.ItemCode    
  And   I.CategoryID = ISort.CategoryID 
and I.Product_Code = temp.Product_Code    
-- Group By TS.ItemCode,TS.ItemName,TS.BatchNo,TS.ECP,ISort.IDS,temp.Category, temp.Sub_Category  
Group By TS.ItemCode,TS.ItemName,TS.BatchNo,TS.MRPPerPack,ISort.IDS,temp.Category, temp.Sub_Category,TS.MRPPerPack  
 Order By ISort.IDS  
  
  
    
Drop Table #DocPreFix    
Drop Table #TmpSalesMan    
Drop Table #TmpBeat    
Drop Table #TempSale    
Drop Table #tempCategory1    
Drop Table #TempInvNo  
Drop Table #TempDocID  
Drop Table #temp

Drop Table #TmpSRInvoiceID


