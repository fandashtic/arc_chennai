CREATE Procedure spr_Sales(@FromDate DateTime, @ToDate DateTime)    
AS    
Select "CustomerCode" = IsNull((Select Top 1 IsNull(DL21, N'') From Setup), N''),   
"CustomerCode" = IsNull((Select Top 1 IsNull(DL21, N'') From Setup), N''),     
"CACODE" = IsNull((Select Top 1 IsNull(DL20, N'') From Setup), N''),     
"ItemCode" = ic.Category_Name, "QTYCASES" = Sum(ids.Quantity),     
"Gross Sales" =  Sum(ids.Quantity*ids.SalePrice),"Discount" = Sum(ids.DiscountValue),     
"Invoice Date" = dbo.stripdatefromtime(ia.InvoiceDate), "Price List Code" = 0 From     
Invoiceabstract ia, InvoiceDetail ids, ItemCategories ic, Items Where    
ia.InvoiceID = ids.InvoiceID And ids.Product_Code = Items.Product_Code And    
Items.CategoryID = ic.CategoryID And ia.InvoiceType In (1, 3) And     
IsNull(ia.Status, 0) & 192 = 0 And ia.InvoiceDate Between @FromDate and @ToDate    
Group By ia.CustomerID, ic.Category_Name,dbo.stripdatefromtime(ia.InvoiceDate)    
