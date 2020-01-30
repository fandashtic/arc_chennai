CREATE PROCEDURE spr_list_items_by_salesman(@SALESMANID INT,
					    @FromInvNo nvarchar(50),
					    @ToInvNo nvarchar(50))
AS
SELECT  InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code, 
"Item Name" = Items.ProductName, "Mfr" = IsNull(Manufacturer.Manufacturer_Name, N''),
"Batch" = Batch_Number, "Sale Price" = SalePrice, 
"Quantity" = sum(Case InvoiceAbstract.InvoiceType When 4 then 0-Quantity Else Quantity End), 
"Amount"=Sum(Case InvoiceAbstract.InvoiceType When 4 then 0-Amount Else Amount End) 
FROM InvoiceAbstract, InvoiceDetail, Items, Manufacturer
WHERE InvoiceAbstract.InvoiceType in (1, 3, 4) AND
(InvoiceAbstract.Status & 128) = 0 AND
InvoiceAbstract.DocumentID BETWEEN dbo.GetTrueVal(@FromInvNo) AND dbo.GetTrueVal(@ToInvNo) AND
InvoiceAbstract.SalesmanID = @SALESMANID AND
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND
InvoiceDetail.Product_Code = Items.Product_Code And
Items.ManufacturerID = Manufacturer.ManufacturerID
GROUP BY InvoiceDetail.Product_Code, Items.ProductName, Batch_Number, SalePrice,
Manufacturer.Manufacturer_Name
Order By IsNull(Manufacturer.Manufacturer_Name, N'')

