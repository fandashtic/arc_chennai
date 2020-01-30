CREATE procedure [dbo].[spr_list_Closing_Stock_Bunge]          
(           
@Given_Date DateTime,           
@UOM nVarchar(256)          
)          
AS          
Set dateformat dmy    
Declare @Operating_Period as DateTime        
        
Select @Given_Date = dbo.StripDatefromTime(@Given_Date)         
Select @Operating_Period = dbo.StripDatefromTime(dbo.Fn_GetOperartingDate(GETDATE()))        
        
If @UOM = N'Sales UOM'          
  Begin        
    If @Operating_Period <= @Given_Date         
      Select Batch_Products.Product_Code, "Item Code" = Batch_Products.Product_Code,        
        
      "Saleable Stock" = Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0         
        Then Quantity Else 0 End) + IsNull((Select Sum(IsNull(Pending, 0)) From vanstatementdetail        
        Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0), -- ' ' + UOM.Description,         
        
      "Free Stock" = Sum(Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0         
        Then Quantity Else 0 End) + IsNull((Select Sum(IsNull(Pending, 0)) From vanstatementdetail        
        Where Product_Code = Batch_Products.Product_Code And SalePrice = 0),0), -- ' ' + UOM.Description         
        
  "Damaged Stock" = Sum( Case When isnull(Damage,0)<>0 then Quantity Else 0 End),          
        
  "Damaged Value" = sum( Case When isnull(Damage,0)<>0 then Quantity * PurchasePrice Else 0 END) ,        
        
         "Closing Value" = Cast((Case ItemCategories.Price_Option When 0 Then        
         Cast(Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then         
         Cast((Quantity * Items.Purchase_Price) as Decimal(18,6)) Else 0 End)as Decimal(18,6)) +         
         Cast (IsNull((Select Sum(IsNull(Pending * PurchasePrice, 0)) From vanstatementdetail        
         Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0) As Decimal(18, 6))        
        Else Cast(Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then         
        Cast((Quantity * Batch_Products.PurchasePrice) as Decimal(18,6)) Else 0 End)         
        as Decimal(18,6)) End) as Decimal(18,6)) +         
        Cast(IsNull((Select Sum(IsNull(Pending * PurchasePrice, 0)) From vanstatementdetail        
        Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0) As Decimal(18, 6)),        
      "Forum Code" = Items.Alias         
      From Batch_Products, Items, UOM, ItemCategories Where Items.UOM = UOM.UOM        
      and Items.CategoryID = ItemCategories.CategoryID and         
      Batch_Products.Product_Code = Items.Product_Code Group By Batch_Products.Product_Code,         
      ItemCategories.Price_Option,Items.Alias --, UOM.Description        
      Order by Batch_Products.Product_Code        
    Else        
      select OpeningDetails.Product_Code, "Item Code" = OpeningDetails.Product_Code,         
      "Saleable Stock" = Cast(Opening_Quantity - Damage_Opening_Quantity as nVarchar), --+ ' ' + UOM.Description,         
      "Free Stock" = Cast(Free_Opening_Quantity as nVarchar), --+ ' ' + UOM.Description         
   "Damaged Stock" = Damage_opening_Quantity,    
      "Damaged Value" = Damage_OPening_Value,    
   "Closing Value" = Opening_Value,        
      "Forum Code" = Items.Alias         
      from OpeningDetails, Items, UOM Where Opening_Date = DateAdd(day,1,@Given_date)        
      and Items.UOM = UOM.UOM        
      and OpeningDetails.Product_Code = Items.Product_Code        
      Order by OpeningDetails.Product_Code        
  End        
        
Else If @UOM = N'Conversion Factor'         
  Begin         
    If @Operating_Period <= @Given_Date         
Select Batch_Products.Product_Code, "Item Code" = Batch_Products.Product_Code,        
"Saleable Stock" = (CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1         
                        ELSE IsNull(Items.ConversionFactor,0) END) *        
                        (Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0         
 Then Quantity Else 0 End) +        
                    IsNull((Select Sum(IsNull(Pending, 0)) From vanstatementdetail        
        Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0)),  -- + ' ' + Isnull(ConversionTable.ConversionUnit, ''),         
"Free Stock" = (CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE         
                IsNull(Items.ConversionFactor,0) END) * (Sum(Case When IsNull(Free, 0) = 1         
                And IsNull(Damage, 0) = 0 Then Quantity Else 0 End) +         
       IsNull((Select Sum(IsNull(Pending, 0)) From vanstatementdetail        
        Where Product_Code = Batch_Products.Product_Code And SalePrice = 0),0)), --+ ' ' + Isnull(ConversionTable.ConversionUnit, '')         
  "Damaged Stock" = (CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END) * (Sum( Case When isnull(Damage,0)<>0 then Quantity Else 0 End)),          
  "Damaged Value" =  sum( Case When isnull(Damage,0)<>0 then Quantity * PurchasePrice Else 0 END) ,        
        
"Closing Value" = Cast((Case ItemCategories.Price_Option When 0 Then        
                  Cast((Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0         
                  Then (Quantity * Items.Purchase_Price) Else 0 End)) as Decimal(18,6)) +         
                  Cast(IsNull((Select Sum(IsNull(Pending * PurchasePrice, 0)) From vanstatementdetail        
                  Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0) As        
                  Decimal(18, 6))        
Else        
Cast((Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then (Quantity * Batch_Products.PurchasePrice) Else 0 End)) as Decimal(18,6))          
End) as Decimal(18,6)) + Cast(IsNull((Select Sum(IsNull(Pending * PurchasePrice, 0)) From         
vanstatementdetail Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0) As        
Decimal(18, 6)),        
"Forum Code" = Items.Alias         
From Batch_Products, Items, ConversionTable, ItemCategories        
Where Items.ConversionUnit *= ConversionTable.ConversionID        
and Items.CategoryID = ItemCategories.CategoryID        
and Batch_Products.Product_Code = Items.Product_Code        
Group By Batch_Products.Product_Code, Items.ConversionFactor, ItemCategories.Price_Option,Items.Alias --, ConversionTable.ConversionUnit        
Order by Batch_Products.Product_Code        
Else        
select OpeningDetails.Product_Code, "Item Code" = OpeningDetails.Product_Code,         
"Saleable Stock" = Cast(Cast((Opening_Quantity - Damage_Opening_Quantity) * (CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END)as Decimal(18,6)) as nVarchar), --+ ' ' + Isnull(ConversionTable.ConversionUnit, ''),
  
"Free Stock" = Cast(Cast(Free_Opening_Quantity * (CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END)as Decimal(18,6))  as nVarchar), -- + ' ' + Isnull(ConversionTable.ConversionUnit, '')          
"Damaged Stock" =Cast(Cast(Damage_opening_Quantity * (CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END)as Decimal(18,6))  as nVarchar),    
"Damaged Value" = Damage_OPening_Value,    
"Closing Value" = Opening_Value,        
"Forum Code" = Items.Alias         
from OpeningDetails, Items, ConversionTable         
Where Opening_Date = DateAdd(day,1,@Given_date)        
and Items.ConversionUnit *= ConversionTable.ConversionID        
and OpeningDetails.Product_Code = Items.Product_Code        
Order by OpeningDetails.Product_Code        
End        
        
Else If @UOM = N'Reporting UOM'          
Begin        

If @Operating_Period <= @Given_Date         
Select Batch_Products.Product_Code,        
"Item Code" = Batch_Products.Product_Code,        

"Saleable Stock" = Sum((Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0         
Then Quantity Else 0 End) / (Case Isnull(Reportingunit,0) When 0 then 1 else ReportingUnit End))
 + IsNull((Select Sum(IsNull(Pending, 0)) From vanstatementdetail        
Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0) / (Case Isnull(Reportingunit,0) When 0 then 1 else ReportingUnit End),

"Free Stock" = Sum((Case When IsNull(Free, 0) = 1 And IsNull(Damage, 0) = 0 Then Quantity         
               Else 0 End)/ (Case Isnull(Reportingunit,0) When 0 then 1 else ReportingUnit End))
  + IsNull((Select Sum(IsNull(Pending, 0))  From vanstatementdetail        
        Where Product_Code = Batch_Products.Product_Code And SalePrice = 0),0)/ (Case Isnull(Reportingunit,0) When 0 then 1 else ReportingUnit End),         
  "Damaged Stock" = Sum( Case When Isnull(Damage,0)<>0 then Quantity/(Case Isnull(Reportingunit,0) When 0 then 1 else ReportingUnit End) Else 0 End),          
  "Damaged Value" = sum( Case When Isnull(Damage,0)<>0 then Quantity * PurchasePrice Else 0 END) ,        
        
"Closing Value" = Cast((Case ItemCategories.Price_Option        
When 0 Then        
Cast((Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then         
(Quantity * Items.Purchase_Price) Else 0 End)) as Decimal(18,6)) +        
Cast(IsNull((Select Sum(IsNull(Pending * PurchasePrice, 0)) From vanstatementdetail        
        Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0) As         
Decimal(18, 6))        
Else        
Cast((Sum(Case When IsNull(Free, 0) = 0 And IsNull(Damage, 0) = 0 Then         
(Quantity * Batch_Products.PurchasePrice) Else 0 End)) as Decimal(18,6)) +        
Cast(IsNull((Select Sum(IsNull(Pending * PurchasePrice, 0)) From vanstatementdetail        
        Where Product_Code = Batch_Products.Product_Code And SalePrice > 0),0) As         
Decimal(18, 6)) End)as Decimal(18,6)),        
"Forum Code" = Items.Alias         
From Batch_Products, Items, ItemCategories        
Where Items.CategoryID = ItemCategories.CategoryID        
and Batch_Products.Product_Code = Items.Product_Code        
Group By Batch_Products.Product_Code, ItemCategories.Price_Option,Items.Alias,Items.ReportingUnit        
Order by Batch_Products.Product_Code        
Else        
select OpeningDetails.Product_Code, "Item Code" = OpeningDetails.Product_Code,         
"Saleable Stock" = (Opening_Quantity - Damage_Opening_Quantity)/ (Case Isnull(Reportingunit,0) When 0 then 1 else ReportingUnit End),  
"Free Stock" = (Free_Opening_Quantity)/ (Case Isnull(Reportingunit,0) When 0 then 1 else ReportingUnit End),        
"Damaged Stock" = (Damage_opening_Quantity / (Case Isnull(Reportingunit,0) When 0 then 1 else ReportingUnit End)),    
"Damaged Value" = Damage_OPening_Value,    
"Closing Value" = Opening_Value,        
"Forum Code" = Items.Alias         
from OpeningDetails, Items         
Where Opening_Date = DateAdd(day,1,@Given_date)        
and OpeningDetails.Product_Code = Items.Product_Code        
Order by OpeningDetails.Product_Code        
End
