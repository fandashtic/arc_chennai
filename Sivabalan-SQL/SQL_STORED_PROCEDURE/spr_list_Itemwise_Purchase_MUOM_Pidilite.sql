Create PROCEDURE spr_list_Itemwise_Purchase_MUOM_Pidilite(@FROMDATE DATETIME,      
         @TODATE DATETIME, @UOMDesc as nvarchar(50))      
AS      
SELECT PODetail.Product_Code, PODetail.Product_Code, Items.ProductName,      
"Total Purchase Order" =       
      Case  When @UOMdesc = 'UOM1' then SUM(PODetail.Quantity)/ Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End          
         When @UOMdesc = 'UOM2' then SUM(PODetail.Quantity)/ Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End          
         when @UOMdesc = 'Conversion Factor' then Sum(PODetail.Quantity) *(Case When IsNull(Items.ConversionFactor, 0) = 0 Then 1 Else Items.ConversionFactor End)      
         When @UOMdesc = 'Reporting Uom' Then Sum(PODetail.Quantity)/(Case When IsNull(Items.ReportingUnit, 0) = 0 Then 1 Else Items.ReportingUnit End)    
         Else SUM(PODetail.Quantity)      
       End,      
"Total Pending Order" =         
      Case  When @UOMdesc = 'UOM1' then SUM(PODetail.Pending)/ (Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)          
          When @UOMdesc = 'UOM2' then SUM(PODetail.Pending)/ (Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)          
          when @UOMdesc = 'Conversion Factor' then Sum(PODetail.Pending) *(Case When IsNull(Items.ConversionFactor, 0) = 0 Then 1 Else Items.ConversionFactor End)      
         When @UOMdesc = 'Reporting Uom' Then  Sum(PODetail.Pending)/(Case When IsNull(Items.ReportingUnit, 0) = 0 Then 1 Else Items.ReportingUnit End)            
         Else SUM(PODetail.Pending)      
       End      
FROM POAbstract, PODetail, Items      
WHERE POAbstract.PODate BETWEEN @FROMDATE AND @TODATE      
AND POAbstract.PONumber = PODetail.PONumber      
AND PODetail.Product_Code = Items.Product_Code      
AND IsNull(POAbstract.Status,0) & 192 = 0      
GROUP BY PODetail.Product_Code, Items.ProductName,Items.UOM1_Conversion,Items.UOM2_Conversion,ITems.ReportingUnit,Items.ConversionFactor      
ORDER BY PODetail.Product_Code      


