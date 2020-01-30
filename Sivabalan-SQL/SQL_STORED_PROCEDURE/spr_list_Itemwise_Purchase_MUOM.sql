CREATE PROCEDURE spr_list_Itemwise_Purchase_MUOM(@FROMDATE DATETIME,
						   @TODATE DATETIME, @UOMDesc as nvarchar(50))
AS
SELECT PODetail.Product_Code, PODetail.Product_Code, Items.ProductName,
"Total Purchase Order" = 
   			Case When @UOMdesc = 'UOM1' then dbo.sp_Get_ReportingQty(SUM(PODetail.Quantity), Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)    
      		When @UOMdesc = 'UOM2' then dbo.sp_Get_ReportingQty(SUM(PODetail.Quantity), Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)    
   			Else SUM(PODetail.Quantity)
     		End,
"Total Pending Order" =   
   			Case When @UOMdesc = 'UOM1' then dbo.sp_Get_ReportingQty(SUM(PODetail.Pending), Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)    
      		When @UOMdesc = 'UOM2' then dbo.sp_Get_ReportingQty(SUM(PODetail.Pending), Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)    
   			Else SUM(PODetail.Pending)
     		End
FROM POAbstract, PODetail, Items
WHERE POAbstract.PODate BETWEEN @FROMDATE AND @TODATE
AND POAbstract.PONumber = PODetail.PONumber
AND PODetail.Product_Code = Items.Product_Code
AND IsNull(POAbstract.Status,0) & 192 = 0
GROUP BY PODetail.Product_Code, Items.ProductName,Items.UOM1_Conversion,Items.UOM2_Conversion
ORDER BY PODetail.Product_Code



