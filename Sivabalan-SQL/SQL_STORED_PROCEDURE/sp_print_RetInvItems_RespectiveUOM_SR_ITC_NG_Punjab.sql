Create Procedure dbo.sp_print_RetInvItems_RespectiveUOM_SR_ITC_NG_Punjab(@INVNO INT,@MODE INT = 0)          
AS  
Begin  
	Declare @Cnt1 Int,@Cnt2 Int, @I Int,@I1 Int,@IDS1 Int,@FQty Decimal(18, 6)  
	Declare @IDS Int,@ItmC nVarChar(50),@Batch nVarChar(150),@UOM nVarChar(150)  

	Select @Cnt1 = 0, @Cnt2 = 0, @I = 0, @I1 = 0, @FQty = 0, @IDS = 0, @IDS1 = 0  

	Create Table #Temp1 (InvID int identity(1,1), invno int,SRQty Decimal(18,6))    
	Insert into #Temp1(Invno,SRQty) Values (@invno,1)    

	If (Select Count(CollectionDetail.DocumentID) From CollectionDetail,InvoiceAbstract    
		Where InvoiceAbstract.InvoiceId = @invno and   
		ISnull(InvoiceAbstract.PaymentDetails,0)=CollectionDetail.CollectionID    
		And CollectionDetail.DocumentType=1 And InvoiceAbstract.InvoiceType in (1,3)) > 0     
	Begin    
		INsert into #Temp1(Invno,SRQty)     
		Select CollectionDetail.DocumentID,-1 From CollectionDetail,InvoiceAbstract    
		Where InvoiceAbstract.InvoiceId = @invno and   
		ISnull(InvoiceAbstract.PaymentDetails,0)=CollectionDetail.CollectionID    
		And CollectionDetail.DocumentType=1 And InvoiceAbstract.InvoiceType in (1,3)    
	End    

	Select  
	Identity(Int, 1, 1) as "id1",  
	"Quantity" = Cast((Case When InvoiceDetail.UOMPrice <>0  Then Sum(#Temp1.SRQty * InvoiceDetail.UOMQty) Else 0 End) as decimal(18,2)),  
	"Free" = Cast((Case When InvoiceDetail.UOMPrice = 0  Then Sum(#Temp1.SRQty * InvoiceDetail.UOMQty) Else 0 End) as decimal(18,2)),  
	"UOM" = UOM.Description,             
	"Sale Price" =  
	Case InvoiceDetail.UOMPrice  
		When 0 Then N'Free'  
		Else Cast(InvoiceDetail.UOMPrice As NVarChar)  
	End,  

	"TaxDetails" = dbo.GetTaxCompInfo(Max(InvoiceDetail.InvoiceID),InvoiceDetail.Product_Code, 
						Max(InvoiceDetail.TaxID), Sum(InvoiceDetail.STPayable)),
	"TaxDetailsWithBreakup" = dbo.GetTaxCompInfoWithBreakup(Max(InvoiceDetail.InvoiceID),InvoiceDetail.Product_Code,
	Max(InvoiceDetail.TaxID),
	Sum(InvoiceDetail.STPayable)),
	"Discount%" = Max(InvoiceDetail.DiscountPercentage),  
	"Discount Value" = Sum(#Temp1.SRQty * InvoiceDetail.DiscountValue),             
	"Amount"=
	Case IsNull(InvoiceAbstract.TaxOnMRP,0)    
	When 1 Then Case (Select Top 1 Flags From InvoiceAbstract Where InvoiceID = #Temp1.Invno)            
	When 0 Then Case (Round((SUM(InvoiceDetail.Quantity) * (Case ItemCategories.Price_Option     
	When 1 Then Max(InvoiceDetail.MRP) Else Max(Items.ECP) End)) +  (SUM(InvoiceDetail.Quantity) * (Case ItemCategories.Price_Option     
	When 1 Then Max(InvoiceDetail.MRP) Else Max(Items.ECP) End) * dbo.fn_get_TaxOnMRP(Max(InvoiceDetail.TaxCode)) / 100),6))         
	When 0 Then NULL            
	Else Cast(Round((SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * (Case ItemCategories.Price_Option     
	When 1 Then Max(InvoiceDetail.MRP) Else Max(Items.ECP) End)) +         
	(SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * (Case ItemCategories.Price_Option     
	When 1 Then Max(InvoiceDetail.MRP) Else Max(Items.ECP) End)     
	* dbo.fn_get_TaxOnMRP(Max(InvoiceDetail.TaxCode)) / 100),6) As nvarchar)    
	End            
	Else            
	Case ((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -             
	(Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *             
	Max(InvoiceDetail.DiscountPercentage) / 100))            
	When 0 Then            
	NULL            
	Else            
	Cast((Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -             
	(Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *             
	Max(InvoiceDetail.DiscountPercentage) / 100) as nvarchar)            
	End            
	End    
	Else   
	Case (Select Top 1 Flags From InvoiceAbstract Where InvoiceID = #Temp1.Invno)            
	When 0 Then             
	Case ((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -             
	(Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *             
	Max(InvoiceDetail.DiscountPercentage) / 100) +             
	((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice             
	- (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *             
	Max(InvoiceDetail.DiscountPercentage) / 100))             
	* Max(InvoiceDetail.TaxCode) / 100))            
	When 0 Then            
	NULL            
	Else            
	Cast((Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -             
	(Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *             
	Max(InvoiceDetail.DiscountPercentage) / 100) +       
	((Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice             
	- (Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *             
	Max(InvoiceDetail.DiscountPercentage) / 100))             
	* Max(InvoiceDetail.TaxCode) / 100) as nvarchar)            
	End            
	Else            
	Case ((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -             
	(Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *             
	Max(InvoiceDetail.DiscountPercentage) / 100))            
	When 0 Then            
	NULL            
	Else            
	Cast((Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -             
	(Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *             
	Max(InvoiceDetail.DiscountPercentage) / 100) as nvarchar)            
	End       
	End    
	End,            
	"Description" = Items.Description,            
	"Item Gross Value" = Case Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice            
	When 0 Then            
	NULL            
	Else            
	Cast(Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice as nvarchar)            
	End,            
	"Net Value" =  Sum(#Temp1.SRQty * ((InvoiceDetail.uomqty * InvoiceDetail.uomprice) 
	+ InvoiceDetail.stpayable + InvoiceDetail.cstpayable + InvoiceDetail.STCredit - InvoiceDetail.DiscountValue)), 
	"Net Amount" = Sum(#Temp1.SRQty * Amount), --Sum(#Temp1.SRQty * ((InvoiceDetail.Quantity * InvoiceDetail.SalePrice) + InvoiceDetail.TaxAmount - InvoiceDetail.DiscountValue)),  
--	"Item MRP" = isnull(Items.MRP,0),     
--	"Item MRP" = case isnull(Max(Batch_Products.MRPPerPack),0) when 0 then isnull(Items.MRPPerPack,0) else isnull(Max(Batch_Products.MRPPerPack),0) end ,     
	"Item MRP" = case isnull(InvoiceDetail.MRPPerPack,0) when 0 then isnull(Items.MRPPerPack,0) else isnull(InvoiceDetail.MRPPerPack,0) end ,    
	"Serial"= Min(InvoiceDetail.Serial),
	"Batch.No" = Cast(Isnull(Ltrim(Rtrim(Batch_Products.Batch_Number)),'') as Nvarchar(9)),
	"Mrf.Dt." = dbo.fn_dateMY(Batch_Products.PKD),
	"Exp.Dt." = dbo.fn_dateMY(Batch_Products.Expiry)
	Into  
	#TmpInvDet    
	From  
	InvoiceAbstract
	Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID    
	Left Outer Join UOM On InvoiceDetail.UOM = UOM.UOM            
	Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code            
	Left Outer Join Batch_Products On InvoiceDetail.Batch_Code = Batch_Products.Batch_Code            
	Left Outer Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID             
	Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID            
	Inner Join Brand On Items.BrandID = Brand.BrandID            
	Left Outer Join UOM As RUOM On  Items.ReportingUOM = RUOM.UOM            
	Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID    
	Inner Join #Temp1 On InvoiceAbstract.InvoiceID = #Temp1.invno                       
	GROUP BY  
	#Temp1.InvID,InvoiceDetail.Product_code, Items.ProductName,   
	InvoiceDetail.Batch_Number,InvoiceDetail.SalePrice,  
	InvoiceDetail.SaleID, ItemCategories.Price_Option,         
	Manufacturer.ManufacturerCode, Items.Description, ItemCategories.Category_Name,          
	Items.ReportingUnit, Items.ConversionFactor, Manufacturer.Manufacturer_Name,          
	Brand.BrandName, RUOM.Description, ConversionTable.ConversionID,           
	ConversionTable.ConversionUnit, UOM.Description, InvoiceDetail.UOMPrice,  
--	InvoiceAbstract.TaxOnMRP,Items.TaxSuffered,Items.Sale_Tax,Items.MRP,  
--	InvoiceAbstract.TaxOnMRP,Items.TaxSuffered,Items.Sale_Tax,Items.MRPPerPack,  
	InvoiceAbstract.TaxOnMRP,Items.TaxSuffered,Items.Sale_Tax,Isnull(InvoiceDetail.MRPPerPack,0),Items.MRPPerPack,    
	InvoiceDetail.TaxID,#Temp1.Invno,
	InvoiceDetail.UOM, Items.Soldas,Batch_Products.Batch_Number,Batch_Products.PKD,Batch_Products.Expiry,Items.UOM2_Conversion
	Order By Serial

	Update #TmpInvDet Set [Sale Price] = Cast(0 As Decimal(18,6)), [Amount] = Cast(0 As Decimal(18,6)) , [Item Gross Value] = Cast(0 As Decimal(18,6))  
	Where [Sale Price] = N'Free'

	--Select * From  #TmpInvDet Order By Serial
	IF @MODE = 0
		Select * From  #TmpInvDet Order By Serial
    ELSE
		Select Count(*) From  #TmpInvDet 

	Drop Table #TmpInvDet    
	Drop Table #Temp1     
End   
