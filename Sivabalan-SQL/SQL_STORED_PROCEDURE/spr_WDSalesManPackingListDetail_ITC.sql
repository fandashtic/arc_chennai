CREATE PROCEDURE spr_WDSalesManPackingListDetail_ITC
(
 @SALESMAN nvarchar(256),
 @FROMDATE datetime,
 @TODATE datetime,
 @UOM nVarChar(255)
)                  
AS                  
DECLARE @SALESMANID int                  
DECLARE @FROMNO nvarchar(510)                  
DECLARE @TONO nvarchar(510)                  
Declare @DocPrefix nVarchar(20)        
DECLARE @INDEX1 int                  
DECLARE @INDEX2 int                  
DECLARE @INDEX3 int                  
Declare @IPrefix nVarchar(256)        
Declare @VPrefix nVarchar(256)        
Set @VPrefix = 'V'

  
SET @INDEX1 = charindex(N';', @SALESMAN)                  
SET @INDEX2 = charindex(N';', @SALESMAN, @INDEX1 + 1)                  
SET @INDEX3 = charindex(N';', @SALESMAN, @INDEX2 + 1)                  
  
Set @SALESMANID = cast(substring(@SALESMAN, 1, @INDEX1-1) as int)                  
Set @FROMNO = substring(@SALESMAN, @INDEX1+1, @INDEX2-1-@INDEX1)                  
Set @ToNO = substring(@SALESMAN, @INDEX2+1, @INDEX3-1-@INDEX2)                  
Set @DocPrefix = substring(@SALESMAN, @INDEX3+1, 20)    

--------------------------------------------------
-- select @SALESMANID
--------------------------------------------------
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)  
Exec sp_CatLevelwise_ItemSorting  

Create Table #TempInvNo(SalInvNo int)
Create Table #TempDocID(DocID int)
Create Table #TmpSRInvoiceID(GSTReference NVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)     

Insert Into #TempInvNo
Select DocumentID From InvoiceAbstract 
 	Where  InvoiceAbstract.Status & 128 = 0 And 
  	InvoiceType In (1, 3, 4) And InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And                  
  	InvoiceAbstract.SalesmanID = @SALESMANID 
  	And dbo.GetTrueVal(InvoiceAbstract.DocReference) Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)
    And IsNull(InvoiceAbstract.GSTFlag,0) = 0 
--Added for GST begin      
Insert Into #TmpSRInvoiceID
Select IsNull(InvoiceAbstract.GSTFullDocID,0) From InvoiceAbstract 
 	Where  InvoiceAbstract.Status & 128 = 0 And 
  	InvoiceType In (1, 3, 4) And InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And                  
  	InvoiceAbstract.SalesmanID = @SALESMANID 
  	And ISNULL(InvoiceAbstract.GSTDocID,0) Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)                  
    And IsNull(InvoiceAbstract.GSTFlag,0) = 1
    
Insert Into #TmpSRInvoiceID   
Select  Isnull(CollectionDetail.OriginalID,'') From CollectionDetail, InvoiceAbstract 
	Where ISnull(InvoiceAbstract.PaymentDetails,0)=CollectionDetail.CollectionID      
	And CollectionDetail.DocumentType=1 And InvoiceAbstract.InvoiceType in (1,3)      
	And InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE  
	And IsNull(InvoiceAbstract.GSTFlag ,0) = 1  
--Added for GST end     

Insert Into #TempDocID
Select  dbo.GetTrueVal(CollectionDetail.OriginalID) From CollectionDetail, InvoiceAbstract 
	Where ISnull(InvoiceAbstract.PaymentDetails,0)=CollectionDetail.CollectionID      
	And CollectionDetail.DocumentType=1 And InvoiceAbstract.InvoiceType in (1,3)      
	And InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE  
	And IsNull(InvoiceAbstract.GSTFlag,0) = 0      


Create Table #tempDiv(Product_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,  
					Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
					Sub_Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
					Market_SKU nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)  

Insert Into #tempDiv(Product_Code, Category, Sub_Category, Market_SKU)  
Select Distinct I.Product_Code, IC1.Category_Name,  
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


Select @IPrefix = Prefix from voucherprefix where tranid = N'INVOICE'

Create Table #Temp
(
 [Item Code] nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
 [Item Name] nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,  
 SalePrice Decimal(18,6), 
 ECP Decimal(18, 6),
 [Uom2 MRP(Rs.)] Decimal(18,6),              
 SalableQty Decimal(18, 6),
 FreeQty Decimal(18, 6),
 -- TotalQty Decimal(18,6), 
 SchDisc Decimal(18, 6),
 Discount Decimal(18, 6),
 Tax Decimal(18, 6),
 TValue Decimal(18, 6),
 SalesReturnSalable Decimal(18, 6),
 SalesReturnDamages Decimal(18, 6),
 Uom2Qty Decimal(18,6),
 Uom2Desc nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
 Uom1Qty Decimal(18,6),              
 Uom1Desc nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
 UomQty Decimal(18,6),
 UomDesc nvarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS
)                    


If @DocPrefix ='%'         
 Begin                
 	Insert into #Temp([Item Code],[Item Name], SalePrice, ECP, SalableQty, 
	FreeQty, SchDisc, Discount, Tax, TValue, SalesReturnSalable, SalesReturnDamages)
 	Select
   	InvoiceDetail.Product_Code, 
	Items.ProductName,
	InvoiceDetail.SalePrice,
--	IsNull(Batch_Products.ECP,0),
	IsNull(Batch_Products.MRPPerPack,0),
	
	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else Case When InvoiceDetail.SalePrice > 0 Then 
  	InvoiceDetail.Quantity Else Cast(0 As Decimal(18, 6)) End End),

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else Case When InvoiceDetail.SalePrice = 0 Then 
  	InvoiceDetail.Quantity Else Cast(0 As Decimal(18, 6)) End End),

	--Sum(IsNull(InvoiceDetail.SchemeDiscAmount, 0) + IsNull(InvoiceDetail.SplCatDiscAmount, 0)),

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else IsNull(InvoiceDetail.SchemeDiscAmount,0) + IsNull(InvoiceDetail.SplCatDiscAmount,0) End)      
	  + sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else (IsNull(InvoiceDetail.Quantity,0) * IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0)) 
	 *  IsNull(InvoiceAbstract.SchemeDiscountPercentage,0)/100 End),      


-- 	Sum(IsNull(InvoiceDetail.DiscountValue, 0) - 
-- 	(IsNull(InvoiceDetail.SchemeDiscAmount, 0) + IsNull(InvoiceDetail.SplCatDiscAmount, 0))), 

	 (Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else IsNull(InvoiceDetail.DiscountValue,0) - (IsNull(InvoiceDetail.SchemeDiscAmount,0) 
	 + IsNull(InvoiceDetail.SplCatDiscAmount,0)) End)      
	  +Sum(Case InvoiceAbstract.InvoiceType  When 4 Then 0 Else ((IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0))  
	*((IsNull(InvoiceAbstract.DiscountPercentage,0) - IsNull(InvoiceAbstract.SchemeDiscountPercentage,0))/100)) end )
	  +Sum(Case InvoiceAbstract.InvoiceType  When 4 Then 0 Else ((IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0)) 
	* IsNull(InvoiceAbstract.AdditionalDiscount,0)/100) end )),        

/*
	(Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else IsNull(InvoiceDetail.DiscountValue,0) - (IsNull(InvoiceDetail.SchemeDiscAmount,0) 
	 + IsNull(InvoiceDetail.SplCatDiscAmount,0)) End)      
	  +Sum( (IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0))  
	*((IsNull(InvoiceAbstract.DiscountPercentage,0) - IsNull(InvoiceAbstract.SchemeDiscountPercentage,0))/100))      
	  +Sum((IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0)) 
	* IsNull(InvoiceAbstract.AdditionalDiscount,0)/100)),        
*/

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else IsNull(InvoiceDetail.STPayable, 0) + IsNull(InvoiceDetail.CSTPayable, 0) End),

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else InvoiceDetail.Amount End),

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then Case InvoiceAbstract.status & 32 When 0 Then IsNull(InvoiceDetail.Quantity,0) Else Cast(0 As Decimal(18, 6)) End Else Cast(0 As Decimal(18, 6)) End),
	Sum(Case InvoiceAbstract.InvoiceType When 4 Then Case InvoiceAbstract.status & 32 When 0 Then Cast(0 As Decimal(18, 6)) Else IsNull(InvoiceDetail.Quantity,0) End Else Cast(0 As Decimal(18, 6)) End)
--   	(Batch_Products.ECP * UOM2_Conversion)            
 	From
   	InvoiceDetail, InvoiceAbstract, Items, Batch_Products                  
 	Where
   	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And                  
  	InvoiceDetail.Product_code = Items.Product_Code And                  
  	Batch_products.Batch_Code = InvoiceDetail.Batch_Code And
  	(InvoiceAbstract.Status & 128) = 0 And                   
	(InvoiceAbstract.Status & 16) = 0 And
  	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And                  
  	InvoiceAbstract.SalesmanID = @SALESMANID And 
	(
	(InvoiceAbstract.InvoiceType in (1,3)) 
	OR
	( InvoiceAbstract.InvoiceType = 4 And IsNull(ReferenceNumber,'')<>'' And InvoiceAbstract.ReferenceNumber In (Select GSTReference From #TmpSRInvoiceID Where GSTReference = InvoiceAbstract.ReferenceNumber) )
	OR
	(InvoiceAbstract.GSTFullDocID in (Select GSTReference From #TmpSRInvoiceID Where GSTReference = InvoiceAbstract.ReferenceNumber)) 
	OR 
	(InvoiceAbstract.InvoiceType = 4 And IsNull(ReferenceNumber,'')<>'' And dbo.GetTrueVal_ITC(ReferenceNumber) in 
			(Select SalInvNo from #TempInvNo where SalInvNo = dbo.GetTrueVal_ITC(ReferenceNumber))  
	Or InvoiceAbstract.DocumentID In(Select DocID From #TempDocID)  )) And

	--IsNull(InvoiceAbstract.DocReference,'') <> '' And
      dbo.GetTrueVal(InvoiceAbstract.DocReference) Between 
      dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)

--      IsNull(InvoiceAbstract.NewReference,'') = ''
 	Group By
	InvoiceDetail.Product_Code,Items.ProductName, InvoiceDetail.Batch_Code, InvoiceDetail.Batch_Number,
--   	InvoiceDetail.SalePrice, Items.MRP, UOM2_Conversion, Batch_Products.ECP
	InvoiceDetail.SalePrice, Items.MRP, UOM2_Conversion, Batch_Products.MRPPerPack
 	Order by
   	InvoiceDetail.Product_Code     

    
 	Insert into #Temp([Item Code],[Item Name], SalePrice, ECP, SalableQty, 
	FreeQty, SchDisc, Discount, Tax, TValue, SalesReturnSalable, SalesReturnDamages)
 	Select
   	InvoiceDetail.Product_Code, 
	Items.ProductName,
	InvoiceDetail.SalePrice,
--	IsNull(VSD.ECP,0),
    IsNull(VSD.MRPPerPack,0),
	
	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else Case When InvoiceDetail.SalePrice > 0 Then 
  	InvoiceDetail.Quantity Else Cast(0 As Decimal(18, 6)) End End),

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else Case When InvoiceDetail.SalePrice = 0 Then 
  	InvoiceDetail.Quantity Else Cast(0 As Decimal(18, 6)) End End),

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else IsNull(InvoiceDetail.SchemeDiscAmount,0) + IsNull(InvoiceDetail.SplCatDiscAmount,0) End)      
	  + sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else (IsNull(InvoiceDetail.Quantity,0) * IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0)) 
	 *  IsNull(InvoiceAbstract.SchemeDiscountPercentage,0)/100 End),      


-- 	Sum(IsNull(InvoiceDetail.DiscountValue, 0) - 
-- 	(IsNull(InvoiceDetail.SchemeDiscAmount, 0) + IsNull(InvoiceDetail.SplCatDiscAmount, 0))), 

	(Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else IsNull(InvoiceDetail.DiscountValue,0) - (IsNull(InvoiceDetail.SchemeDiscAmount,0) 
	 + IsNull(InvoiceDetail.SplCatDiscAmount,0)) End)      
	  +Sum(Case InvoiceAbstract.InvoiceType  When 4 Then 0 Else ((IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0))  
	*((IsNull(InvoiceAbstract.DiscountPercentage,0) - IsNull(InvoiceAbstract.SchemeDiscountPercentage,0))/100)) end )      
	  +Sum(Case InvoiceAbstract.InvoiceType  When 4 Then 0 Else  ((IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0)) 
	* IsNull(InvoiceAbstract.AdditionalDiscount,0)/100) end )),        

-- 	Sum(IsNull(InvoiceDetail.SchemeDiscAmount, 0) + IsNull(InvoiceDetail.SplCatDiscAmount, 0)),
-- 
-- 	Sum(IsNull(InvoiceDetail.DiscountValue, 0) - 
-- 	(IsNull(InvoiceDetail.SchemeDiscAmount, 0) + IsNull(InvoiceDetail.SplCatDiscAmount, 0))), 

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else IsNull(InvoiceDetail.STPayable, 0) + IsNull(InvoiceDetail.CSTPayable, 0) End), 
	
	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else InvoiceDetail.Amount End),

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then Case InvoiceAbstract.status & 32 When 0 Then IsNull(InvoiceDetail.Quantity,0) Else Cast(0 As Decimal(18, 6)) End Else Cast(0 As Decimal(18, 6)) End),
	Sum(Case InvoiceAbstract.InvoiceType When 4 Then Case InvoiceAbstract.status & 32 When 0 Then Cast(0 As Decimal(18, 6)) Else IsNull(InvoiceDetail.Quantity,0) End Else Cast(0 As Decimal(18, 6)) End)
 	From
   	InvoiceDetail, InvoiceAbstract, Items, VanStatementDetail VSD, VanStatementAbstract VSA            
 	Where
   	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And                  
  	InvoiceDetail.Product_code = Items.Product_Code And                  
  	VSD.[ID] = InvoiceDetail.Batch_Code And
	@VPrefix + CAst(VSA.DocumentID AS nVarchar) = InvoiceAbstract.NewReference and
  	(InvoiceAbstract.Status & 128) = 0 And 
  	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And                  
  	InvoiceAbstract.SalesmanID = @SALESMANID And                  
	(
	(InvoiceAbstract.InvoiceType in (1,3)) 
	OR (InvoiceAbstract.InvoiceType = 4 And IsNull(ReferenceNumber,'')<>'' And dbo.GetTrueVal_ITC(ReferenceNumber) 
		in (Select SalInvNo from #TempInvNo where SalInvNo = dbo.GetTrueVal_ITC(ReferenceNumber))  
	Or InvoiceAbstract.DocumentID In(Select DocID From #TempDocID) )
	OR 
	( InvoiceAbstract.InvoiceType = 4 And IsNull(ReferenceNumber,'')<>'' And InvoiceAbstract.ReferenceNumber In (Select GSTReference From #TmpSRInvoiceID Where GSTReference = InvoiceAbstract.ReferenceNumber) )
	OR
	(InvoiceAbstract.GSTFullDocID in (Select GSTReference From #TmpSRInvoiceID Where GSTReference = InvoiceAbstract.ReferenceNumber))
	) And
    dbo.GetTrueVal(InvoiceAbstract.DocReference) Between dbo.GetTrueVal(@FROMNO) 
    And dbo.GetTrueVal(@TONO) And
   IsNull(InvoiceAbstract.NewReference,'') <> ''
 	Group By
   InvoiceDetail.Product_Code,Items.ProductName, InvoiceDetail.Batch_Number,
--   InvoiceDetail.SalePrice, Items.MRP, VSD.ECP, UOM2_Conversion, VSA.DocumentID           
	InvoiceDetail.SalePrice, Items.MRP, VSD.MRPPerPack, UOM2_Conversion, VSA.DocumentID           
 	Order by
   InvoiceDetail.Product_Code                  

	
 End        
  
Else        
Begin        

 	Insert into #Temp([Item Code],[Item Name], SalePrice, ECP, SalableQty, 
	FreeQty, SchDisc, Discount, Tax, TValue, SalesReturnSalable, SalesReturnDamages)
 	Select
   	InvoiceDetail.Product_Code, 
	Items.ProductName,
	InvoiceDetail.SalePrice,
--	IsNull(Batch_Products.ECP,0),
    IsNull(Batch_Products.MRPPerPack,0),
	
	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else Case When InvoiceDetail.SalePrice > 0 Then 
  	InvoiceDetail.Quantity Else Cast(0 As Decimal(18, 6)) End End),

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else Case When InvoiceDetail.SalePrice = 0 Then 
  	InvoiceDetail.Quantity Else Cast(0 As Decimal(18, 6)) End End),

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else IsNull(InvoiceDetail.SchemeDiscAmount,0) + IsNull(InvoiceDetail.SplCatDiscAmount,0) End)      
	  + sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else (IsNull(InvoiceDetail.Quantity,0) * IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0)) 
	 *  IsNull(InvoiceAbstract.SchemeDiscountPercentage,0)/100 End),      

	(Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else IsNull(InvoiceDetail.DiscountValue,0) - (IsNull(InvoiceDetail.SchemeDiscAmount,0) 
	 + IsNull(InvoiceDetail.SplCatDiscAmount,0)) End)      
	  +Sum(Case InvoiceAbstract.InvoiceType  When 4 Then 0 Else  ((IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0))  
	*((IsNull(InvoiceAbstract.DiscountPercentage,0) - IsNull(InvoiceAbstract.SchemeDiscountPercentage,0))/100)) end)      
	  +Sum(Case InvoiceAbstract.InvoiceType  When 4 Then 0 Else  ((IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0)) 
	* IsNull(InvoiceAbstract.AdditionalDiscount,0)/100) end  )),        

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else IsNull(InvoiceDetail.STPayable, 0) + IsNull(InvoiceDetail.CSTPayable, 0) End),

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else InvoiceDetail.Amount End),

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then Case InvoiceAbstract.status & 32 When 0 Then IsNull(InvoiceDetail.Quantity,0) Else Cast(0 As Decimal(18, 6)) End Else Cast(0 As Decimal(18, 6)) End),
	Sum(Case InvoiceAbstract.InvoiceType When 4 Then Case InvoiceAbstract.status & 32 When 0 Then Cast(0 As Decimal(18, 6)) Else IsNull(InvoiceDetail.Quantity,0) End Else Cast(0 As Decimal(18, 6)) End)

	From
	InvoiceDetail, InvoiceAbstract, Items, Batch_Products                   
	Where
  	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And                  
 	InvoiceDetail.Product_code = Items.Product_Code And                  
 	Batch_products.Batch_Code = InvoiceDetail.Batch_Code And
 	(InvoiceAbstract.Status & 128) = 0 And                   
	(InvoiceAbstract.Status & 16) = 0 And
 	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And                  
 	InvoiceAbstract.SalesmanID = @SALESMANID And                  
 	(
 	(InvoiceAbstract.InvoiceType in (1,3)) 
 	 OR (InvoiceAbstract.InvoiceType = 4 And IsNull(ReferenceNumber,'')<>'' And dbo.GetTrueVal_ITC(ReferenceNumber) 
			in (Select SalInvNo from #TempInvNo where SalInvNo = dbo.GetTrueVal_ITC(ReferenceNumber))  
	 Or InvoiceAbstract.DocumentID In(Select DocID From #TempDocID) )
	 OR 
	( InvoiceAbstract.InvoiceType = 4 And IsNull(ReferenceNumber,'')<>'' And InvoiceAbstract.ReferenceNumber In (Select GSTReference From #TmpSRInvoiceID Where GSTReference = InvoiceAbstract.ReferenceNumber) )
	OR
	(InvoiceAbstract.GSTFullDocID in (Select GSTReference From #TmpSRInvoiceID Where GSTReference = InvoiceAbstract.ReferenceNumber))
	 )  And 
	dbo.GetTrueVal(InvoiceAbstract.DocReference) Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)        
	 And DocSerialType = @DocPrefix --And 
--  IsNull(InvoiceAbstract.NewReference,'') = ''             
	Group By
  InvoiceDetail.Product_Code, Items.ProductName,  InvoiceDetail.Batch_Number,
--  InvoiceDetail.SalePrice, Items.MRP, UOM2_Conversion,  Batch_Products.ECP         
  InvoiceDetail.SalePrice, Items.MRP, UOM2_Conversion,  Batch_Products.MRPPerPack
	Order by
  InvoiceDetail.Product_Code                 

 	Insert into #Temp([Item Code],[Item Name], SalePrice, ECP, SalableQty, 
	FreeQty, SchDisc, Discount, Tax, TValue, SalesReturnSalable, SalesReturnDamages)
 	Select
   	InvoiceDetail.Product_Code, 
	Items.ProductName,
	InvoiceDetail.SalePrice,
--	IsNull(VSD.ECP,0),
	IsNull(VSD.MRPPerPack,0),
	
	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else Case When InvoiceDetail.SalePrice > 0 Then 
  	InvoiceDetail.Quantity Else Cast(0 As Decimal(18, 6)) End End),

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else Case When InvoiceDetail.SalePrice = 0 Then 
  	InvoiceDetail.Quantity Else Cast(0 As Decimal(18, 6)) End End),

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else IsNull(InvoiceDetail.SchemeDiscAmount,0) + IsNull(InvoiceDetail.SplCatDiscAmount,0) End)      
	  + sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else (IsNull(InvoiceDetail.Quantity,0) * IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0)) 
	 *  IsNull(InvoiceAbstract.SchemeDiscountPercentage,0)/100 End),      

	(Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else IsNull(InvoiceDetail.DiscountValue,0) - (IsNull(InvoiceDetail.SchemeDiscAmount,0) 
	 + IsNull(InvoiceDetail.SplCatDiscAmount,0)) End)      
	  +Sum( Case InvoiceAbstract.InvoiceType  When 4 Then 0 Else  ((IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0))  
	*((IsNull(InvoiceAbstract.DiscountPercentage,0) - IsNull(InvoiceAbstract.SchemeDiscountPercentage,0))/100)) end )      
	  +Sum( Case InvoiceAbstract.InvoiceType  When 4 Then 0 Else  ((IsNull(InvoiceDetail.Quantity,0)*IsNull(InvoiceDetail.SalePrice,0)-IsNull(InvoiceDetail.DiscountValue,0)) 
	* IsNull(InvoiceAbstract.AdditionalDiscount,0)/100) end )),        

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else IsNull(InvoiceDetail.STPayable, 0) + IsNull(InvoiceDetail.CSTPayable, 0) End),

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then 0 Else InvoiceDetail.Amount End),

	Sum(Case InvoiceAbstract.InvoiceType When 4 Then Case InvoiceAbstract.status & 32 When 0 Then IsNull(InvoiceDetail.Quantity,0) Else Cast(0 As Decimal(18, 6)) End Else Cast(0 As Decimal(18, 6)) End),
	Sum(Case InvoiceAbstract.InvoiceType When 4 Then Case InvoiceAbstract.status & 32 When 0 Then Cast(0 As Decimal(18, 6)) Else IsNull(InvoiceDetail.Quantity,0) End Else Cast(0 As Decimal(18, 6)) End)
	From
	InvoiceDetail, InvoiceAbstract, Items, VanStatementDetail VSD                   
	Where
	InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And                  
 	InvoiceDetail.Product_code = Items.Product_Code And                  
 	VSD.[ID] = InvoiceDetail.Batch_Code And
 	(InvoiceAbstract.Status & 128) = 0 And (InvoiceAbstract.Status & 16) <> 0 and 
 	InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And                  
 	InvoiceAbstract.SalesmanID = @SALESMANID And                  
 		(
 		(InvoiceAbstract.InvoiceType in (1,3)) 
 		 OR (InvoiceAbstract.InvoiceType = 4 And IsNull(ReferenceNumber,'')<>'' and dbo.GetTrueVal_ITC(ReferenceNumber) 
				in (Select SalInvNo from #TempInvNo where SalInvNo = dbo.GetTrueVal_ITC(ReferenceNumber))  
		 Or InvoiceAbstract.DocumentID In(Select DocID From #TempDocID) )
		 OR 
		 ( InvoiceAbstract.InvoiceType = 4 And IsNull(ReferenceNumber,'')<>'' And InvoiceAbstract.ReferenceNumber In (Select GSTReference From #TmpSRInvoiceID Where GSTReference = InvoiceAbstract.ReferenceNumber) )
		 OR
		 (InvoiceAbstract.GSTFullDocID in (Select GSTReference From #TmpSRInvoiceID Where GSTReference = InvoiceAbstract.ReferenceNumber))
		) And 
	dbo.GetTrueVal(InvoiceAbstract.DocReference) Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)        
	And DocSerialType = @DocPrefix And
	IsNull(InvoiceAbstract.NewReference,'') <> ''             
	Group By
	InvoiceDetail.Product_Code, Items.ProductName,  InvoiceDetail.Batch_Number,
--	InvoiceDetail.SalePrice, Items.MRP, VSD.ECP, UOM2_Conversion            
	InvoiceDetail.SalePrice, Items.MRP, VSD.MRPPerPack, UOM2_Conversion            
	Order by
	InvoiceDetail.Product_Code                  
End        

If @UOM = 'UOM1 & UOM2'
Begin
	Select "Item Code" = T.[Item Code], 
	"Category"   =  td.Category, 
	"Sub Category" = td.Sub_Category,
	"Item Name" = T.[Item Name], 
	"Qty in CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(T.[Item Code], Sum(IsNull(T.SalableQty, 0)), 1),

-- Sum(IsNull(T.SalableQty, 0)) / Case IsNull((Select uom1_conversion From Items 
-- 		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
-- 		IsNull((Select uom1_conversion From Items 
-- 		Where Product_Code = T.[Item Code]), 0) End,

	"Qty in PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(T.[Item Code], Sum(IsNull(T.SalableQty, 0)), 2),

-- Sum(IsNull(T.SalableQty, 0)) / Case IsNull((Select uom2_conversion From Items 
-- 		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
-- 		IsNull((Select uom2_conversion From Items 
-- 		Where Product_Code = T.[Item Code]), 0) End,

	"Free Qty in PAC" = Sum(IsNull(T.FreeQty, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End,

	"Total CFC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(T.[Item Code], Sum(IsNull(T.SalableQty, 0) + IsNull(T.FreeQty, 0)), 1),

-- Sum(IsNull(T.SalableQty, 0)) / Case IsNull((Select uom1_conversion From Items 
-- 		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
-- 		IsNull((Select uom1_conversion From Items 
-- 		Where Product_Code = T.[Item Code]), 0) End +
-- 
-- 		Sum(IsNull(T.FreeQty, 0)) / Case IsNull((Select uom1_conversion From Items 
-- 		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
-- 		IsNull((Select uom1_conversion From Items 
-- 		Where Product_Code = T.[Item Code]), 0) End,
		
	"Total PAC" = dbo.fn_GetQtyAsUOM1UOM2_ITC(T.[Item Code], Sum(IsNull(T.SalableQty, 0) + IsNull(T.FreeQty, 0)), 2),

-- Sum(IsNull(T.SalableQty, 0)) / Case IsNull((Select uom2_conversion From Items 
-- 		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
-- 		IsNull((Select uom2_conversion From Items 
-- 		Where Product_Code = T.[Item Code]), 0) End + 
-- 
-- 		Sum(IsNull(T.FreeQty, 0)) / Case IsNull((Select uom2_conversion From Items 
-- 		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
-- 		IsNull((Select uom2_conversion From Items 
-- 		Where Product_Code = T.[Item Code]), 0) End,


	"Sch. Disc" = Sum(T. SchDisc), 
	"Discount" = Sum(T.Discount), 
	"VAT/Tax" = Sum(T.Tax), 
	"Total Value" = Sum(T.TValue), 
	"Weight(Kg)" = Cast(Sum((IsNull(T.SalableQty, 0) + IsNull(T.FreeQty,0)) * 
		IsNull(ITS.ConversionFactor,0)) As Decimal(18,6)), 

--	"MRP/PAC" = Cast(IsNull(T.ECP,0) * IsNull(ITS.UOM2_Conversion,0) As Decimal(18,6)), 
    "MRP Per PACK" = IsNull(T.ECP,0), 

	"Sale Price/PAC" = Cast(IsNull(T.SalePrice,0) * 
		IsNull(ITS.UOM2_Conversion,0) As Decimal(18,6)), 

	"Ret Saleable in PAC" = Sum(IsNull(T.SalesReturnSalable, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End,
 
	"Return Damaged in PAC" = Sum(IsNull(T.SalesReturnDamages, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End 
	From #Temp T, Items ITS, #tempCategory1 TC, #tempDiv td
	Where T.[Item Code] = ITS.Product_Code And
		TC.CategoryID = ITS.CategoryID
		 and T.[Item Code] = td.Product_Code
	Group By T.[Item Code], T.[Item Name], T.ECP, T.SalePrice, ITS.UOM2_Conversion, TC.IDS, td.Category, td.Sub_Category
	Order By TC.IDS

End
Else
If @UOM = 'Base UOM'
Begin
	Select "Item Code" = T.[Item Code], 
	"Category"   =  td.Category, 
	"Sub Category" = td.Sub_Category,
	"Item Name" = T.[Item Name],
	"UOM" = IsNull((Select [Description] From UOM Where UOM In (Select UOM From Items 
		Where Product_code = IsNull(T.[Item Code],''))), ''),
	"Qty" = Sum(T.SalableQty), 
	"Free" = Sum(T.FreeQty), 
	"Total Qty" = Sum(T.SalableQty + T.FreeQty), 
	"Sch. Disc" = Sum(T.SchDisc), 	
	"Discount" = Sum(T.Discount), 
	"VAT/Tax" = Sum(T.Tax), 
	"Total Value" = Sum(T.TValue),
	"Weight(Kg)" = Cast(Sum((IsNull(T.SalableQty,0) + IsNull(T.FreeQty,0)) * IsNull(ITS.ConversionFactor,0)) As Decimal(18,6)),
--	"MRP/PAC" = Cast(IsNull(T.ECP,0) * IsNull(ITS.UOM2_Conversion,0) As Decimal(18,6)),
    "MRP Per PACK" = IsNull(T.ECP,0), 
	"Sale Price/PAC" = Cast(IsNull(T.SalePrice,0) * IsNull(ITS.UOM2_Conversion,0) As Decimal(18,6)),

	"Ret Saleable in PAC" = Sum(IsNull(T.SalesReturnSalable, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End,
 
	"Return Damaged in PAC" = Sum(IsNull(T.SalesReturnDamages, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End 

	From #Temp T, Items ITS, #tempCategory1 TC, #tempDiv td
	Where T.[Item Code] = ITS.Product_Code And
		TC.CategoryID = ITS.CategoryID 
		and T.[Item Code] = td.Product_Code
	Group By T.[Item Code], T.[Item Name], T.ECP, T.SalePrice, ITS.UOM2_Conversion, TC.IDS, td.Category, td.Sub_Category
	Order By TC.IDS
End
Else
If @UOM = 'UOM1'
Begin
	Select "Item Code" = T.[Item Code], 
	"Category"   =  td.Category, 
	"Sub Category" = td.Sub_Category,
	"Item Name" = T.[Item Name],
	"UOM" = IsNull((Select [Description] From UOM Where UOM In (Select UOM1 From Items 
		Where Product_code = IsNull(T.[Item Code],''))), ''),
	"Qty" = Sum(IsNull(T.SalableQty, 0)) / Case IsNull((Select uom1_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom1_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End,

	"Free" = Sum(IsNull(T.FreeQty, 0)) / Case IsNull((Select uom1_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom1_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End,

	"Total Qty" = Sum(IsNull(T.SalableQty, 0)) / Case IsNull((Select uom1_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom1_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End +
	
		Sum(IsNull(T.FreeQty, 0)) / Case IsNull((Select uom1_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom1_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End,
 
	"Sch. Disc" = Sum(T.SchDisc), 	
	"Discount" = Sum(T.Discount), 
	"VAT/Tax" = Sum(T.Tax), 
	"Total Value" = Sum(T.TValue),
	"Weight(Kg)" = Cast(Sum((IsNull(T.SalableQty,0) + IsNull(T.FreeQty,0)) * IsNull(ITS.ConversionFactor,0)) As Decimal(18,6)),
--	"MRP/PAC" = Cast(IsNull(T.ECP,0) * IsNull(ITS.UOM2_Conversion,0) As Decimal(18,6)),
    "MRP Per PACK" = IsNull(T.ECP,0), 
	"Sale Price/PAC" = Cast(IsNull(T.SalePrice,0) * IsNull(ITS.UOM2_Conversion,0) As Decimal(18,6)),

	"Ret Saleable in PAC" = Sum(IsNull(T.SalesReturnSalable, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End,
 
	"Return Damaged in PAC" = Sum(IsNull(T.SalesReturnDamages, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End 

	From #Temp T, Items ITS, #tempCategory1 TC, #tempDiv td
	Where T.[Item Code] = ITS.Product_Code
	And TC.CategoryID = ITS.CategoryID 
	and T.[Item Code] = td.Product_Code
	Group By T.[Item Code], T.[Item Name], T.ECP, T.SalePrice, ITS.UOM2_Conversion, TC.IDS, td.Category, td.Sub_Category
	Order By TC.IDS

End
Else
If @UOM = 'UOM2'
Begin
	Select "Item Code" = T.[Item Code], 
	"Category"   =  td.Category, 
	"Sub Category" = td.Sub_Category,	
	"Item Name" = T.[Item Name],
	"UOM" = IsNull((Select [Description] From UOM Where UOM In (Select UOM2 From Items 
		Where Product_code = IsNull(T.[Item Code],''))), ''),
	"Qty" = Sum(IsNull(T.SalableQty, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End,

	"Free" = Sum(IsNull(T.FreeQty, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End,

	"Total Qty" = Sum(IsNull(T.SalableQty, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End +
	
		Sum(IsNull(T.FreeQty, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End,
 
	"Sch. Disc" = Sum(T.SchDisc), 	
	"Discount" = Sum(T.Discount), 
	"VAT/Tax" = Sum(T.Tax), 
	"Total Value" = Sum(T.TValue),
	"Weight(Kg)" = Cast(Sum((IsNull(T.SalableQty,0) + IsNull(T.FreeQty,0)) * IsNull(ITS.ConversionFactor,0)) As Decimal(18,6)),
--	"MRP/PAC" = Cast(IsNull(T.ECP,0) * IsNull(ITS.UOM2_Conversion,0) As Decimal(18,6)),
    "MRP Per PACK" = IsNull(T.ECP,0), 
	"Sale Price/PAC" = Cast(IsNull(T.SalePrice,0) * IsNull(ITS.UOM2_Conversion,0) As Decimal(18,6)),

	"Ret Saleable in PAC" = Sum(IsNull(T.SalesReturnSalable, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End,
 
	"Return Damaged in PAC" = Sum(IsNull(T.SalesReturnDamages, 0)) / Case IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) When 0 Then 1 Else 
		IsNull((Select uom2_conversion From Items 
		Where Product_Code = T.[Item Code]), 0) End 

	From #Temp T, Items ITS, #tempCategory1 TC, #tempDiv td
	Where T.[Item Code] = ITS.Product_Code And
	TC.CategoryID = ITS.CategoryID 
	and T.[Item Code] = td.Product_Code
	Group By T.[Item Code], T.[Item Name], T.ECP, T.SalePrice, ITS.UOM2_Conversion, TC.IDS, td.Category, td.Sub_Category
	Order By TC.IDS
End

-- Update
--  #temp             
-- Set
--  UOM2Qty = dbo.GetFirstLevelUOMQty([Item Code], TotalQty),            
--  UOM2Desc = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  [Item Code])),              
--  UOM1Qty = dbo.GetSecondLevelUOMQty([Item Code], TotalQty),              
--  UOM1Desc = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  [Item Code])),              
--  UOMQty = dbo.GetLastLevelUOMQty([Item Code], TotalQty),              
--  UOMDesc = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  [Item Code]))              

--Select [Item Code],* from #Temp

--Select * from #tempCategory1
                 
Drop Table #Temp  
Drop Table #TempInvNo
Drop Table #TempDocID
Drop Table #tempDiv

Drop Table #TmpSRInvoiceID

