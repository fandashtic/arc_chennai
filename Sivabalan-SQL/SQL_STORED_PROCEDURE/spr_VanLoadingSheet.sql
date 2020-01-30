Create Procedure spr_VanLoadingSheet
(
@FromDate Datetime,
@ToDate Datetime,
@VANumber nVarchar(2000),
@UOM nVarchar(255)
)
As
Begin
Set Dateformat DMY

Declare @Delimeter as Char(1)              
Set @Delimeter = Char(15)

Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)  
Exec sp_CatLevelwise_ItemSorting       

Create Table #tmpAllVANum(AllVAFullDocID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create table #tmpVANumber(ID Int Identity(1,1), VAFullDocID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Create Table #tmpVAInvoices(InvoiceID Int, GSTFullDocID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  

Create Table #Temp (
Itemcode nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
ItemName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
ECP Decimal (18,6),
Salableqty Decimal (18,6),
SchDisc Decimal (18,6),
Discount Decimal(18,6),
Freeqty Decimal(18,6),
Tvalue Decimal(18,6),
Batch nVarchar(256)COLLATE SQL_Latin1_General_CP1_CI_AS,
Tax Decimal(18,6))

Create Table #TempDiv(
Product_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,  
Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
Sub_Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
Market_SKU nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	

If @VANumber = '%' or @VANumber = '' 
	Insert into #tmpAllVANum (AllVAFullDocID) Select FullDocID From VAllocAbstract Where dbo.StripTimeFromDate(AllocDate) Between @FromDate and @ToDate 
Else	
	Insert into #tmpAllVANum (AllVAFullDocID) Select ItemValue From dbo.sp_SplitIn2Rows(@VANumber,@Delimeter)
		
	Insert into #tmpVANumber (VAFullDocID) 
	Select "ItemValue" = Case When CHARINDEX('(',AllVAFullDocID,1) > 0 Then SubString(AllVAFullDocID,1,CHARINDEX('(',AllVAFullDocID,1)-1) Else AllVAFullDocID End From #tmpAllVANum

	Insert Into #tmpVAInvoices (InvoiceID, GSTFullDocID )
	Select VAD.InvoiceID, VAD.GSTFullDocID   
	From VAllocAbstract VAA 
	Inner Join VAllocDetail VAD On VAD.VAllocID = VAA.ID 
	Inner Join #tmpVANumber V On V.VAFullDocID = VAA.FullDocID 
	Where VAA.Status & 64 = 0
 	 
	 Insert into #Temp 
	 (Itemcode,ItemName,ECP,Salableqty,SchDisc,Discount,Freeqty,Tvalue,Batch,Tax)
	 Select 
	 InvoiceDetail.Product_Code,
	 Items.ProductName,
	 ISNULL(Batch_Products.MRPPerPack,0),
	 
	 SUM(CASE InvoiceAbstract.InvoiceType when 4 then 0 ELSE Case when InvoiceDetail.SalePrice > 0 Then InvoiceDetail.Quantity Else Cast (0 As decimal (18,6))End END),-- sale
	 
	 SUM(CASE InvoiceAbstract.InvoiceType when 4  then 0 ELSE ISNULL(InvoiceDetail.SCHEMEDISCAMOUNT,0)+ISNULL(InvoiceDetail.SPLCATDISCAMOUNT,0)End)-- schdisc
	 + SUM(CASE InvoiceAbstract.InvoiceType when 4 then 0 ELSE (Isnull(InvoiceDetail.Quantity,0)
	 * ISNULL(Invoicedetail.SalePrice,0)- ISNULL(Invoicedetail.DiscountValue,0))* ISNULL(InvoiceAbstract.SchemeDiscountPercentage,0)/100 END), 
	
	 (Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else IsNull(InvoiceDetail.DiscountValue,0) - (IsNull(InvoiceDetail.SchemeDiscAmount,0) 
	 + IsNull(InvoiceDetail.SplCatDiscAmount,0)) End)      
	  +Sum(Case InvoiceAbstract.InvoiceType  When 4 Then 0 Else ((IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0))  
	*((IsNull(InvoiceAbstract.DiscountPercentage,0) - IsNull(InvoiceAbstract.SchemeDiscountPercentage,0))/100)) end )
	  +Sum(Case InvoiceAbstract.InvoiceType  When 4 Then 0 Else ((IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0)) 
	* IsNull(InvoiceAbstract.AdditionalDiscount,0)/100) end )),  ---- Discount
	
	 SUM(CASE InvoiceAbstract.InvoiceType When 4 Then 0 ELSE Case When InvoiceDetail.SalePrice = 0 Then 
  	 InvoiceDetail.Quantity Else Cast(0 As Decimal(18, 6)) End END), --- Free qty
 
	 SUM(CASE InvoiceAbstract.InvoiceType When 4 Then 0 ELSE InvoiceDetail.Amount END), -- tvalue
	 
	 ISNULL (InvoiceDetail.Batch_Number,''),  -- batch 

	 Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else IsNull(InvoiceDetail.STPayable, 0) + IsNull(InvoiceDetail.CSTPayable, 0) End) -- tax

	 
	 From InvoiceDetail,Invoiceabstract,Items,Batch_Products,#tmpVAInvoices
	 Where 
	 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And 
	 InvoiceDetail.Product_Code = Items.Product_Code And
	 Batch_products.Batch_Code = Invoicedetail.Batch_Code And
	 (InvoiceAbstract.Status & 128) = 0 And
	 (InvoiceAbstract.Status & 16) = 0 And
	 InvoiceAbstract.GSTFullDocID = #tmpVAInvoices.GSTFullDocID And
	 InvoiceAbstract.InvoiceType in (1,3)
	 
	 Group By 
	 InvoiceDetail.Product_Code ,Items.ProductName,Batch_Products.MRPPerPack,InvoiceDetail.Batch_Code,InvoiceDetail.Batch_Number ,Items.MRP,UOM2_Conversion,Batch_Products.MRPPerPack
	 
	 Order By
	 InvoiceDetail.Product_Code

	  
	-------- For Category & Subcategory 
	Insert Into #TempDiv(Product_Code, Category, Sub_Category,Market_SKU)
	
	Select Distinct I.Product_Code, IC1.Category_Name,IC2.Category_Name,IC3.Category_Name   
	From  
	ItemCategories IC1, ItemCategories IC2, ItemCategories IC3, Items I  
	
	Where  
	IC1.CategoryID = IC2.ParentID  
	And IC2.CategoryID = IC3.ParentID   
	And IC1.Level = 2  
	And I.CategoryID = IC3.CategoryID  
	
	Order By  
	I.Product_Code, IC1.Category_Name, IC2.Category_Name, IC3.Category_Name     
	 

IF @UOM = N'UOM1&UOM2'
Begin 
	 Select "Category" = TD.Category,
	 "Category" = TD.Category,
	 "SubCategory" = TD.Sub_Category,
	 "ItemCode" = T.Itemcode,
	 "ItemName" = T.ItemName,
	 "Batch" = T.Batch,
	 "QtyInCFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(T.Itemcode, Sum(IsNull(T.SalableQty, 0)), 1),
	 
	 "QtyInPAC"=dbo.fn_GetQtyAsUOM1UOM2_ITC(T.Itemcode, Sum(IsNull(T.SalableQty, 0)), 2),
	 
	 "FreeQtyInPAC" = Sum(IsNull(T.FreeQty, 0)) / Case IsNull((Select uom2_conversion From Items 
					  Where Product_Code = T.Itemcode), 0) When 0 Then 1 Else 
					  IsNull((Select uom2_conversion From Items 
					  Where Product_Code = T.Itemcode), 0) End,
					  
	 "TotalCFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(T.Itemcode, Sum(IsNull(T.SalableQty, 0) + IsNull(T.FreeQty, 0)), 1),
	 
	 "TotalPAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(T.Itemcode, Sum(IsNull(T.SalableQty, 0) + IsNull(T.FreeQty, 0)), 2),
	 
	 "Sch.Disc"= SUM(T.SchDisc),
	 "Discount" = SUM(T.Discount),
	 "TaxAmount" = SUM(T.Tax),
	 "TotalValue" = SUM(T.Tvalue),
	 "Weight(Kg)"= Cast(Sum((IsNull(T.SalableQty, 0) + IsNull(T.FreeQty,0)) * IsNull(ITS.ConversionFactor,0)) As Decimal(18,6)),
	 "MRPPerPack" = ISNULL(T.ECP,0)
	 From  
	 #Temp T ,Items ITS, #TempDiv TD , #tempCategory1 TC
	 Where
	 T.Itemcode = ITS.Product_Code And
	 TC.CategoryID = ITS.CategoryID And
	 T.Itemcode = TD.Product_Code
	 Group By
	 T.Itemcode,T.ItemName,T.ECP,ITS.UOM2_Conversion,TD.Category,TD.Sub_Category,T.Batch,TC.IDS
	 Order By
	 TC.IDS
	 
End
Else
Begin
	Select "Category" = TD.Category,
	"Category" = TD.Category,
	"SubCategory" = TD.Sub_Category,
	"ItemCode"=T.Itemcode,
	"ItemName"=T.ItemName,
	"UOM"= IsNull((Select [Description] From UOM Where UOM In (Select UOM2 From Items 
	       Where Product_code = IsNull(T.Itemcode,''))), ''),
	"Batch"=T.Batch,
	"Qty"=SUM(T.SalableQty) / Case IsNull(ITS.UOM2_Conversion,0) When 0  Then 1 Else ITS.UOM2_Conversion End,
	"Free" = SUM(T.FreeQty) / Case IsNull(ITS.UOM2_Conversion,0) When 0  Then 1 Else ITS.UOM2_Conversion End,
	"TotalQty" = SUM(T.SalableQty + T.FreeQty) / Case IsNull(ITS.UOM2_Conversion,0) When 0  Then 1 Else ITS.UOM2_Conversion End,
	"Sch.Disc"= SUM(T.SchDisc),
	"Discount"=SUM(T.Discount),
	"TaxAmount"=SUM(T.Tax),
	"TotalValue"=SUM(T.Tvalue),
	"Weight(KG)"=Cast(Sum((IsNull(T.SalableQty,0) + IsNull(T.FreeQty,0)) * IsNull(ITS.ConversionFactor,0)) As Decimal(18,6)),
	"MRPPerPack"=IsNull(T.ECP,0)
	From  
	 #Temp T ,Items ITS, #TempDiv TD,#tempCategory1 TC
	 Where 
	 T.Itemcode = ITS.Product_Code And
	 TC.CategoryID = ITS.CategoryID And
	 T.Itemcode = TD.Product_Code
	 Group By
	 T.Itemcode,T.ItemName,T.ECP,ITS.UOM2_Conversion,TD.Category,TD.Sub_Category,TC.IDS,T.Batch
	 Order By
	 TC.IDS
End

Drop Table #tempCategory1
Drop Table #tmpVANumber
Drop Table #tmpVAInvoices
Drop Table #Temp
Drop Table #TempDiv  

END
