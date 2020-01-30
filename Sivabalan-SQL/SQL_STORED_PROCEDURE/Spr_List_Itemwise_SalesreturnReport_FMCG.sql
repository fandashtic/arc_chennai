Create Procedure Spr_List_Itemwise_SalesreturnReport_FMCG(@FromDate datetime,@ToDate datetime)  
As  
Select Items.ProductName,  
"Item Name" = Items.ProductName,  
"Damaged Qty"=  
Sum(case When InvoiceType = 6 Then InvoiceDetail.Quantity Else 0 End),  
"Damaged Value"=  
Sum(case When InvoiceType = 6 Then ISnull((InvoiceDetail.Quantity * InvoiceDetail.SalePrice),0) Else 0 End),  
"Rejected Qty"=  
Sum(case When InvoiceType = 5 Then InvoiceDetail.Quantity Else 0 End),  
"Rejected Value"=  
Sum(case When  InvoiceType = 5 Then ISnull((InvoiceDetail.Quantity * InvoiceDetail.SalePrice),0) Else 0 End)  
From Items,InvoiceDetail,InvoiceAbstract    
Where InvoiceDetail.Product_Code = Items.Product_Code    
And InvoiceDetail.InvoiceID=InvoiceAbstract.InvoiceID    
And InvoiceAbstract.InvoiceType In (4,5,6)    
And Invoicedate Between @FromDate And @Todate    
And Status & 128 = 0    
Group By Items.ProductName    


