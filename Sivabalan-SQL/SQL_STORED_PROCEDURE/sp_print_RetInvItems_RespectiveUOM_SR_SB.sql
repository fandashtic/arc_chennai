CREATE procedure [dbo].[sp_print_RetInvItems_RespectiveUOM_SR_SB](@INVNO INT)              
AS      
Begin      
      
Declare @Cnt1 Int,@Cnt2 Int, @I Int,@I1 Int,@IDS1 Int,@FQty Decimal(18, 6)      
Declare @IDS Int,@ItmC nVarChar(50),@Batch nVarChar(150),@UOM nVarChar(150)      
      
Select @Cnt1 = 0, @Cnt2 = 0, @I = 0, @I1 = 0, @FQty = 0, @IDS = 0, @IDS1 = 0      
  
Declare @ClosingPoints as Nvarchar(2000)   
Declare @TargetVsAchievement as Nvarchar(2000)   
Declare @CustCode as nvarchar(255)     
Declare @InvoiceDate as DateTime   
  
Set @CustCode='' Set @CustCode=(Select CustomerID from InvoiceAbstract where InvoiceID=@InvNo)    
Set @InvoiceDate = (select  Top 1 dbo.stripTimeFromdate(InvoiceDate) From InvoiceAbstract Where InvoiceID = @INVNO)   
  
set @ClosingPoints = isnull((select Dbo.Fn_Get_CurrentAchievementVal(@CustCode,@InvoiceDate)),'')   
Set @TargetVsAchievement = isnull((select Dbo.Fn_Get_CurrentTarget_AchievementVal(@CustCode,@InvoiceDate)),'')     
      
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
    
Select * into #tmpInvoiceAbstract    
From    
invoiceabstract where invoiceid=@invno    
    
Select * into #tmpInvoiceDetail    
From    
invoicedetail where invoiceid=@invno    
    
        
SELECT      
  Identity(Int, 1, 1) as "id1",      
  "Item Code" = InvoiceDetail.Product_Code,       
  "Item Name" = Items.ProductName,"Batch" = InvoiceDetail.Batch_Number,       
  "Quantity" = Sum(#Temp1.SRQty * InvoiceDetail.UOMQty),      
  "Free" = Cast(0 As Decimal(18,6)),      
  "UOM" = UOM.Description,                 
  "Sale Price" =       
   Case InvoiceDetail.UOMPrice      
    When 0 Then N'Free'      
    Else Cast(InvoiceDetail.UOMPrice As NVarChar)      
   End,      
  "Tax%" = (ISNULL(Max(InvoiceDetail.TaxCode), 0) + ISNULL(Max(InvoiceDetail.TaxCode2), 0)),                 
 "Discount%" = Max(InvoiceDetail.DiscountPercentage),       
 "Scheme Discount%" = SUM(InvoiceDetail.SchemeDiscPercent + InvoiceDetail.SPLCATDISCPERCENT),                
 "Discount Value" = Sum(#Temp1.SRQty * InvoiceDetail.DiscountValue),                 
 "Amount" =         
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
 "Total Savings - Incl Discount" = (Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * IsNull((CASE ItemCategories.Price_Option         
   WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END),0)) -             
 ((SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -              
 ((SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) * (MAX(InvoiceDetail.DiscountPercentage) / 100))),               
    
 "Expiry" =  CAST(DATEPART(mm, Max(Batch_Products.Expiry)) AS nvarchar) + N'/'    
 + SubString(CAST(DATEPART(yy, Max(Batch_Products.Expiry)) AS nvarchar), 3, 2),    
 "MRP" = CASE ItemCategories.Price_Option         
 WHEN 1 THEN         
 Max(InvoiceDetail.MRP)         
 ELSE        
 Max(Items.ECP) END,        
 "PTS" = CASE ItemCategories.Price_Option         
 WHEN 1 THEN         
 Max(InvoiceDetail.PTS)         
 ELSE        
 Max(Items.PTS) END,         
 "PTR" = CASE ItemCategories.Price_Option         
 WHEN 1 THEN         
 Max(InvoiceDetail.PTR)         
 ELSE        
 Max(Items.PTR) END,         
 "Type" = CASE                 
  WHEN InvoiceDetail.SaleID = 1 THEN N'F'                
  WHEN InvoiceDetail.SaleID = 2 THEN N'S'                
  WHEN InvoiceDetail.SaleID = 0 AND Max(InvoiceDetail.STPayable) <> 0 THEN N'F'                
  ELSE N' '                
  END,                
 "Tax Suffered" = ISNULL(Max(InvoiceDetail.TaxSuffered), 0),                
 "Mfr" = Manufacturer.ManufacturerCode, "Description" = Items.Description,                
 "Category" = ItemCategories.Category_Name,                
 "Item Gross Value" = Case Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice                
 When 0 then                
 NULL                
 Else                
 Cast(Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice as nvarchar)                
 End,                
 "Amount Before Tax" = Sum(#Temp1.SRQty * InvoiceDetail.Amount) - (Max(#Temp1.SRQty * InvoiceDetail.STPayable) + Max(#Temp1.SRQty * InvoiceDetail.CSTPayable)),                
 "Property1" = dbo.GetProperty(InvoiceDetail.Product_Code, 1),                
 "Property2" = dbo.GetProperty(InvoiceDetail.Product_Code, 2),                
 "Property3" = dbo.GetProperty(InvoiceDetail.Product_Code, 3),                
 "Reporting Unit Qty" = (Sum(InvoiceDetail.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),                
 "Conversion Unit Qty" = Sum(InvoiceDetail.Quantity) * Items.ConversionFactor,                
 "Rounded Reporting Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),                
 "Rounded Conversion Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) * Items.ConversionFactor),                
 "Mfr Name" = Manufacturer.Manufacturer_Name,                
 "Divison" = Brand.BrandName,                
 "Tax Applicable Value" = IsNull(Sum(#Temp1.SRQty * InvoiceDetail.STPayable), 0) + IsNull(Sum(#Temp1.SRQty * InvoiceDetail.CSTPayable), 0),                
 "Tax Suffered Value" =         
 case InvoiceAbstract.TaxOnMRP when 1 then         
 Round(IsNull(Sum(#Temp1.SRQty * InvoiceDetail.Quantity * (CASE ItemCategories.Price_Option         
 WHEN 1 THEN InvoiceDetail.MRP ELSE Items.ECP END) * dbo.fn_get_TaxOnMRP(InvoiceDetail.TaxSuffered) / 100), 0),6)        
 else        
 IsNull(Sum(#Temp1.SRQty * InvoiceDetail.Quantity * InvoiceDetail.SalePrice * InvoiceDetail.TaxSuffered / 100), 0)        
 end,        
 "Reporting UOM" = RUOM.Description,                
 "Conversion Unit" = ConversionTable.ConversionUnit,                
 "Reporting Factor" = Items.ReportingUnit,                
 "Conversion Factor" = Items.ConversionFactor,              
 "PKD" = CAST(DATEPART(mm, Max(Batch_Products.PKD)) AS nvarchar) + N'/'     
  + SubString(CAST(DATEPART(yy, Max(Batch_Products.PKD)) AS nvarchar), 3, 2),                
 "Net Rate" = Cast(        
 case IsNull(InvoiceAbstract.TaxOnMRP,0)        
 when 1 then         
  (case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = #Temp1.Invno)                
  WHEN 0 THEN                 
   Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) +             
   (SUM(InvoiceDetail.Quantity) * (CASE ItemCategories.Price_Option         
   WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END)        
   * dbo.fn_get_TaxOnMRP(Max(InvoiceDetail.TaxCode)) / 100),6))             
   When 0 then                
    NULL                
   Else                
   Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) +             
   (SUM(InvoiceDetail.Quantity) * (CASE ItemCategories.Price_Option         
   WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END)        
   * dbo.fn_get_TaxOnMRP(Max(InvoiceDetail.TaxCode)) / 100),6)             
   End          
  ELSE            
   Case ((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -                 
   (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *                 
   Max(InvoiceDetail.DiscountPercentage) / 100))                
   When 0 then                
    NULL                
   Else                
    Cast((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -                 
    (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *                 
    Max(InvoiceDetail.DiscountPercentage) / 100) as nvarchar)                
   End                
  END)         
 else      
  (case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = #Temp1.Invno)                
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
    Cast(Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice -                 
    (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *                 
    Max(InvoiceDetail.DiscountPercentage) / 100) +                 
    ((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice                 
    - (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *                 
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
    Cast((Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -                 
    (Sum(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *                 
    Max(InvoiceDetail.DiscountPercentage) / 100) as nvarchar)                
   End                
 END)         
 end        
 / CASE WHEN Sum(InvoiceDetail.UOMQty) = 0 THEN 1 ELSE Sum(InvoiceDetail.UOMQty) END As Decimal(18,6)),               
 "Net Item Rate" = Cast(Sum(InvoiceDetail.Amount) / CASE WHEN Sum(InvoiceDetail.UOMQty) = 0 THEN 1 ELSE Sum(InvoiceDetail.UOMQty) END As Decimal(18,6)),         
 "Net Value" = Sum(#Temp1.SRQty * Amount),         
 "Tax Suffered Desc" = (select Tax_description from Tax where tax_code = items.TaxSuffered),        
 "Sales Tax Desc" = (select Tax_description from Tax where tax_code = InvoiceDetail.TaxID),    
-- "Item MRP" = isnull(Items.MRP,0),         
 "Item MRP" = case Isnull(InvoiceDetail.MRPPerPack,0) when 0 then isnull(Items.MRPPerPack,0) else Isnull(InvoiceDetail.MRPPerPack,0) End,   
 "SPBED" = IsNull(InvoiceDetail.SalePriceBeforeExciseAmount, 0),         
 "Excise duty" = IsNull(InvoiceDetail.ExciseDuty, 0),"Serial" = InvoiceDetail.Serial,     
 "Sales Tax Credit" = InvoiceDetail.STCredit, "Sold As" = Items.Soldas ,  
"ClosingPoints as on Date" = @ClosingPoints,   
"Target Vs Achievement" = @TargetVsAchievement    
,InvoiceDetail.TaxID
,Items.HSNNumber
Into      
 #TmpInvDet        
FROM      
 #tmpInvoiceAbstract InvoiceAbstract,#tmpInvoicedetail InvoiceDetail,UOM,Items,Batch_Products,Manufacturer,      
 ItemCategories,Brand,UOM As RUOM,ConversionTable,#Temp1        
WHERE      
 InvoiceAbstract.InvoiceID = #Temp1.invno                       
 AND InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID        
 AND InvoiceDetail.Product_Code = Items.Product_Code                
 AND InvoiceDetail.UOM = UOM.UOM                
 AND InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code                
 AND Items.ManufacturerID = Manufacturer.ManufacturerID                 
 AND Items.CategoryID = ItemCategories.CategoryID                
 And Items.BrandID = Brand.BrandID                
 And Items.ReportingUOM = RUOM.UOM                
 And Items.ConversionUnit = ConversionTable.ConversionID      
GROUP BY      
 #Temp1.InvID,InvoiceDetail.Product_code, Items.ProductName,       
 InvoiceDetail.Batch_Number,InvoiceDetail.SalePrice,      
 InvoiceDetail.SaleID, ItemCategories.Price_Option,             
 Manufacturer.ManufacturerCode, Items.Description, ItemCategories.Category_Name,              
 Items.ReportingUnit, Items.ConversionFactor, Manufacturer.Manufacturer_Name,              
 Brand.BrandName, RUOM.Description, ConversionTable.ConversionID,               
 ConversionTable.ConversionUnit, UOM.Description, InvoiceDetail.UOMPrice,      
 InvoiceAbstract.TaxOnMRP,Items.TaxSuffered,Items.Sale_Tax,Isnull(InvoiceDetail.MRPPerPack,0),Items.MRPPerPack,  
 InvoiceDetail.TaxID,#Temp1.Invno,InvoiceDetail.SalePriceBeforeExciseAmount,        
 InvoiceDetail.ExciseDuty, InvoiceDetail.UOM,InvoiceDetail.STCredit, Items.Soldas,     
 InvoiceDetail.Serial    
      
Select @Cnt1 = Count(*) From #TmpInvDet Where [Sale Price] = N'Free'      
While @I < @Cnt1      
 Begin      
  Select       
   Top 1 @IDS = [id1],  @FQty = [Quantity], @ItmC = [Item Code],@Batch = [Batch], @UOM = [UOM]      
  From      
   #TmpInvDet      
  Where      
   [Sale Price] = N'Free' And [id1] > @IDS      
  Order By      
   [id1]      
        
  Select       
   @Cnt2 = Count(*)      
  From      
   #TmpInvDet      
  Where       
   [Item Code] = @ItmC And [Batch] = @Batch      
   And [UOM] = @UOM And [Sale Price] <> N'Free'      
        
  Select      
   Top 1 @IDS1 = [id1]      
  From      
   #TmpInvDet      
  Where       
   [Item Code] = @ItmC And [Batch] = @Batch      
   And [UOM] = @UOM And [Sale Price] <> N'Free'      
  Order By      
   [id1]      
        
  Set @I1 = @Cnt2 - 1      
  While @I1 < @Cnt2      
   Begin      
    If @ids1 > 0      
     Update #TmpInvDet Set [Free] = [Free] + @FQty Where [id1] = @IDS1      
    Else      
     Update #TmpInvDet Set  [Quantity] = Cast(0 As Decimal(18, 6)), [Free] = [Free] + @FQty Where [id1] = @IDS      
    Set @I1 = @I1 + 1      
   End       
  Select @I1 = 0, @IDS1 = 0      
  Set @I = @I + 1      
 End      
       
 Delete From #TmpInvDet Where [Sale Price] = N'Free' And [Free] = 0      
      
 Update #TmpInvDet Set [Sale Price] = Cast(0 As Decimal(18,6)) Where [Sale Price] = N'Free'      
      
 Select *,
"cgst"	 = (case when dbo.[fn_GetTaxValueByComponent](TaxID,2) > 0 then dbo.[fn_GetTaxValueByComponent](TaxID,2)/100 else 0 end)  * Amount
,"SGST"	 = (case when dbo.[fn_GetTaxValueByComponent](TaxID,3) > 0 then dbo.[fn_GetTaxValueByComponent](TaxID,3)/100 else 0 end)  * Amount
,"IGST"	 = (case when dbo.[fn_GetTaxValueByComponent](TaxID,4) > 0 then dbo.[fn_GetTaxValueByComponent](TaxID,4)/100 else 0 end)  * Amount
,"CESS"	 = (case when dbo.[fn_GetTaxValueByComponent](TaxID,5) > 0 then dbo.[fn_GetTaxValueByComponent](TaxID,5)/100 else 0 end)  * Amount
,"ADDL CESS"= dbo.[fn_GetTaxValueByComponent](TaxID,6)  * (Quantity)
 From #TmpInvDet Order By Serial      
    
 Drop Table #TmpInvDet        
 Drop Table #Temp1         
 Drop table #tmpInvoiceAbstract    
 Drop table #tmpInvoiceDetail    
End
