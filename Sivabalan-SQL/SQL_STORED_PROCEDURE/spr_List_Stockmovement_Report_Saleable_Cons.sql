CREATE procedure [dbo].[spr_List_Stockmovement_Report_Saleable_Cons]  
(
 @BranchName NVarChar(4000),
	@Mfr NVarChar(2550),          
	@Division NVarChar(2550),  
	@ItemCode NVarChar(2550),
	@UOM NVarChar(255),  
	@FromDate DateTime,  
	@ToDate DateTime  
)  
As              
Declare @FromDateBh DateTime
Declare @ToDateBh DateTime

Set @FromDateBh = dbo.StripDateFromTime(@FromDate)      
Set @ToDateBh = dbo.StripDateFromTime(@ToDate)      

Declare @Delimeter As Char(1)        
Set @Delimeter=Char(15)        

Create Table #TmpMfr(Manufacturer NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
if @Mfr=N'%'         
   Insert InTo #TmpMfr Select Manufacturer_Name From Manufacturer        
Else        
   Insert InTo #TmpMfr Select * From dbo.sp_SplitIn2Rows(@Mfr,@Delimeter)        

Create Table #TmpDiv(Division NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
if @Division=N'%'        
   Insert InTo #TmpDiv Select BrandName From Brand        
Else        
   Insert InTo #TmpDiv Select * From dbo.sp_SplitIn2Rows(@Division,@Delimeter)        

Create Table #TmpProd(Product_Code NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
if @ItemCode = N'%'  
 Insert InTo #TmpProd Select Product_Code From Items  
Else  
 Insert InTo #TmpProd Select * From dbo.sp_SplitIn2Rows(@ItemCode,@Delimeter)  

CREATE Table #TmpBranch(CompanyId NVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)        
If @BranchName = N'%'            
 Insert InTo #TmpBranch Select Distinct CompanyId From Reports  
Else            
 Insert InTo #TmpBranch Select ForumID From WareHouse Where WareHouse_Name In(Select * From dbo.sp_SplitIn2Rows(@BranchName,@Delimeter))  
      
Declare @Next_Date DateTime          
Declare @Corrected_Date DateTime          
Set @Corrected_Date = Cast(DatePart(dd, @ToDateBh) AS NVarChar) + N'/'+ Cast(DatePart(mm, @ToDateBh) as NVarChar) + N'/' + Cast(DatePart(yyyy, @ToDateBh) AS NVarChar)          
Set  @Next_Date = Cast(DatePart(dd, GetDate()) AS NVarChar) + N'/'+ Cast(DatePart(mm, GetDate()) as NVarChar) + N'/'+ Cast(DatePart(yyyy, GetDate()) AS NVarChar)          

Create Table #TmpStkMvtItem
(
	ItemCodeH NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ItemCodeV NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ItemName NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CategoryName NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	OpeningQty Decimal(18,6),
	FreeOpengQty Decimal(18,6),DamageOpengQty Decimal(18,6),TotalOpengQty Decimal(18,6),
	OpeningVal Decimal(18,6),DamageOpengVal Decimal(18,6),TotalOpengVal Decimal(18,6),
	Purchase Decimal(18,6),FreePurchase Decimal(18,6),SalesRrnSal Decimal(18,6),
	SalesRrnDam Decimal(18,6),TotalIssues Decimal(18,6),SaleableIsus Decimal(18,6),
	FreeIssues Decimal(18,6),SalesVal Decimal(18,6),PurchaseRrn Decimal(18,6),
	Adjustments Decimal(18,6),STO Decimal(18,6),STI Decimal(18,6),
	StkDes Decimal(18,6),OnHanQty Decimal(18,6),OnHanFreQty Decimal(18,6),
	OnHandDamQty Decimal(18,6),TotalOnHanQty Decimal(18,6),OnHanVal Decimal(18,6),
	OnHanDamVal Decimal(18,6),TotalOnHanVal Decimal(18,6),PendingOrd Decimal(18,6),
	ForumCod NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
)

Create Table #TmpStkMvtItemUnion
(
	ItemCodeH NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ItemCodeV NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ItemName NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CategoryName NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	UOMDescription NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	OpeningQty Decimal(18,6),FreeOpengQty Decimal(18,6),DamageOpengQty Decimal(18,6),
	TotalOpengQty Decimal(18,6),OpeningVal Decimal(18,6),DamageOpengVal Decimal(18,6),
	TotalOpengVal Decimal(18,6),Purchase Decimal(18,6),FreePurchase Decimal(18,6),
	SalesRrnSal Decimal(18,6),SalesRrnDam Decimal(18,6),TotalIssues Decimal(18,6),
	SaleableIsus Decimal(18,6),FreeIssues Decimal(18,6),SalesVal Decimal(18,6),
	PurchaseRrn Decimal(18,6),Adjustments Decimal(18,6),STO Decimal(18,6),
	STI Decimal(18,6),StkDes Decimal(18,6),OnHanQty Decimal(18,6),OnHanFreQty Decimal(18,6),
	OnHandDamQty Decimal(18,6),TotalOnHanQty Decimal(18,6),OnHanVal Decimal(18,6),
	OnHanDamVal Decimal(18,6),TotalOnHanVal Decimal(18,6),PendingOrd Decimal(18,6),
	ForumCod NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
)

Insert InTo #TmpStkMvtItem
(
	ItemCodeH,ItemCodeV,ItemName,CategoryName,OpeningQty,FreeOpengQty,
	DamageOpengQty,TotalOpengQty,OpeningVal,DamageOpengVal,TotalOpengVal,Purchase,FreePurchase,
	SalesRrnSal,SalesRrnDam,TotalIssues,SaleableIsus,FreeIssues,SalesVal,PurchaseRrn,Adjustments,
	STO,STI,StkDes,OnHanQty,OnHanFreQty,OnHandDamQty,TotalOnHanQty,OnHanVal,OnHanDamVal,
	TotalOnHanVal,PendingOrd,ForumCod
)
Select  
 Items.Product_Code,           
	"Item Code" = Items.Product_Code,           
	"Item Name" = ProductName,           
	"Category Name" = ItemCategories.Category_Name,  
	"Opening Quantity" = IsNull(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0) - IsNull(Free_Saleable_Quantity, 0),  
	"Free Opening Quantity" = IsNull(Free_Saleable_Quantity, 0),
	"Damage Opening Quantity" = IsNull(Damage_Opening_Quantity, 0),
	"Total Opening Quantity" = IsNull(Opening_Quantity, 0),
	"(%c) Opening Value" = IsNull(Opening_Value, 0) - IsNull(Damage_Opening_Value, 0),          
	"(%c) Damage Opening Value" = IsNull(Damage_Opening_Value, 0),   
	"(%c) Total Opening Value" = IsNull(Opening_Value, 0),  
	"Purchase" =   
		(IsNull((Select Sum(QuantityReceived - QuantityRejected)           
		From GRNAbstract, GRNDetail           
		Where GRNAbstract.GRNID = GRNDetail.GRNID           
		And GRNDetail.Product_Code = Items.Product_Code           
		And dbo.StripDateFromTime(GRNAbstract.GRNDate) Between @FromDateBh And @ToDateBh And           
		(GRNAbstract.GRNStatus & 64) = 0 And          
		(GRNAbstract.GRNStatus & 32) = 0 ), 0)),
	"Free Purchase" =   
		(IsNull((Select Sum(IsNull(FreeQty, 0))           
		From GRNAbstract, GRNDetail           
		Where GRNAbstract.GRNID = GRNDetail.GRNID           
		And GRNDetail.Product_Code = Items.Product_Code           
		And dbo.StripDateFromTime(GRNAbstract.GRNDate) Between @FromDateBh And @ToDateBh And
		(GRNAbstract.GRNStatus & 64) = 0 And        
		(GRNAbstract.GRNStatus & 32) = 0 ), 0)),  
	"Sales Return Saleable" =     
		(ISNULL((Select SUM(Quantity) From     
		InvoiceDetail, InvoiceAbstract             
		Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID             
		AND (InvoiceAbstract.InvoiceType = 4)             
		AND (InvoiceAbstract.Status & 128) = 0             
		AND InvoiceDetail.Product_Code = Items.Product_Code             
		AND (InvoiceAbstract.Status & 32) = 0            
		AND dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) Between @FromDateBh And @ToDateBh 
		), 0) +     
		ISNULL((Select SUM(Quantity) From     
		InvoiceDetail, InvoiceAbstract             
		Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID             
		AND (InvoiceAbstract.InvoiceType = 5)             
		AND (InvoiceAbstract.Status & 128) = 0             
		AND InvoiceDetail.Product_Code = Items.Product_Code             
		AND dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) Between @FromDateBh And @ToDateBh
	), 0)),   
	"Sales Return Damages" =   
		(IsNull((Select Sum(Quantity) From   
		InvoiceDetail, InvoiceAbstract   
		Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
		And (InvoiceAbstract.InvoiceType = 4)           
		And (InvoiceAbstract.Status & 128) = 0           
		And InvoiceDetail.Product_Code = Items.Product_Code           
		And (InvoiceAbstract.Status & 32) <> 0          
		AND dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) Between @FromDateBh And @ToDateBh   
  ), 0) +   
		IsNull((Select Sum(Quantity) From   
		InvoiceDetail, InvoiceAbstract   
		Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
		And (InvoiceAbstract.InvoiceType = 6)           
		And (InvoiceAbstract.Status & 128) = 0           
		And InvoiceDetail.Product_Code = Items.Product_Code           
		AND dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) Between @FromDateBh And @ToDateBh 
	), 0)),
	"Total Issues" =   
		(IsNull((Select Sum(Quantity) From InvoiceDetail, InvoiceAbstract   
		Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
		And (InvoiceAbstract.InvoiceType = 2) And   
		(InvoiceAbstract.Status & 128) = 0 And   
		InvoiceDetail.Product_Code = Items.Product_Code          
		AND dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) Between @FromDateBh And @ToDateBh 
		), 0)           
		+ IsNull((Select Sum(Quantity)           
		From DispatchDetail, DispatchAbstract           
		Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID            
		And IsNull(DispatchAbstract.Status, 0) & 64 = 0        
		And DispatchDetail.Product_Code = Items.Product_Code           
		AND dbo.StripDateFromTime(DispatchAbstract.DispatchDate) Between @FromDateBh And @ToDateBh 
	), 0)),
	"Saleable Issues" =   
		(IsNull((Select Sum(Quantity) From InvoiceDetail, InvoiceAbstract  
		Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
		And (InvoiceAbstract.InvoiceType = 2)           
		And (InvoiceAbstract.Status & 128) = 0          
		And InvoiceDetail.Product_Code = Items.Product_Code           
		And InvoiceDetail.SalePrice > 0       
		And (InvoiceAbstract.Status & 32) = 0          
		And dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) Between @FromDateBh And @ToDateBh 
		), 0)      
		+ IsNull((Select Sum(Quantity)           
		From DispatchDetail, DispatchAbstract           
		Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID           
		And (DispatchAbstract.Status & 64) = 0           
		And DispatchDetail.Product_Code = Items.Product_Code           
		And dbo.StripDateFromTime(DispatchAbstract.DispatchDate) Between @FromDateBh And @ToDateBh 
		And DispatchDetail.SalePrice > 0), 0)),
	"Free Issues" =   
		(IsNull((Select Sum(Quantity) From InvoiceDetail, InvoiceAbstract  
		Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
		And (InvoiceAbstract.InvoiceType = 2)           
		And (InvoiceAbstract.Status & 128) = 0           
		And InvoiceDetail.Product_Code = Items.Product_Code           
		And dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) Between @FromDateBh And @ToDateBh 
		And InvoiceDetail.SalePrice = 0), 0)           
		+ IsNull((Select Sum(Quantity)           
		From DispatchDetail, DispatchAbstract           
		Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID           
		And (DispatchAbstract.Status & 64) = 0           
		And DispatchDetail.Product_Code = Items.Product_Code           
		And dbo.StripDateFromTime(DispatchAbstract.DispatchDate) Between @FromDateBh And @ToDateBh
		And DispatchDetail.SalePrice = 0), 0)),  	  
	"Sales Value (%c)" = 
		IsNull((Select Sum(Case invoicetype When 4 Then 0 - Amount Else Amount End)           
		From InvoiceDetail, InvoiceAbstract           
		Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID           
		And (InvoiceAbstract.Status & 128) = 0           
		And InvoiceDetail.Product_Code = Items.Product_Code           
		And dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) Between @FromDateBh And @ToDateBh
	), 0),             
	"Purchase Return" =   
		(IsNull((Select Sum(Quantity)           
		From AdjustmentReturnDetail, AdjustmentReturnAbstract           
		Where AdjustmentReturnAbstract.AdjustmentID = AdjustmentReturnDetail.AdjustmentID  
		And AdjustmentReturnDetail.Product_Code = Items.Product_Code           
		And dbo.StripDateFromTime(AdjustmentReturnAbstract.AdjustmentDate) Between @FromDateBh And @ToDateBh
		And (IsNull(AdjustmentReturnAbstract.Status, 0) & 64) = 0      
		And (IsNull(AdjustmentReturnAbstract.Status, 0) & 128) = 0), 0)),
	"Adjustments" =   
		(IsNull((Select Sum(Quantity - OldQty)           
		From StockAdjustment, StockAdjustmentAbstract           
		Where IsNull(AdjustmentType,0) in (1, 3)           
		And Product_Code = Items.Product_Code           
		And StockAdjustment.SerialNo = StockAdjustmentAbstract.AdjustmentID          
		And  dbo.StripDateFromTime(StockAdjustmentAbstract.AdjustmentDate) Between @FromDateBh And @ToDateBh
	), 0)),
	"Stock Transfer Out" =   
		(IsNull((Select Sum(Quantity)           
		From StockTransferOutAbstract, StockTransferOutDetail          
		Where StockTransferOutAbstract.DocSerial = StockTransferOutDetail.DocSerial  And        
	 dbo.StripDateFromTime(StockTransferOutAbstract.DocumentDate) Between @FromDateBh And @ToDateBh
		And StockTransferOutAbstract.Status & 192 = 0          
		And StockTransferOutDetail.Product_Code = Items.Product_Code), 0)),
	"Stock Transfer In" =   
		(IsNull((Select Sum(Quantity)           
		From StockTransferInAbstract, StockTransferInDetail           
		Where StockTransferInAbstract.DocSerial = StockTransferInDetail.DocSerial          
		And dbo.StripDateFromTime(StockTransferInAbstract.DocumentDate) Between @FromDateBh And @ToDateBh
		And StockTransferInAbstract.Status & 192 = 0          
		And StockTransferInDetail.Product_Code = Items.Product_Code), 0)),
	"Stock Destruction" =   
		(Cast ( IsNull((Select Sum(StockDestructionDetail.DestroyQuantity)                   
		From StockDestructionAbstract, StockDestructionDetail,ClaimsNote       
		Where StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial                  
		And  StockDestructionAbstract.ClaimID = ClaimsNote.ClaimID      
		And dbo.StripDateFromTime(StockDestructionAbstract.DocumentDate) Between @FromDateBh And @ToDateBh
		And ClaimsNote.Status & 1 <> 0          
		And StockDestructionDetail.Product_Code = Items.Product_Code), 0) as Decimal(18,6))), 
	"On Hand Qty" = 
		Case When (@ToDateBh < @Next_Date) Then           
			(IsNull((Select Opening_Quantity - IsNull(Free_Saleable_Quantity, 0)  
			- IsNull(Damage_Opening_Quantity, 0) From OpeningDetails  
			Where OpeningDetails.Product_Code = Items.Product_Code   
			And Opening_Date = DateAdd(dd, 1, @Corrected_Date)), 0))  
		Else           
			((IsNull((Select Sum(Quantity)           
			From Batch_Products           
			Where Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And   
			IsNull(Damage, 0) = 0), 0) +          
			(Select IsNull(Sum(Pending), 0)           
			From VanStatementDetail, VanStatementAbstract           
			Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
			And (VanStatementAbstract.Status & 128) = 0           
			And VanStatementDetail.Product_Code = Items.Product_Code And   
			VanStatementDetail.PurchasePrice <> 0)))  
		End,          
	"On Hand Free Qty" =   
		Case When (@ToDateBh < @Next_Date) Then           
			(IsNull((Select IsNull(Free_Saleable_Quantity, 0)          
			From OpeningDetails           
			Where OpeningDetails.Product_Code = Items.Product_Code           
			And Opening_Date = DateAdd(dd, 1, @Corrected_Date)), 0))  
		Else         
			((IsNull((Select Sum(Quantity)           
			From Batch_Products           
			Where Product_Code = Items.Product_Code And IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0), 0) +    
			(Select IsNull(Sum(Pending), 0)       
			From VanStatementDetail, VanStatementAbstract           
			Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
			And (VanStatementAbstract.Status & 128) = 0           
			And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.PurchasePrice = 0)))  
		End,          
	"On Hand Damage Qty" = 
		Case When (@ToDateBh < @Next_Date) Then           
			(IsNull((Select IsNull(Damage_Opening_Quantity, 0)          
			From OpeningDetails   
			Where OpeningDetails.Product_Code = Items.Product_Code    
			And Opening_Date = DateAdd(dd, 1, @Corrected_Date)), 0))  
		Else           
			(IsNull((Select Sum(Quantity)   
			From Batch_Products           
			Where Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0), 0))  
		End,          
	"Total On Hand Qty" = 
		Case When (@ToDateBh < @Next_Date) Then           
			(IsNull((Select Opening_Quantity          
			From OpeningDetails           
			Where OpeningDetails.Product_Code = Items.Product_Code           
			And Opening_Date = DateAdd(dd, 1, @Corrected_Date)), 0))  
		Else           
			(IsNull((Select Sum(Quantity)           
			From Batch_Products           
			Where Product_Code = Items.Product_Code), 0) +          
			(Select IsNull(Sum(Pending), 0)           
			From VanStatementDetail, VanStatementAbstract           
			Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
			And (VanStatementAbstract.Status & 128) = 0           
			And VanStatementDetail.Product_Code = Items.Product_Code))  
		End,          
	"On Hand Value (%c)" = 
		Case When (@ToDateBh < @Next_Date) Then           
			IsNull((Select Opening_Value - IsNull(Damage_Opening_Value, 0)          
			From OpeningDetails           
			Where OpeningDetails.Product_Code = Items.Product_Code           
			And Opening_Date = DateAdd(dd, 1, @Corrected_Date)), 0)          
		Else           
			((Select IsNull(Sum(Quantity * PurchasePrice), 0)           
			From Batch_Products           
			Where Product_Code = Items.Product_Code And IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0) +           
			(Select IsNull(Sum(Pending * PurchasePrice), 0)           
			From VanStatementDetail, VanStatementAbstract           
			Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
			And (VanStatementAbstract.Status & 128) = 0           
			And VanStatementDetail.Product_Code = Items.Product_Code And VanStatementDetail.SalePrice <> 0))          
		End,          
	"On Hand Damages Value (%c)" = 
		Case When (@ToDateBh < @Next_Date) Then           
			IsNull((Select IsNull(Damage_Opening_Value, 0)          
			From OpeningDetails           
			Where OpeningDetails.Product_Code = Items.Product_Code           
			And Opening_Date = DateAdd(dd, 1, @Corrected_Date)), 0)          
		Else           
			(Select IsNull(Sum(Quantity * PurchasePrice), 0)           
			From Batch_Products           
			Where Product_Code = Items.Product_Code And IsNull(Damage, 0) > 0)          
		End,           
	"Total On Hand Value" = 
		Case When (@ToDateBh < @Next_Date) Then           
			IsNull((Select Opening_Value          
			From OpeningDetails           
			Where OpeningDetails.Product_Code = Items.Product_Code           
			And Opening_Date = DateAdd(dd, 1, @Corrected_Date)), 0)          
		Else           
			((Select IsNull(Sum(Quantity * PurchasePrice), 0)           
			From Batch_Products           
			Where Product_Code = Items.Product_Code) +           
			(Select IsNull(Sum(Pending * PurchasePrice), 0)           
			From VanStatementDetail, VanStatementAbstract           
			Where VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial           
			And (VanStatementAbstract.Status & 128) = 0           
			And VanStatementDetail.Product_Code = Items.Product_Code))          
		End,       
	"Pending Orders" =
		(IsNull(dbo.GetPOPending (Items.Product_Code), 0) +       
		IsNull(dbo.GetSRPending(Items.Product_Code), 0)),     
	"Forum Code" = Items.Alias      
From 
	Items, OpeningDetails,Manufacturer, Brand, ItemCategories      
Where   
	Items.Product_Code *= OpeningDetails.Product_Code And        
 OpeningDetails.Opening_Date = @FromDateBh And      
 Items.ManufacturerID = Manufacturer.ManufacturerID And        
 Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpMfr) And      
 Items.BrandID = Brand.BrandID And      
 Brand.BrandName In (Select Division COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpDiv) And   
 Items.CategoryID = ItemCategories.CategoryID And  
 Items.Product_Code in (Select Product_Code COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpProd)  

Insert InTo #TmpStkMvtItemUnion
(
	ItemCodeH,ItemCodeV,ItemName,CategoryName,OpeningQty,FreeOpengQty,
	DamageOpengQty,TotalOpengQty,OpeningVal,DamageOpengVal,TotalOpengVal,Purchase,FreePurchase,
	SalesRrnSal,SalesRrnDam,TotalIssues,SaleableIsus,FreeIssues,SalesVal,PurchaseRrn,Adjustments,
	STO,STI,StkDes,OnHanQty,OnHanFreQty,OnHandDamQty,TotalOnHanQty,OnHanVal,OnHanDamVal,
	TotalOnHanVal,PendingOrd,ForumCod
)
	Select
		ItemCodeH,	"Item Code" = ItemCodeV,"Item Name" = ItemName,"Category Name" = CategoryName,  
 	"Opening Quantity" = OpeningQty,	"Free Opening Quantity" = FreeOpengQty,"Damage Opening Quantity" = DamageOpengQty,  
		"Total Opening Quantity" = TotalOpengQty,"Opening Value (%c)" = OpeningVal,
		"Damage Opening Value (%c)" = DamageOpengVal,"Total Opening Value (%c)" = TotalOpengVal,
		"Purchase" = Purchase,"Free Purchase" = FreePurchase,"Sales Return Saleable" = SalesRrnSal,  
		"Sales Return Damages" = SalesRrnDam,"Total Issues" = TotalIssues,"Saleable Issues" = SaleableIsus,  
		"Free Issues" = FreeIssues,"Sales Value (%c)" = SalesVal,"Purchase Return" = PurchaseRrn,  
		"Adjustments" = Adjustments,"Stock Transfer Out" = STO,"Stock Transfer In" = STI,  
		"Stock Destruction" = StkDes,"On Hand Qty" = OnHanQty,"On Hand Free Qty" = OnHanFreQty,  
		"On Hand Damage Qty" = OnHandDamQty,"Total On Hand Qty" = TotalOnHanQty,
		"On Hand Value (%c)" = OnHanVal,"On Hand Damages Value (%c)" = OnHanDamVal,
		"Total On Hand Value (%c)" = TotalOnHanVal,"Pending Orders" = PendingOrd,
		"Forum Code" = ForumCod
	From	
		#TmpStkMvtItem

Union All

	Select
		Field1,
		"Item Code" = 	Field1,
		"Item Name" = Field2,           
		"Category Name" = Field3,  
		"Opening Quantity" = Sum(Cast(Field5 As Decimal(18,6))),  
		"Free Opening Quantity" = Sum(Cast(Field6 As Decimal(18,6))),  
		"Damage Opening Quantity" = Sum(Cast(Field7 As Decimal(18,6))),  
		"Total Opening Quantity" = Sum(Cast(Field8 As Decimal(18,6))),  
		"Opening Value (%c)" = Sum(Cast(Field9 As Decimal(18,6))),
		"Damage Opening Value (%c)" = Sum(Cast(Field10 As Decimal(18,6))),
		"Total Opening Value (%c)" = Sum(Cast(Field11 As Decimal(18,6))),
		"Purchase" = Sum(Cast(Field12 As Decimal(18,6))), 
		"Free Purchase" = Sum(Cast(Field13 As Decimal(18,6))),  
		"Sales Return Saleable" = Sum(Cast(Field14 As Decimal(18,6))),  
		"Sales Return Damages" = Sum(Cast(Field15 As Decimal(18,6))),  
		"Total Issues" = Sum(Cast(Field16 As Decimal(18,6))),  
		"Saleable Issues" = Sum(Cast(Field17 As Decimal(18,6))),  
		"Free Issues" = Sum(Cast(Field18 As Decimal(18,6))), 
		"Sales Value (%c)" = Sum(Cast(Field19 As Decimal(18,6))),
		"Purchase Return" = Sum(Cast(Field20 As Decimal(18,6))),  
		"Adjustments" = Sum(Cast(Field21 As Decimal(18,6))),  
		"Stock Transfer Out" = Sum(Cast(Field22 As Decimal(18,6))),  
		"Stock Transfer In" = Sum(Cast(Field23 As Decimal(18,6))),  
		"Stock Destruction" = Sum(Cast(Field24 As Decimal(18,6))),  
		"On Hand Qty" = Sum(Cast(Field25 As Decimal(18,6))),
		"On Hand Free Qty" = Sum(Cast(Field26 As Decimal(18,6))),  
		"On Hand Damage Qty" = Sum(Cast(Field27 As Decimal(18,6))),
		"Total On Hand Qty" = Sum(Cast(Field28 As Decimal(18,6))),
		"On Hand Value (%c)" = Sum(Cast(Field29 As Decimal(18,6))),
		"On Hand Damages Value (%c)" = Sum(Cast(Field30 As Decimal(18,6))),
		"Total On Hand Value (%c)" = Sum(Cast(Field31 As Decimal(18,6))),
		"Pending Orders" =   Sum(Cast(Field32 As Decimal(18,6))),
		"Forum Code" = Field33
	From	
	 Reports,ReportAbstractReceived,Items,Manufacturer,Brand,ItemCategories      
 Where  
  Reports.ReportID In (Select ReportID From Reports Where ReportName = N'Stock Movement - Item')  
  And Reports.CompanyID In (Select CompanyId COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpBranch)  
  And ParameterID In (Select ParameterID From dbo.GetReportParameters_INV_DAILY(N'Stock Movement - Item') Where FromDate = @FromDateBh And ToDate = @ToDateBh)
  And ReportAbstractReceived.ReportID = Reports.ReportID  
  And Field1 <> N'Item Code' And Field1 <> N'SubTotal:' And Field1 <> N'GrandTotal:' 
 	And	Items.ManufacturerID = Manufacturer.ManufacturerID 
 	And Manufacturer.Manufacturer_Name In (Select Manufacturer COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpMfr) 
		And Items.BrandID = Brand.BrandID 
		And Brand.BrandName In (Select Division COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpDiv) 
		And Items.CategoryID = ItemCategories.CategoryID 
		And Items.Product_Code in (Select Product_Code COLLATE SQL_Latin1_General_CP1_CI_AS From #TmpProd)  
		And Field1=Items.Product_Code
	Group By
		Field1,Field2,Field3,Field33

	Select
		ItemCodeH,	"Item Code" = ItemCodeV,"Item Name" = ItemName,"Category Name" = CategoryName,  
		"UOM Description" =   
			Case @UOM 
				When 'Sales UOM' Then IsNull((Select [Description] From UOM Where UOM = Items.UOM), N'')  
				When 'Reporting UOM' Then IsNull((Select [Description] From UOM Where UOM = Items.ReportingUOM), N'')  
				When 'Conversion Factor' Then IsNull((Select [ConversionUnit] From ConversionTable Where ConversionID = Items.ConversionUnit), N'')  
			End,  
		"Opening Quantity" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(OpeningQty,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(OpeningQty,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(OpeningQty,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,
		"Free Opening Quantity" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(FreeOpengQty,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(FreeOpengQty,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(FreeOpengQty,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,
		"Damage Opening Quantity" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(DamageOpengQty,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(DamageOpengQty,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(DamageOpengQty,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,
		"Total Opening Quantity" =
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(TotalOpengQty,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(TotalOpengQty,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(TotalOpengQty,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,
		"Opening Value (%c)" = Sum(OpeningVal),
		"Damage Opening Value (%c)" = Sum(DamageOpengVal),
		"Total Opening Value (%c)" = Sum(TotalOpengVal),
		"Purchase" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(Purchase,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(Purchase,0))) 
			 When 'Conversion Factor'  Then  Sum(IsNull(Purchase,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"Free Purchase" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(FreePurchase,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(FreePurchase,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(FreePurchase,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"Sales Return Saleable" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(SalesRrnSal,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(SalesRrnSal,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(SalesRrnSal,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"Sales Return Damages" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(SalesRrnDam,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(SalesRrnDam,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(SalesRrnDam,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"Total Issues" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(TotalIssues,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(TotalIssues,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(TotalIssues,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"Saleable Issues" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(SaleableIsus,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(SaleableIsus,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(SaleableIsus,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"Free Issues" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(FreeIssues,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(FreeIssues,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(FreeIssues,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"Sales Value (%c)" = Sum(SalesVal),
		"Purchase Return" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(PurchaseRrn,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(PurchaseRrn,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(PurchaseRrn,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"Adjustments" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(Adjustments,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(Adjustments,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(Adjustments,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"Stock Transfer Out" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(Case When STO>STI Then STO-STI Else 0 End,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(Case When STO>STI Then STO-STI Else 0 End,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(Case When STO>STI Then STO-STI Else 0 End,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"Stock Transfer In" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(Case When STI>STO Then STI-STO Else 0 End,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(Case When STI>STO Then STI-STO Else 0 End,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(Case When STI>STO Then STI-STO Else 0 End,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"Stock Destruction" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(StkDes,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(StkDes,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(StkDes,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"On Hand Qty" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(OnHanQty,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(OnHanQty,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(OnHanQty,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"On Hand Free Qty" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(OnHanFreQty,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(OnHanFreQty,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(OnHanFreQty,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"On Hand Damage Qty" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(OnHandDamQty,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(OnHandDamQty,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(OnHandDamQty,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"Total On Hand Qty" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(TotalOnHanQty,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(TotalOnHanQty,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(TotalOnHanQty,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"On Hand Value (%c)" = Sum(OnHanVal),

		"On Hand Damages Value (%c)" = Sum(OnHanDamVal),

		"Total On Hand Value (%c)" = Sum(TotalOnHanVal),

		"Pending Orders" = 
			Case @UOM
				When 'Sales UOM' Then Sum(IsNull(PendingOrd,0))
			 When 'Reporting UOM' Then dbo.sp_Get_ReportingUOMQty(ItemCodeV,Sum(IsNull(PendingOrd,0)))  
			 When 'Conversion Factor'  Then  Sum(IsNull(PendingOrd,0) * (Case IsNull(Items.ConversionFactor, 0) When 0 Then 1 Else Items.ConversionFactor End))
	 	End,

		"Forum Code" = ForumCod
	From	
		#TmpStkMvtItemUnion,Items
	Where
		Product_Code=ItemCodeV
	Group By
		ItemCodeH,ItemCodeV,ItemName,CategoryName,UOM,ReportingUOM,ConversionUnit,ForumCod
	

Drop Table #TmpMfr      
Drop Table #TmpDiv      
Drop Table #TmpProd  
Drop Table #TmpBranch
Drop Table #TmpStkMvtItem
Drop Table #TmpStkMvtItemUnion
