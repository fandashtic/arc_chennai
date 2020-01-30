Create Procedure [dbo].[spr_ser_list_Sales_VAT_Report]   
(       
@From_Date DateTime,       
@To_Date DateTime      
 )      
AS      
      
Declare @Inv_Pre nvarchar(50)    
Declare @STO_Pre nvarchar(50)    
Declare @Ser_Pre nvarchar(50)    
Declare @AlterSQL nvarchar(4000)    
Declare @UpdateSQL nvarchar(4000)    
Declare @SelectSQL nvarchar(4000)    
Declare @Field_Str nvarchar(4000)   
Declare @Field_Str1 nvarchar(4000)     
Declare @Field_Str2 nvarchar(4000)   
Declare @Field_Str3 nvarchar(4000)   
Declare @Field_Str4 nvarchar(4000)   
Declare @Field_Str5 nvarchar(4000)   
Declare @PerLevel nvarchar(255)    
Declare @SalesVal Decimal(18,6)    
Declare @TaxPerc Decimal(18,6)    
Declare @TaxVal Decimal(18,6)    
Declare @TaxPer Decimal(18,6)    
Declare @LST_Incr Integer 
Declare @DocType Integer    
Declare @DocID Integer    
   
    
-------------------------- Prefix for Invoice and STO  and Service Invoice ------------    
Select @Inv_Pre = Prefix From VoucherPrefix Where TranID = N'INVOICE'    
Select @STO_Pre = Prefix From VoucherPrefix Where TranID = N'STOCK TRANSFER OUT'    
Select @Ser_Pre = Prefix From VoucherPrefix Where TranID = N'SERVICEINVOICE'    
    
--Temp Table #SalesVAT used to store DocumentID, Date, NetValue etc From Invoices, STO,Service Invoice     

Create Table #SalesVAT (DocType nvarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS, 
TempDocID Integer, DocuDate DateTime, 
DocuID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
DocRef nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
Cust_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, NetValue Decimal(18,6))    
    
Insert Into #SalesVAT (DocType,TempDocID,DocuDate,DocuID,DocRef,Cust_Name,NetValue)
    
Select N'I', DocumentID, InvoiceAbstract.InvoiceDate, @Inv_Pre + Cast(DocumentID as nvarchar), DocReference, Customer.Company_Name, InvoiceAbstract.NetValue    
From InvoiceAbstract, Customer    
Where InvoiceAbstract.CustomerID = Customer.CustomerID And    
InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date    
And InvoiceType in (1,3)    
And (IsNull(Status, 0) & 192) = 0    
Union    
Select N'S', DocumentID, StockTransferOutAbstract.DocumentDate, @STO_Pre + Cast(DocumentID as nvarchar), N'',  WareHouse_Name,     
StockTransferOutAbstract.NetValue    
From  StockTransferOutAbstract, WareHouse    
Where StockTransferOutAbstract.WareHouseID = WareHouse.WareHouseID And    
(IsNull(Status, 0) & 192) = 0 And    
StockTransferOutAbstract.DocumentDate Between @From_Date and @To_Date    
Union    
Select N'R', DocumentID, InvoiceAbstract.InvoiceDate, @Inv_Pre + Cast(DocumentID as nvarchar), DocReference, Customer.Company_Name,InvoiceAbstract.NetValue    
From InvoiceAbstract
Left Outer Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID 
Where InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date    
And InvoiceType = 2    
And (IsNull(Status, 0) & 192) = 0    
Union    
Select N'R', DocumentID, InvoiceAbstract.InvoiceDate, @Inv_Pre + Cast(DocumentID as nvarchar), DocReference, Customer.Company_Name, 0 - InvoiceAbstract.NetValue    
From InvoiceAbstract
Left Outer Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
Where InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date    
And InvoiceType in (5, 6)    
And (IsNull(Status, 0) & 192) = 0    
Union
Select N'I', DocumentID, InvoiceAbstract.InvoiceDate, @Inv_Pre + Cast(DocumentID as nvarchar), DocReference, Customer.Company_Name, 0 - InvoiceAbstract.NetValue    
From InvoiceAbstract, Customer    
Where InvoiceAbstract.CustomerID = Customer.CustomerID And    
InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date    
And InvoiceType In (4)    
And (IsNull(Status, 0) & 192) = 0    
Union
Select N'SI', DocumentID,SerAbs.ServiceInvoiceDate,@Ser_Pre + Cast(DocumentID as nvarchar), 
DocReference, Cust.Company_Name,SerAbs.NetValue    
From ServiceInvoiceAbstract SerAbs
Left Outer Join Customer Cust  On SerAbs.CustomerID = Cust.CustomerID     
Where SerAbs.ServiceInvoiceDate Between @From_Date and @To_Date    
And IsNull(ServiceInvoiceType,0) = 1    
And IsNull(Status, 0) & 192 = 0 

------------------Cursor used to stored both the CST and LST Percentage -------------------    
Declare LST_Tax Cursor For    
Select Distinct Cast(Percentage as nvarchar) From Tax    
Where Percentage <> 0 And Active = 1  
Union    
Select Distinct Cast(CST_Percentage as nvarchar) From Tax      
Where CST_Percentage <> 0  And Active = 1    
    
Declare CST_Tax Cursor For    

Select Distinct Cast(Percentage as nvarchar) From Tax      
Where Percentage <> 0 And Active = 1    
Union    
Select Distinct Cast(CST_Percentage as nvarchar) From Tax    
Where CST_Percentage <> 0  And Active = 1  
    
------------------------ Adding CST as Column for Outstation Invoices------------------------    
Set @Field_Str = N''    
Open CST_Tax     
Fetch From CST_Tax Into @TaxPerc    
Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Outstation (Exempt) Sales Value' + N'] Decimal(18,6) null'                   
Set @Field_Str = N'[Outstation (Exempt) Sales Value], '    
Exec sp_Executesql @AlterSQL                  

Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Outstation (0%) Sales Value' + N'] Decimal(18,6) null'                   
Set @Field_Str = @Field_Str + N'[Outstation (0%) Sales Value], '    
Exec sp_Executesql @AlterSQL     

While @@FETCH_STATUS = 0                  
Begin    

Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Outstation (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value' + N'] Decimal(18,6) null'          
Set @Field_Str = @Field_Str + N'[Outstation (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value], '    
Exec sp_Executesql @AlterSQL                  

Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Outstation (' + Cast(@TaxPerc as nvarchar) + N'%) VAT' + '] Decimal(18,6) null'                   
Set @Field_Str = @Field_Str + N'[Outstation (' + Cast(@TaxPerc as nvarchar) + N'%) VAT], '    
Exec sp_Executesql @AlterSQL                   
    
Fetch Next From CST_Tax Into @TaxPerc       
END    
    
---------------------------Adding LST as Column for STO-------------------------------------    
Set @Field_Str1 = N''        
Open LST_Tax     
Fetch From LST_Tax Into @TaxPerc    
Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'STO (Exempt) Sales Value' + N'] Decimal(18,6) null'                   
Set @Field_Str1 = @Field_Str1 + N'[STO (Exempt) Sales Value], '    
Exec sp_Executesql @AlterSQL                  

Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'STO (0%) Sales Value' + N'] Decimal(18,6) null'                   
Set @Field_Str1 = @Field_Str1 + N'[STO (0%) Sales Value], '    
Exec sp_Executesql @AlterSQL                             
    
While @@FETCH_STATUS = 0                  
Begin    
Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'STO (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value' + N'] Decimal(18,6) null'                   
Set @Field_Str1 = @Field_Str1 + N'[STO (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value], '    
Exec sp_Executesql @AlterSQL                  

Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'STO (' + Cast(@TaxPerc as nvarchar) + N'%) VAT' + N'] Decimal(18,6) null'                   
Set @Field_Str1 = @Field_Str1 + N'[STO (' + Cast(@TaxPerc as nvarchar) + N'%) VAT], '    
Exec sp_Executesql @AlterSQL                    
Fetch Next From LST_Tax Into @TaxPerc       
End    
Close LST_Tax    
    
---------------------------Adding LST as Column for Invoices---------------------------------    
Set @Field_Str2 = N''          
Open LST_Tax     
Fetch From LST_Tax Into @TaxPerc    
Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Invoice (Exempt) Sales Value' + N'] Decimal(18,6) null'                   
Set @Field_Str2 = @Field_Str2 + N'[Invoice (Exempt) Sales Value], '    
Exec sp_Executesql @AlterSQL                  

Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Invoice (0%) Sales Value' + N'] Decimal(18,6) null'                   
Set @Field_Str2 = @Field_Str2 + N'[Invoice (0%) Sales Value], '     
Exec sp_Executesql @AlterSQL                             
    
While @@FETCH_STATUS = 0                  
Begin    

Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Invoice (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value' + N'] Decimal(18,6) null'                   
Set @Field_Str2 = @Field_Str2 + N'[Invoice (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value], '    
Exec sp_Executesql @AlterSQL                  

Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Invoice (' + Cast(@TaxPerc as nvarchar) + N'%) VAT' + N'] Decimal(18,6) null'                   
Set @Field_Str2 = @Field_Str2 + N'[Invoice (' + Cast(@TaxPerc as nvarchar) + N'%) VAT], '    
Exec sp_Executesql @AlterSQL                
             
Fetch Next From LST_Tax Into @TaxPerc       
End    
Close LST_Tax  
    

------------------------Adding LST as Column for Retail Invoices----------------------------    
Set @Field_Str3 = N''              
Open LST_Tax     
Fetch From LST_Tax Into @TaxPerc    
Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Retail (Exempt) Sales Value' + N'] Decimal(18,6) null'                   
Set @Field_Str3 = @Field_Str3 + N'[Retail (Exempt) Sales Value], '     
Exec sp_Executesql @AlterSQL                  

Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Retail (0%) Sales Value' + N'] Decimal(18,6) null'                   
Set @Field_Str3 = @Field_Str3 + N'[Retail (0%) Sales Value], '     
Exec sp_Executesql @AlterSQL   
    
While @@FETCH_STATUS = 0                  
Begin    
Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Retail (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value' + N'] Decimal(18,6) null'                 
Set @Field_Str3 = @Field_Str3 + N'[Retail (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value], '     
Exec sp_Executesql @AlterSQL                  

Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Retail (' + Cast(@TaxPerc as nvarchar) + N'%) VAT' + N'] Decimal(18,6) null'                   
Set @Field_Str3 = @Field_Str3 + N'[Retail (' + Cast(@TaxPerc as nvarchar) + N'%) VAT],'    
Exec sp_Executesql @AlterSQL                
           
Fetch Next From LST_Tax Into @TaxPerc       
End    
Close LST_Tax    

------------------------Adding LST as Column for Service Invoices----------------------------    
Set @Field_Str4 = N''              
Open LST_Tax     
Fetch From LST_Tax Into @TaxPerc    

Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Service Invoice (Exempt) Sales Value' + N'] Decimal(18,6) null'                   
Set @Field_Str4 = @Field_Str4 + N'[Service Invoice (Exempt) Sales Value],'     
Exec sp_Executesql @AlterSQL                  

Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Service Invoice (0%) Sales Value' + N'] Decimal(18,6) null'                   
Set @Field_Str4 = @Field_Str4 + N'[Service Invoice (0%) Sales Value],'     
Exec sp_Executesql @AlterSQL           
    		
While @@FETCH_STATUS = 0                  
Begin    
Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Service Invoice (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value' + N'] Decimal(18,6) null'                 
Set @Field_Str4 = @Field_Str4 + N'[Service Invoice (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value], '     
Exec sp_Executesql @AlterSQL                  

Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Service Invoice (' + Cast(@TaxPerc as nvarchar) + N'%) VAT' + N'] Decimal(18,6) null'                   
Set @Field_Str4 = @Field_Str4 + N'[Service Invoice (' + Cast(@TaxPerc as nvarchar) + N'%) VAT],'    
Exec sp_Executesql @AlterSQL                
  
Fetch Next From LST_Tax Into @TaxPerc
End    
Close LST_Tax    


------------------------Adding CST as Column for Service Invoices----------------------------    
Set @Field_Str5 = N''              
Fetch From CST_Tax Into @TaxPerc    
Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'OutStation Service Invoice (Exempt) Sales Value' + N'] Decimal(18,6) null'                   
Set @Field_Str5 = @Field_Str5 + N'[OutStation Service Invoice (Exempt) Sales Value],'     
Exec sp_Executesql @AlterSQL                  

Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'OutStation Service Invoice (0%) Sales Value' + N'] Decimal(18,6) null'                   
Set @Field_Str5 = @Field_Str5 + N'[OutStation Service Invoice (0%) Sales Value],'     
Exec sp_Executesql @AlterSQL           
    		
While @@FETCH_STATUS = 0                  
Begin    

Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'OutStation Service Invoice (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value' + N'] Decimal(18,6) null'                 
Set @Field_Str5 = @Field_Str5 + N'[OutStation Service Invoice (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value], '     
Exec sp_Executesql @AlterSQL                  

Set @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'OutStation Service Invoice (' + Cast(@TaxPerc as nvarchar) + N'%) VAT' + N'] Decimal(18,6) null'                   
Set @Field_Str5 = @Field_Str5 + N'[OutStation Service Invoice (' + Cast(@TaxPerc as nvarchar) + N'%) VAT],'    
Exec sp_Executesql @AlterSQL                
         
Fetch Next From CST_Tax Into @TaxPerc
End    
  
-- Fields Concadinated for Select Statement    

Set @Field_Str = Substring(@Field_Str, 1, Len(@Field_Str) - 1)     
IF len(@Field_Str)>0
Set @Field_Str = N','+@Field_Str
Set @Field_Str1 = Substring(@Field_Str1, 1, Len(@Field_Str1) - 1)     

IF Len(@Field_Str1)>0
Set @Field_Str1 = N','+@Field_Str1

Set @Field_Str2= Substring(@Field_Str2, 1, Len(@Field_Str2) - 1)     
IF Len(@Field_Str2)>0
Set @Field_Str2= N','+@Field_Str2

Set @Field_Str3 = Substring(@Field_Str3, 1, Len(@Field_Str3) - 1)     
IF Len(@Field_Str3)>0
Set @Field_Str3=N','+@Field_Str3
    
Set @Field_Str4 = Substring(@Field_Str4, 1, Len(@Field_Str4) - 1)     
IF Len(@Field_Str4)>0
Set @Field_Str4=N','+@Field_Str4


Set @Field_Str5 = Substring(@Field_Str5, 1, Len(@Field_Str5) - 1)     
IF Len(@Field_Str5)>0
Set @Field_Str5=N','+@Field_Str5


-- Cursor for Storing Sales Value and VAT for Invoices (Outstation Customers), STO, Invoices, Retail Invoices    
    
Declare TaxVal Cursor for    
------------------------ Invoices for Outstation Customers-------------------------------    
Select 1, DocumentID, Sum(Amount) - Sum(CSTPayable), Sum(CSTPayable), InvoiceDetail.TaxCode2,    
Cast((Case When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax = 0 Then N'Exempt'     
When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax <> 0 Then N'0%'     
Else Cast(Cast(InvoiceDetail.TaxCode2 as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)    
From InvoiceAbstract
Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID    
Left Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode2 = Tax.Percentage         
Inner Join Customer On invoiceAbstract.CustomerID = Customer.CustomerID    
Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code        
Where InvoiceType in (1,3)    
And Customer.Locality = 2    
And (IsNull(Status, 0) & 128) = 0    
And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date    
Group By DocumentID, InvoiceDetail.TaxCode2, Items.Sale_Tax  

Union  All  
-------------------------------------------- STO-----------------------------------------     
Select 2, DocumentID, Sum(Amount), Sum(StockTransferOutDetail.TaxAmount), StockTransferOutDetail.TaxSuffered,     
Case     
When StockTransferOutDetail.TaxSuffered = 0 and Items.Sale_Tax <> 0 Then N'0%'    
When StockTransferOutDetail.TaxSuffered = 0 and Items.Sale_Tax = 0 Then N'Exempt'    
Else Cast( Cast(StockTransferOutDetail.TaxSuffered as Decimal(18,6)) as nvarchar) + N'%' End    
From  StockTransferOutDetail, StockTransferOutAbstract, Items    
Where StockTransferOutDetail.DocSerial = StockTransferOutAbstract.DocSerial    
And StockTransferOutDetail.product_Code = Items.Product_Code    
And (IsNull(Status, 0) & 128) = 0    
and StockTransferOutAbstract.DocumentDate Between @From_Date and @To_Date 
Group by StockTransferOutDetail.TaxSuffered, DocumentID, Items.Sale_Tax    

Union  All  
------------------------------------------ Invoices----------------------------------------    
Select 3, DocumentID, Sum(Amount) - Sum(STPayable), Sum(STPayable), InvoiceDetail.TaxCode,    
Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'Exempt'     
When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax <> 0 Then N'0%'    
Else Cast(Cast(InvoiceDetail.TaxCode as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)    
From InvoiceAbstract
Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
Left Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID
Inner Join Customer On invoiceAbstract.CustomerID = Customer.CustomerID
Left Outer Join Items On InvoiceDetail.TaxCode = Tax.Percentage        
Where InvoiceDetail.product_Code = Items.Product_Code    
And InvoiceType in (1,3)    
And Customer.Locality = 1    
And (IsNull(Status, 0) & 128) = 0    
And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date    
Group By DocumentID, InvoiceDetail.TaxCode, Items.Sale_Tax  

Union  All  
------------------------------------- Retail Invoices--------------------------------------    
Select 4, DocumentID, Sum(Amount) - Sum(STPayable), Sum(STPayable), InvoiceDetail.TaxCode,    
Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'Exempt'     
When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax <> 0 Then N'0%'    
Else Cast(Cast(InvoiceDetail.TaxCode as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)    
From InvoiceAbstract
Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
Left Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode = Tax.Percentage    
Left Outer Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID
Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code        
Where InvoiceType in (2)
And (IsNull(Status, 0) & 128) = 0    
And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date    
Group By DocumentID, InvoiceDetail.TaxCode, Items.Sale_Tax  

Union  All  
------------------Sales Return for Retail Invoices-----------------------------------------
Select 7, DocumentID, 0 - (Sum(Amount) - Sum(STPayable)), 0 - Sum(STPayable), InvoiceDetail.TaxCode,    
Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'Exempt'     
When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax <> 0 Then N'0%'    
Else Cast(Cast(InvoiceDetail.TaxCode as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)    
From InvoiceAbstract
Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID    
Left Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode = Tax.Percentage        
Left Outer Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID    
Inner Join Items On  InvoiceDetail.product_Code = Items.Product_Code        
Where InvoiceType in (5, 6)
And (IsNull(Status, 0) & 128) = 0    
And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date    
Group By DocumentID, InvoiceDetail.TaxCode, Items.Sale_Tax  

Union  All  

------------------ Sales Return for invoices (Local Customers) ---------------------------    
Select 5, DocumentID, 0 - (sum(Amount) - sum(STPayable)), 0 - sum(STPayable), InvoiceDetail.TaxCode,    
Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'Exempt'     
When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax <> 0 Then N'0%'     
Else Cast(Cast(InvoiceDetail.TaxCode as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)    
From InvoiceAbstract
Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID    
Left Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode = Tax.Percentage          
Inner Join Customer On invoiceAbstract.CustomerID = Customer.CustomerID    
Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code       
Where InvoiceType in (4)    
And Customer.Locality = 1    
And (IsNull(Status, 0) & 128) = 0    
And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date    
Group By DocumentID, InvoiceDetail.TaxCode, Items.Sale_Tax    

Union  All  
----------------- Sales Return for invoices (Outstation Customers)-------------------------    
Select 6, DocumentID, 0 - (sum(Amount) - sum(CSTPayable)), 0 - sum(CSTPayable), InvoiceDetail.TaxCode2,      
Cast((Case When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax = 0 Then N'Exempt'       
When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax <> 0 Then N'0%'      
Else Cast(Cast(InvoiceDetail.TaxCode2 as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)      
From InvoiceAbstract
Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID      
Left Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode2 = Tax.CST_Percentage              
Inner Join Customer On invoiceAbstract.CustomerID = Customer.CustomerID      
Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code           
Where InvoiceType in (4)      
And Customer.Locality = 2      
And (IsNull(Status, 0) & 128) = 0      
And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
Group By DocumentID, InvoiceDetail.TaxCode2, Items.Sale_Tax        

Union All
-------------------- Service Invoice(For Local Customer)-------------------------    
Select 8,DocumentID, Sum(IsNull(SerDet.NetValue,0)) - Sum(IsNull(SerDet.LSTPayable,0)), 
Sum(IsNull(SerDet.LSTPayable,0)),IsNull(SerDet.SaleTax,0),
Cast((Case When IsNull(SerDet.SaleTax,0) = 0 and Items.Sale_Tax = 0 Then N'Exempt'     
When IsNull(SerDet.SaleTax,0) = 0 and Items.Sale_Tax <> 0 Then N'0%'     
Else Cast(Cast(IsNull(SerDet.SaleTax,0) as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)    
From ServiceInvoiceAbstract SerAbs
Inner Join ServiceInvoiceDetail SerDet On SerAbs.ServiceInvoiceID = SerDet.ServiceInvoiceID 
Inner Join ServiceInvoiceTaxComponents SerTax  On  SerDet.SerialNo = SerTax.SerialNo
Left Outer Join Tax On Tax.Tax_Code = SerTax.TaxCode And SerTax.Tax_Percentage = Tax.Percentage         
Inner Join Customer On SerAbs.CustomerID = Customer.CustomerID    
Inner Join Items On SerDet.Product_Code = Items.Product_Code    
Where 
IsNull(SerAbs.ServiceInvoiceType,0) = 1
And IsNull(Status, 0) & 192 = 0    
And Customer.Locality =  1    
And SerAbs.ServiceInvoiceDate Between @From_Date and @To_Date    
Group By DocumentID, SerDet.SaleTax, Items.Sale_Tax 

Union All  

-------------------- Service Invoice(For OutStation Customers)-------------------------    
Select 9,DocumentID, Sum(IsNull(SerDet.NetValue,0)) - Sum(IsNull(SerDet.CSTPayable,0)), 
Sum(IsNull(SerDet.CSTPayable,0)),IsNull(SerDet.SaleTax,0),
Cast((Case When IsNull(SerDet.SaleTax,0) = 0 and Items.Sale_Tax = 0 Then N'Exempt'     
When IsNull(SerDet.SaleTax,0) = 0 and Items.Sale_Tax <> 0 Then N'0%'     
Else Cast(Cast(IsNull(SerDet.SaleTax,0) as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)    
From ServiceInvoiceAbstract SerAbs
Inner Join ServiceInvoiceDetail SerDet On SerAbs.ServiceInvoiceID = SerDet.ServiceInvoiceID  
Inner Join ServiceInvoiceTaxComponents SerTax On SerDet.SerialNo = SerTax.SerialNo    
Left Outer Join Tax On SerTax.Tax_Percentage = Tax.Percentage   And Tax.Tax_Code =SerTax.TaxCode       
Inner Join Customer On SerAbs.CustomerID = Customer.CustomerID    
Inner Join Items On SerDet.Product_Code = Items.Product_Code    
Where IsNull(SerAbs.ServiceInvoiceType,0) = 1
And (IsNull(Status, 0) & 192) = 0    
And Customer.Locality = 2   
And SerAbs.ServiceInvoiceDate Between @From_Date and @To_Date    
Group By DocumentID, SerDet.SaleTax, Items.Sale_Tax 

------------------- Updating Sales Value and VAT for All Tax levels ------------------------    

Open TaxVal     
Fetch From TaxVal Into @DocType, @DocID, @SalesVal, @TaxVal, @TaxPer, @PerLevel    
    
While @@FETCH_STATUS = 0                  
Begin    
    
IF @DocType = 1 Or @DocType = 6       
Begin      
Set @UpdateSQL = N'Update #SalesVAT Set [Outstation (' + @PerLevel + N') Sales Value] = IsNull([Outstation (' + @PerLevel + N') Sales Value],0) + ' + cast (@SalesVal as nvarchar) + N' Where TempDocID = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''I'''             
Exec sp_Executesql @UpdateSQL                 
If @PerLevel <> N'Exempt' and @PerLevel <> N'0%'       
Begin    
	Set @UpdateSQL = N'Update #SalesVAT Set [Outstation (' + @PerLevel + N') VAT] = IsNull([Outstation (' + @PerLevel + N') VAT],0) + ' + cast (@TaxVal as nvarchar) + N' Where TempDocID = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''I'''              
	Exec sp_Executesql @UpdateSQL                 
End    
End       

Else If @DocType = 2      
Begin     
Set @UpdateSQL = N'Update #SalesVAT Set [STO (' + @PerLevel + N') Sales Value] = IsNull([STO (' + @PerLevel + N') Sales Value],0) + ' + cast (@SalesVal as nvarchar) + N' Where TempDocID  = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''S'''             
Exec sp_Executesql @UpdateSQL                 
If @PerLevel <> N'Exempt' and @PerLevel <> N'0%'       
Begin    
	Set @UpdateSQL = N'Update #SalesVAT Set [STO (' + @PerLevel + N') VAT] = IsNull([STO (' + @PerLevel + N') VAT],0) + ' + cast (@TaxVal as nvarchar) + N' Where TempDocID  = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''S'''             
	Exec sp_Executesql @UpdateSQL                 
End    
End       

Else If @DocType = 3 or @DocType = 5       
Begin      
Set @UpdateSQL = N'Update #SalesVAT Set [Invoice (' + @PerLevel + N') Sales Value] = IsNull([Invoice (' + @PerLevel + N') Sales Value],0) + ' + cast (@SalesVal as nvarchar) + N' Where TempDocID  = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''I'''      
Exec sp_Executesql @UpdateSQL                 
If @PerLevel <> N'Exempt' and @PerLevel <> N'0%'        
Begin    
	Set @UpdateSQL = N'Update #SalesVAT Set [Invoice (' + @PerLevel + N') VAT] = IsNull([Invoice (' + @PerLevel + N') VAT],0) + ' + cast (@TaxVal as nvarchar) + N' Where TempDocID = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''I'''      
	Exec sp_Executesql @UpdateSQL         
End    
End       

Else If @DocType = 4 or @DocType = 7
Begin      
Set @UpdateSQL = N'Update #SalesVAT Set [Retail (' + @PerLevel + N') Sales Value] = IsNull([Retail (' + @PerLevel + N') Sales Value],0) + ' + cast (@SalesVal as nvarchar) + N' Where TempDocID  = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''R'''      
Exec sp_Executesql @UpdateSQL                 
If @PerLevel <> N'Exempt' and @PerLevel <> N'0%'       
Begin    
	Set @UpdateSQL = N'Update #SalesVAT Set [Retail (' + @PerLevel + N') VAT] = IsNull([Retail (' + @PerLevel + N') VAT],0) + ' + cast (@TaxVal as nvarchar) + N' Where TempDocID = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''R'''      
	Exec sp_Executesql @UpdateSQL                 
End    
End       

Else If @DocType = 8 
Begin      
Set @UpdateSQL = N'Update #SalesVAT Set [Service Invoice (' + @PerLevel + N') Sales Value] = IsNull([Service Invoice (' + @PerLevel + N') Sales Value],0) + ' + cast (@SalesVal as nvarchar) + N' Where TempDocID  = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''SI'''        
Exec sp_Executesql @UpdateSQL                 
If @PerLevel <> N'Exempt' and @PerLevel <> N'0%'        
Begin    
	Set @UpdateSQL = N'Update #SalesVAT Set [Service Invoice (' + @PerLevel + N') VAT] = IsNull([Service Invoice (' + @PerLevel + N') VAT],0) + ' + cast (@TaxVal as nvarchar) + N' Where TempDocID = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''SI'''      
	Exec sp_Executesql @UpdateSQL         
End    
End     

Else If @DocType = 9
Begin      
Set @UpdateSQL = N'Update #SalesVAT Set [OutStation Service Invoice (' + @PerLevel + N') Sales Value] = IsNull([OutStation Service Invoice (' + @PerLevel + N') Sales Value],0) + ' + cast (@SalesVal as nvarchar) + N' Where TempDocID  = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''SI'''        
Exec sp_Executesql @UpdateSQL                 
If @PerLevel <> N'Exempt' and @PerLevel <> N'0%'        
Begin    
	Set @UpdateSQL = N'Update #SalesVAT Set [OutStation Service Invoice (' + @PerLevel + N') VAT] = IsNull([OutStation Service Invoice (' + @PerLevel + N') VAT],0) + ' + cast (@TaxVal as nvarchar) + N' Where TempDocID = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''SI'''      
	Exec sp_Executesql @UpdateSQL         
End    
End

Fetch Next From TaxVal Into @DocType, @DocID, @SalesVal, @TaxVal, @TaxPer, @PerLevel    
END    
    
Close CST_Tax    
DeAllocate CST_Tax    
DeAllocate LST_Tax   

Close TaxVal    
DeAllocate TaxVal    

Exec (N'Select DocuDate, ''Document Date'' = DocuDate, ''Document ID '' = DocuID , ''Document Ref'' = DocRef, ''Customer/Branch'' = Cust_Name, NetValue' + @Field_Str + @Field_Str1+@Field_Str2+@Field_Str3+@Field_Str4+@Field_Str5+ ' From  #SalesVAT')    
Drop Table #SalesVAT    

