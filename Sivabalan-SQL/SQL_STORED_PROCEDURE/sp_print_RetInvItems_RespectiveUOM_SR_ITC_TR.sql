
Create Procedure [dbo].[sp_print_RetInvItems_RespectiveUOM_SR_ITC_TR](@INVNO INT,@MODE INT=0)          
AS  
Begin  
 
Declare @Cnt1 Int,@Cnt2 Int, @I Int,@I1 Int,@IDS1 Int,@FQty Decimal(18, 6)  
Declare @IDS Int,@ItmC nVarChar(50),@Batch nVarChar(150),@UOM nVarChar(150)  
  
Select @Cnt1 = 0, @Cnt2 = 0, @I = 0, @I1 = 0, @FQty = 0, @IDS = 0, @IDS1 = 0  
  
Create Table #Temp1 (InvID int identity(1,1), invno int,SRQty Decimal(18,6))    
Insert into #Temp1(Invno,SRQty) Values (@invno,1)    
 If  
 (  
  SELECT Count(CollectionDetail.DocumentID) FROM CollectionDetail,InvoiceAbstract    
  Where InvoiceAbstract.InvoiceId = @invno and   
  ISnull(InvoiceAbstract.PaymentDetails,0)=CollectionDetail.CollectionID    
  And CollectionDetail.DocumentType=1 And InvoiceAbstract.InvoiceType in (1,3)  
 ) > 0     
 Begin    
  INsert into #Temp1(Invno,SRQty)     
  SELECT CollectionDetail.DocumentID,-1 FROM CollectionDetail,InvoiceAbstract    
  Where InvoiceAbstract.InvoiceId = @invno and   
  ISnull(InvoiceAbstract.PaymentDetails,0)=CollectionDetail.CollectionID    
  And CollectionDetail.DocumentType=1 And InvoiceAbstract.InvoiceType in (1,3)    
 End    
    
SELECT  
  Identity(Int, 1, 1) as "id1",  
  "Quantity" = Cast((Case When InvoiceDetail.UOMPrice <>0  THEN Sum(#Temp1.SRQty * InvoiceDetail.UOMQty) Else 0 End) as decimal(18,2)),  
  "Free" = Cast((Case When InvoiceDetail.UOMPrice = 0  THEN Sum(#Temp1.SRQty * InvoiceDetail.UOMQty) Else 0 End) as decimal(18,2)),  
  "UOM" = UOM.Description,             
  "Sale Price" =  
   Case InvoiceDetail.UOMPrice  
    When 0 Then N'Free'  
    Else Cast(InvoiceDetail.UOMPrice As NVarChar)  
   End,  
--"TaxDetails" = dbo.GetTaxCompInfo(Max(InvoiceDetail.InvoiceID),InvoiceDetail.Product_Code),
--"TaxDetailsWithBreakup" = dbo.GetTaxCompInfoWithBreakup(Max(InvoiceDetail.InvoiceID),InvoiceDetail.Product_Code),

"TaxDetails" = dbo.GetTaxCompInfo(Max(InvoiceDetail.InvoiceID),InvoiceDetail.Product_Code, 
										Max(InvoiceDetail.TaxID), Sum(InvoiceDetail.STPayable)),
"TaxDetailsWithBreakup" = dbo.GetTaxCompInfoWithBreakup(Max(InvoiceDetail.InvoiceID),InvoiceDetail.Product_Code, 
								Max(InvoiceDetail.TaxID), Sum(InvoiceDetail.STPayable)),


 "Discount%" = Max(InvoiceDetail.DiscountPercentage),  
 "Discount Value" = Sum(#Temp1.SRQty * InvoiceDetail.DiscountValue),             
 "Amount"=
 case IsNull(InvoiceAbstract.TaxOnMRP,0)    
 when 1 then     
  case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = #Temp1.Invno)            
  WHEN 0 THEN             
   Case (Round((SUM(InvoiceDetail.Quantity) * (CASE ItemCategories.Price_Option     
   WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END)) +         
   (SUM(InvoiceDetail.Quantity) * (CASE ItemCategories.Price_Option     
   WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END)     
   * dbo.fn_get_TaxOnMRP(Max(InvoiceDetail.TaxCode)) / 100),6))         
   When 0 then            
    NULL            
   Else            
   Cast(Round((SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * (CASE ItemCategories.Price_Option     
   WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END)) +         
   (SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * (CASE ItemCategories.Price_Option     
   WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END)     
   * dbo.fn_get_TaxOnMRP(Max(InvoiceDetail.TaxCode)) / 100),6) As nvarchar)    
   End            
  ELSE            
   Case ((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -             
   (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *             
   Max(InvoiceDetail.DiscountPercentage) / 100))            
   When 0 then            
    NULL            
   Else            
    Cast((Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -             
    (Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *             
    Max(InvoiceDetail.DiscountPercentage) / 100) as nvarchar)            
   End            
  END    
 else   
  case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = #Temp1.Invno)            
  WHEN 0 THEN             
   Case ((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -             
   (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *             
   Max(InvoiceDetail.DiscountPercentage) / 100) +             
   ((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice             
   - (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *             
   Max(InvoiceDetail.DiscountPercentage) / 100))             
   * Max(InvoiceDetail.TaxCode) / 100))            
   When 0 then            
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
  ELSE            
   Case ((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -             
   (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *             
   Max(InvoiceDetail.DiscountPercentage) / 100))            
   When 0 then            
    NULL            
   Else            
    Cast((Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -             
    (Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *             
    Max(InvoiceDetail.DiscountPercentage) / 100) as nvarchar)            
   End       
  END    
 end,            
	"Description" = Items.Description,            
 "Item Gross Value" = Case Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice            
 When 0 then            
 NULL            
 Else            
 Cast(Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice as nvarchar)            
 End,            
"Net Value" =  Sum(#Temp1.SRQty * ((InvoiceDetail.uomqty * InvoiceDetail.uomprice) 
	+ InvoiceDetail.stpayable + InvoiceDetail.cstpayable + InvoiceDetail.STCredit - InvoiceDetail.DiscountValue)), 
"Net Amount" = Sum(#Temp1.SRQty * Amount), --Sum(#Temp1.SRQty * ((InvoiceDetail.Quantity * InvoiceDetail.SalePrice) + InvoiceDetail.TaxAmount - InvoiceDetail.DiscountValue)),  
 --"Item MRP" = isnull(Items.MRP,0),     
--"Item MRP" = case isnull(Max(Batch_Products.MRPPerPack),0) when 0 then isnull(Items.MRPPerPack,0) else isnull(Max(Batch_Products.MRPPerPack),0) end ,     
"Item MRP" = case isnull(InvoiceDetail.MRPPerPack,0) when 0 then isnull(Items.MRPPerPack,0) else isnull(InvoiceDetail.MRPPerPack,0) end , 
"Serial"= Min(InvoiceDetail.Serial)
Into  
 #TmpInvDet    
FROM  InvoiceAbstract
Inner Join #Temp1 On InvoiceAbstract.InvoiceID = #Temp1.invno                   
Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID    
Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code            
Left Outer Join UOM On InvoiceDetail.UOM = UOM.UOM            
Left Outer Join Batch_Products On InvoiceDetail.Batch_Code = Batch_Products.Batch_Code            
Left Outer Join Manufacturer On Items.ManufacturerID = Manufacturer.ManufacturerID             
Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID            
Inner Join Brand On Items.BrandID = Brand.BrandID            
Left Outer Join UOM As RUOM On Items.ReportingUOM = RUOM.UOM            
Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID    
-- AND InvoiceDetail.UOMQty > 0    
GROUP BY  
 #Temp1.InvID,InvoiceDetail.Product_code, Items.ProductName,   
 InvoiceDetail.Batch_Number,InvoiceDetail.SalePrice,  
  InvoiceDetail.SaleID, ItemCategories.Price_Option,         
 Manufacturer.ManufacturerCode, Items.Description, ItemCategories.Category_Name,          
 Items.ReportingUnit, Items.ConversionFactor, Manufacturer.Manufacturer_Name,          
 Brand.BrandName, RUOM.Description, ConversionTable.ConversionID,           
 ConversionTable.ConversionUnit, UOM.Description, InvoiceDetail.UOMPrice,  
-- InvoiceAbstract.TaxOnMRP,Items.TaxSuffered,Items.Sale_Tax,Items.MRP,  
-- InvoiceAbstract.TaxOnMRP,Items.TaxSuffered,Items.Sale_Tax,Items.MRPPerPack,  
InvoiceAbstract.TaxOnMRP,Items.TaxSuffered,Items.Sale_Tax,Isnull(InvoiceDetail.MRPPerPack,0),Items.MRPPerPack,  
 InvoiceDetail.TaxID,#Temp1.Invno,
 InvoiceDetail.UOM, Items.Soldas
Order By Serial
  
  
Update #TmpInvDet Set [Sale Price] = Cast(0 As Decimal(18,6)), [Amount] = Cast(0 As Decimal(18,6)) , [Item Gross Value] = Cast(0 As Decimal(18,6))  
Where [Sale Price] = N'Free'

IF @MODE=0
	Select * From  #TmpInvDet Order By Serial
ELSE
	Select count(*) from #TmpInvDet
 
 Drop Table #TmpInvDet    
 Drop Table #Temp1     
End   
