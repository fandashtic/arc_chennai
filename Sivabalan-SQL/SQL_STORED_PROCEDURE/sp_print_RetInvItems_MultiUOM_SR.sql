CREATE PROCEDURE sp_print_RetInvItems_MultiUOM_SR(@INVNO INT)
AS
Declare @Cnt1 Int,@Cnt2 Int, @I Int,@I1 Int,@IDS1 Int,@FQty Decimal(18, 6)  
Declare @IDS Int,@ItmC nVarChar(50),@Batch nVarChar(150),@UOM nVarChar(150)  
  
Select @Cnt1 = 0, @Cnt2 = 0, @I = 0, @I1 = 0, @FQty = 0, @IDS = 0, @IDS1 = 0  
  
--1 is set in SrQty when it is a Normal Invoice /SR and -1 for those SR which are adjusted  
Create Table #Temp1 (InvID int identity(1,1), invno int,SRQty Decimal(18,6))  
Insert into #Temp1(Invno,SRQty) Values (@invno,1)  
 If (SELECT Count(CollectionDetail.DocumentID) FROM CollectionDetail,InvoiceAbstract  
   Where InvoiceAbstract.InvoiceId = @invno and ISnull(InvoiceAbstract.PaymentDetails,0)=CollectionDetail.CollectionID  
   And CollectionDetail.DocumentType=1 And InvoiceAbstract.InvoiceType in (1,3)) > 0   
 Begin  
  INsert into #Temp1(Invno,SRQty)   
    SELECT CollectionDetail.DocumentID,-1 FROM CollectionDetail,InvoiceAbstract  
    Where InvoiceAbstract.InvoiceId = @invno and ISnull(InvoiceAbstract.PaymentDetails,0)=CollectionDetail.CollectionID  
    And CollectionDetail.DocumentType=1 And InvoiceAbstract.InvoiceType in (1,3)  
 End  
  
SELECT  
 Identity(Int, 1, 1) as "id1",  
 "Item Code" = InvoiceDetail.Product_Code, "Item Name" = Items.ProductName,       
 "Quantity" = Sum(#Temp1.SRQty * InvoiceDetail.Quantity),   
 "UOM" = UOM.Description,      
 "UOM2Quantity" =  
  Case InvoiceDetail.SalePrice  
   When 0 Then 0   
   Else dbo.GetFirstLevelUOMQty(InvoiceDetail.Product_Code, Sum(#Temp1.SRQty *InvoiceDetail.Quantity))  
  End,  
 "UOM2Description" =   
  Case InvoiceDetail.SalePrice  
   When 0 Then N''   
   Else (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  InvoiceDetail.Product_Code ))  
  End,  
 "UOM2Price" =   
  Case InvoiceDetail.SalePrice  
   When 0 Then 0   
   Else  
    Isnull(Max(UOM2_Conversion),0) *  
    (Case ItemCategories.Price_Option   
    When 1 Then  
    Max((Case CustomerCategory When 1 Then InvoiceDetail.PTS When 2 Then InvoiceDetail.PTR ELSE InvoiceDetail.MRP END))   
    Else  
    Max((Case CustomerCategory When 1 Then Items.PTS When 2 Then Items.PTR ELSE Items.ECP END))   
    End)  
  End,  
 "UOM1Quantity" =   
  Case InvoiceDetail.SalePrice  
   When 0 Then 0   
   Else dbo.GetSecondLevelUOMQty(InvoiceDetail.Product_Code, Sum(#Temp1.SRQty *InvoiceDetail.Quantity))  
  End,  
 "UOM1Description" =   
  Case InvoiceDetail.SalePrice  
   When 0 Then N''   
   Else (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  InvoiceDetail.Product_Code ))  
  End,  
 "UOM1Price" =  
  Case InvoiceDetail.SalePrice  
   When 0 Then 0   
   Else  
    Isnull(Max(UOM1_Conversion),0) *  
    (Case ItemCategories.Price_Option   
    When 1 Then  
    Max((Case CustomerCategory When 1 Then InvoiceDetail.PTS When 2 Then InvoiceDetail.PTR ELSE InvoiceDetail.MRP END))   
    Else  
    Max((Case CustomerCategory When 1 Then Items.PTS When 2 Then Items.PTR ELSE Items.ECP END))   
    End)  
  End,  
 "UOMQuantity" =   
  Case InvoiceDetail.SalePrice  
   When 0 Then 0   
   Else dbo.GetLastLevelUOMQty(InvoiceDetail.Product_Code, Sum(#Temp1.SRQty *InvoiceDetail.Quantity))  
  End,  
 "UOMDescription" =   
  Case InvoiceDetail.SalePrice  
   When 0 Then N''   
   Else (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  InvoiceDetail.Product_Code ))  
  End,  
 "UOMPrice" =   
  Case InvoiceDetail.SalePrice  
   When 0 Then 0   
   Else  
    (Case ItemCategories.Price_Option   
    When 1 Then  
    Max((Case CustomerCategory When 1 Then InvoiceDetail.PTS When 2 Then InvoiceDetail.PTR ELSE InvoiceDetail.MRP END))   
    Else  
    Max((Case CustomerCategory When 1 Then Items.PTS When 2 Then Items.PTR ELSE Items.ECP END))   
    End)  
  End,  
 "Free" = Cast(0 As Decimal(18,6)),  
 "Batch" = InvoiceDetail.Batch_Number,       
 "Sale Price" =   
   Case InvoiceDetail.SalePrice  
    When 0 Then N'Free'  
    Else Cast(InvoiceDetail.SalePrice As NVarChar)  
   End,  
 "Tax%" = (ISNULL(Max(InvoiceDetail.TaxCode), 0) + ISNULL(Max(InvoiceDetail.TaxCode2), 0)),       
 "Discount%" = MAX(InvoiceDetail.DiscountPercentage), 
 "Scheme Discount%" = SUM(InvoiceDetail.SchemeDiscPercent),       
 "Discount Value" = SUM(#Temp1.SRQty * InvoiceDetail.DiscountValue),       
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
    N''      
   Else      
   Cast(Round((SUM(#Temp1.SRQty *InvoiceDetail.Quantity) * (CASE ItemCategories.Price_Option   
   WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END)) +       
   (SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * (CASE ItemCategories.Price_Option   
   WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END)   
   * dbo.fn_get_TaxOnMRP(Max(InvoiceDetail.TaxCode)) / 100),6) As nvarchar)  
   End      
  ELSE      
   Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
   (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
   MAX(InvoiceDetail.DiscountPercentage) / 100), 6))      
   When 0 then      
    N''      
   Else      
    Cast(Round((SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
    (SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
    MAX(InvoiceDetail.DiscountPercentage) / 100), 6) as nvarchar)      
   End      
  END  
 else --when TaxOnMRP = 0  
  case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = #Temp1.Invno)      
  WHEN 0 THEN       
  Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
  (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
  MAX(InvoiceDetail.DiscountPercentage) / 100) +       
  (((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice)       
  - (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
  MAX(InvoiceDetail.DiscountPercentage) / 100))       
  * Max(InvoiceDetail.TaxCode) / 100), 6))      
  When 0 then      
  N''      
  Else      
  Cast(Round((SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
  (SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
  MAX(InvoiceDetail.DiscountPercentage) / 100) +       
  (((SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice)       
  - (SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
  MAX(InvoiceDetail.DiscountPercentage) / 100))       
  * Max(InvoiceDetail.TaxCode) / 100), 6) as nvarchar)      
  End      
  ELSE      
  Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
  (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
  MAX(InvoiceDetail.DiscountPercentage) / 100), 6))      
  When 0 then      
  N''      
  Else      
  Cast(Round((SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
  (SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
  MAX(InvoiceDetail.DiscountPercentage) / 100), 6) as nvarchar)      
  End      
  END  
 end,      
 "Total Savings - Incl Discount" = (Sum(#Temp1.SRQty * InvoiceDetail.Quantity) * IsNull((CASE ItemCategories.Price_Option   
   WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END),0)) -       
 ((SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -        
 ((SUM(#Temp1.SRQty * InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) * (MAX(InvoiceDetail.DiscountPercentage) / 100))),      
 "Expiry" = CAST(DATEPART(mm, Max(Batch_Products.Expiry)) AS nvarchar) + N'/'      
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
  WHEN InvoiceDetail.SaleID = 0 AND SUM(STPAYABLE) <> 0 THEN N'F'      
  ELSE N' '      
  END,      
 "Tax Suffered" = ISNULL(Max(InvoiceDetail.TaxSuffered), 0),      
 "Mfr" = Manufacturer.ManufacturerCode, "Description" = Items.Description,      
 "Category" = ItemCategories.Category_Name,      
 "Item Gross Value" = Case Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice)      
 When 0 then      
 N''      
 Else      
 Cast(Sum(#Temp1.SRQty * InvoiceDetail.Quantity * InvoiceDetail.SalePrice) as nvarchar)      
 End,      
 "Amount Before Tax" = Sum (#Temp1.SRQty * InvoiceDetail.Amount - #Temp1.SRQty * (InvoiceDetail.STPayable + InvoiceDetail.CSTPayable)),      
 "Property1" = dbo.GetProperty(InvoiceDetail.Product_Code, 1),      
 "Property2" = dbo.GetProperty(InvoiceDetail.Product_Code, 2),      
 "Property3" = dbo.GetProperty(InvoiceDetail.Product_Code, 3),      
 "Reporting Unit Qty" = (Sum(InvoiceDetail.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),      
 "Conversion Unit Qty" = (Sum(InvoiceDetail.Quantity) * Items.ConversionFactor),      
 "Rounded Reporting Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End)),      
 "Rounded Conversion Unit Qty" = Ceiling(Sum(InvoiceDetail.Quantity) * Items.ConversionFactor),      
 "Mfr Name" = Manufacturer.Manufacturer_Name,      
 "Divison" = Brand.BrandName,      
 "Tax Applicable Value" = Sum(IsNull(#Temp1.SRQty * InvoiceDetail.STPayable, 0) + IsNull(#Temp1.SRQty * InvoiceDetail.CSTPayable, 0)),      
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
    0      
   Else      
   Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) +       
   (SUM(InvoiceDetail.Quantity) * (CASE ItemCategories.Price_Option   
   WHEN 1 THEN Max(InvoiceDetail.MRP) ELSE Max(Items.ECP) END)  
   * dbo.fn_get_TaxOnMRP(Max(InvoiceDetail.TaxCode)) / 100),6)       
   End      
  ELSE      
   Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
   (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
   MAX(InvoiceDetail.DiscountPercentage) / 100), 6))      
   When 0 then      
    0      
   Else      
    Cast(Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
    (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
    MAX(InvoiceDetail.DiscountPercentage) / 100), 6) as Decimal(18,6))      
   End      
  END)   
 else --when TaxOnMRP = 0  
  (case (SELECT TOP 1 Flags FROM InvoiceAbstract WHERE InvoiceID = #Temp1.Invno)      
  WHEN 0 THEN       
   Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
   (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
   MAX(InvoiceDetail.DiscountPercentage) / 100) +       
   (((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice)       
   - (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
   MAX(InvoiceDetail.DiscountPercentage) / 100))       
   * Max(InvoiceDetail.TaxCode) / 100), 6))      
   When 0 then      
    0      
   Else      
    Cast(Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
    (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
    MAX(InvoiceDetail.DiscountPercentage) / 100) +       
    (((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice)       
    - (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
    MAX(InvoiceDetail.DiscountPercentage) / 100))       
    * Max(InvoiceDetail.TaxCode) / 100), 6) as Decimal(18,6))      
   End      
  ELSE      
   Case (Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
   (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
   MAX(InvoiceDetail.DiscountPercentage) / 100), 6))      
   When 0 then      
    0      
   Else      
    Cast(Round((SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice) -       
    (SUM(InvoiceDetail.Quantity) * InvoiceDetail.SalePrice *       
    MAX(InvoiceDetail.DiscountPercentage) / 100), 6) as Decimal(18,6))      
   End      
  END)   
 end/ Sum(InvoiceDetail.Quantity) As Decimal(18,6)),       
 "Net Item Rate" = Cast(Sum(InvoiceDetail.Amount) / Sum(InvoiceDetail.Quantity) As Decimal(18,6)),   
 "Net Value" = Sum(#Temp1.SRQty * Amount),   
 "Tax Suffered Desc" = (select Tax_description from Tax where tax_code = items.TaxSuffered),    
 "Sales Tax Desc" = (select Tax_description from Tax where tax_code = InvoiceDetail.TaxID),  
 "Item MRP" = isnull(Items.MRP,0),   
 --IsNull(InvoiceDetail.SalePriceBeforeExciseAmount, 0),   
 "Excise duty" = IsNull(InvoiceDetail.ExciseDuty, 0),  
 "Serial" = InvoiceDetail.Serial, "Sales Tax Credit" = InvoiceDetail.STCredit, "Sold As" = Items.Soldas
Into  
 #TmpInvDet    
FROM  
 InvoiceAbstract
 Inner Join #Temp1 On InvoiceAbstract.InvoiceID =#Temp1.invno                  
 Inner Join  InvoiceDetail On InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID  
 Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code      
 Left Outer Join UOM On Items.UOM = UOM.UOM
 Left Outer Join  Batch_Products On  InvoiceDetail.Batch_Code = Batch_Products.Batch_Code
 Left Outer Join Manufacturer On   Items.ManufacturerID = Manufacturer.ManufacturerID       
 Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID      
 Inner Join Brand On  Items.BrandID = Brand.BrandID
 Left Outer Join UOM As RUOM On Items.ReportingUOM = RUOM.UOM 
 Left Outer Join ConversionTable On Items.ConversionUnit = ConversionTable.ConversionID
  Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID   
GROUP BY  
 #Temp1.Invid,InvoiceDetail.Product_code, Items.ProductName, InvoiceDetail.Batch_Number,       
 InvoiceDetail.SalePrice, 
-- (ISNULL(InvoiceDetail.TaxCode, 0) + ISNULL(InvoiceDetail.TaxCode2, 0)),
-- CAST(DATEPART(mm, Batch_Products.Expiry) AS nvarchar) + N'/'       
-- + SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS nvarchar), 3, 2),      
-- CAST(DATEPART(mm, Batch_Products.PKD) AS nvarchar) + N'/'      
-- + SubString(CAST(DATEPART(yy, Batch_Products.PKD) AS nvarchar), 3, 2),      
 InvoiceDetail.SaleID, ItemCategories.Price_Option,     
 Manufacturer.ManufacturerCode, Items.Description, ItemCategories.Category_Name,      
 Items.ReportingUnit, Items.ConversionFactor, Manufacturer.Manufacturer_Name,      
 Brand.BrandName, RUOM.Description, ConversionTable.ConversionID,       
 ConversionTable.ConversionUnit, InvoiceDetail.TaxID, InvoiceAbstract.TaxOnMRP,  
 Items.TaxSuffered, Items.Sale_Tax, Items.MRP, #Temp1.Invno,UOM.Description,  
 InvoiceDetail.ExciseDuty,InvoiceDetail.STCredit, Items.Soldas,
 InvoiceDetail.Serial
Order By  
 #Temp1.Invid,InvoiceDetail.Product_Code, InvoiceDetail.SalePrice Desc   
  
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
     Update #TmpInvDet Set [Free] =[Free]+ @FQty Where [id1] = @IDS1  
    Else  
     Update #TmpInvDet Set  [Quantity] = Cast(0 As Decimal(18, 6)), [Free] = @FQty Where [id1] = @IDS  
    Set @I1 = @I1 + 1  
   End   
  Select @I1 = 0, @IDS1 = 0  
  Set @I = @I + 1  
 End  
   
 Delete From #TmpInvDet Where [Sale Price] = N'Free' And [Free] = 0  
  
 Update #TmpInvDet Set [Sale Price] = Cast(0 As Decimal(18,6)), [Amount] = Cast(0 As Decimal(18,6)), [Item Gross Value] = Cast(0 As Decimal(18,6))  
 Where [Sale Price] = N'Free'  
  
 Select * from #TmpInvDet Order by Serial 
  
 Drop Table #TmpInvDet    
 Drop Table #Temp1  
  

