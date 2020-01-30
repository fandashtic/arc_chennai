CREATE PROCEDURE Spr_FreeSalesListing_detail_muom_pidilite( @PRODUCTCODE varchar(15),
													@FROMDATE DATETIME, 
													@TODATE DATETIME,
													@UOM VarChar(100))    
AS  
BEGIN  
  
Select Invoiceabstract.InvoiceID, Invoiceabstract.InvoiceID,
Invoiceabstract.DocReference as "Doc.Reference", 
Invoiceabstract.InvoiceDate,  
case Invoiceabstract.Invoicetype
when 2 then	
	isnull((select customername from cash_customer where customerid = invoiceabstract.customerid),'Retailer')
else
	(select Company_Name from customer where customerid = invoiceabstract.customerid)
end as "Customer Name",   
case InvoiceAbstract.InvoiceType   
when 4 then 0 -  Case @UOM When 'Sales UOM' Then Invoicedetail.Quantity 
				         When 'UOM1' Then Invoicedetail.Quantity / (Case IsNull(UOM1_Conversion, 1) When 0 Then 1 Else IsNull(UOM1_Conversion, 1) End)
						 When 'UOM2' Then Invoicedetail.Quantity / (Case IsNull(UOM2_Conversion, 1) When 0 Then 1 Else IsNull(UOM2_Conversion, 1) End) End

--Invoicedetail.Quantity   
else  
              Case @UOM When 'Sales UOM' Then Invoicedetail.Quantity 
				         When 'UOM1' Then Invoicedetail.Quantity / (Case IsNull(UOM1_Conversion, 1) When 0 Then 1 Else IsNull(UOM1_Conversion, 1) End)
						 When 'UOM2' Then Invoicedetail.Quantity / (Case IsNull(UOM2_Conversion, 1) When 0 Then 1 Else IsNull(UOM2_Conversion, 1) End) End

--Invoicedetail.Quantity 
end  as "Quantity",
"Reporting UOM" = (case InvoiceAbstract.InvoiceType   
when 4 then 0 -  Invoicedetail.Quantity Else Invoicedetail.Quantity End)
 / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End,  
"Conversion Factor" = (case InvoiceAbstract.InvoiceType   
when 4 then 0 -  Invoicedetail.Quantity Else Invoicedetail.Quantity End) * IsNull(ConversionFactor, 0)
From Invoicedetail,Invoiceabstract, Items
Where Invoicedetail.InvoiceID = Invoiceabstract.InvoiceID   
And Invoicedetail.Saleprice = 0 
And (status & 128) = 0 
And Invoicedetail.product_code = Items.Product_Code
And Invoicedetail.product_code = @PRODUCTCODE  
And InvoiceAbstract.invoicedate BETWEEN @FROMDATE AND @TODATE  
 
END  
  
  


