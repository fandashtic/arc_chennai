CREATE PROCEDURE spr_list_items_by_salesman_MUOM(@SALESMANID INT,
					    @FromInvNo nvarchar(50),
					    @ToInvNo nvarchar(50), @UOMDesc nvarchar(30))
AS
SELECT   InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code, 
	"Item Name" = Items.ProductName, "Mfr" = IsNull(Manufacturer.Manufacturer_Name, N''),
	"Batch" = Batch_Number, 
--"Sale Price" = SalePrice, 
"Sale Price" = Cast((      
					Case When @UOMdesc = N'UOM1' then SalePrice * (Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)        
          			When @UOMdesc = N'UOM2' then SalePrice * (Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)        
        			Else SalePrice        
       				End) as decimal(18,6)),
--"Quantity" = sum(Quantity), 
"Quantity" = Cast((      
       Case When @UOMdesc = N'UOM1' then dbo.sp_Get_ReportingQty(Sum(Quantity), Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)        
          	When @UOMdesc = N'UOM2' then dbo.sp_Get_ReportingQty(Sum(Quantity), Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)        
        	Else dbo.sp_Get_ReportingQty(Sum(Quantity),1)        
      		End) as nvarchar)  
  + N' ' + Cast((      
       	Case When @UOMdesc = N'UOM1' then (SELECT Description FROM UOM WHERE UOM = Items.UOM1)        
         	When @UOMdesc = N'UOM2' then (SELECT Description FROM UOM WHERE UOM = Items.UOM2)        
       		Else (SELECT Description FROM UOM WHERE UOM = Items.UOM)        
      		End) as nvarchar),
"Amount"=Sum(Amount) 
FROM InvoiceAbstract, InvoiceDetail, Items, Manufacturer
WHERE InvoiceAbstract.InvoiceType in (1, 3) AND
(InvoiceAbstract.Status & 128) = 0 AND
InvoiceAbstract.DocumentID BETWEEN dbo.GetTrueVal(@FromInvNo) AND dbo.GetTrueVal(@ToInvNo) AND
InvoiceAbstract.SalesmanID = @SALESMANID AND
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND
InvoiceDetail.Product_Code = Items.Product_Code And
Items.ManufacturerID = Manufacturer.ManufacturerID
GROUP BY InvoiceDetail.Product_Code, Items.ProductName, Batch_Number, SalePrice,
Manufacturer.Manufacturer_Name,
Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2,Items.UOM
Order By IsNull(Manufacturer.Manufacturer_Name, N'')


