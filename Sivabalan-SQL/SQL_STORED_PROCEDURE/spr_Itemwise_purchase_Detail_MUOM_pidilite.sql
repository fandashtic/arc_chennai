CREATE Procedure spr_Itemwise_purchase_Detail_MUOM_pidilite (@Product_Code nvarchar(15), @FromDate datetime,         
 @ToDate Datetime, @UOMDesc nvarchar(30))            
as            
select             
 "Date"= cast(DATEPART(d, BillAbstract.BillDate)  as nvarchar) +  '/' +             
  cast(DATEPART(m, BillAbstract.BillDate)  as nvarchar) + '/'  +            
  cast(DATEPART(yy, BillAbstract.BillDate) as nvarchar),            
 "Purchase Value" = sum(BillDetail.amount + BillDetail.TaxAmount + BillAbstract.AdjustmentAmount)  ,           
 "Total Qty" = Cast((                
          Case When @UOMdesc = 'UOM1' then Sum(Quantity)/(Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)                  
			   When @UOMdesc = 'UOM2' then Sum(Quantity)/(Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)                  
			   when @UOMdesc = 'Conversion Factor' then Sum(Quantity) *IsNull(Items.ConversionFactor, 0)
			   When @UOMdesc = 'Reporting Uom' Then  Sum(Quantity)/(Case When IsNull(Items.ReportingUnit, 0) = 0 Then 1 Else Items.ReportingUnit End)                  
            Else Sum(Quantity)      
          End) as nvarchar)              
     + ' ' + Cast((                
          Case  When @UOMdesc = 'UOM1' then (SELECT Description FROM UOM WHERE UOM = Items.UOM1)                  
                When @UOMdesc = 'UOM2' then (SELECT Description FROM UOM WHERE UOM = Items.UOM2)                  
                when @UOMdesc = 'Conversion Factor' then (SELECT ConversionUnit FROM ConversionTable WHERE ConversionId = Items.ConversionUnit)      
                When @UOMdesc = 'Reporting Uom' Then (SELECT Description FROM UOM WHERE UOM = Items.ReportingUom)      
             Else (SELECT Description FROM UOM WHERE UOM = Items.UOM)                  
          End) as nvarchar),      
"Reporting UOM" = Sum(Quantity)/(Case When IsNull(Items.ReportingUnit, 0) = 0 Then 1 Else Items.ReportingUnit End),    
--Sum(Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End),        
"Conversion Factor" = Sum(Quantity *  IsNull(Items.ConversionFactor, 0))      
From              
 BillAbstract, BillDetail, Items            
Where            
 BillDetail.BillId = BillAbstract.BillId            
 AND Billabstract.BillDate between @FromDate and @ToDate             
 AND (BillAbstract.Status & 128) = 0             
 AND BillDetail.Product_Code LIKE @Product_Code             
And BillDetail.Product_Code = Items.Product_Code      
Group by cast(DATEPART(d, BillAbstract.BillDate)  as nvarchar) +  '/' +             
 cast(DATEPART(m, BillAbstract.BillDate)  as nvarchar) + '/'  +            
 cast(DATEPART(yy, BillAbstract.BillDate) as nvarchar),BillDetail.amount,BillDetail.Taxamount,Billabstract.AdjustmentAmount,      
Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2,Items.UOM,      
Items.ConversionFactor,Items.ConversionUnit,Items.ReportingUOM,Items.ReportingUnit,BillDetail.Product_Code        
      
      
      
    
    
  


