Create Procedure [dbo].[spr_list_Sales_VAT_Report_Pidilite]     
(         
@From_Date DateTime,         
@To_Date DateTime,  
@CustomerType nVarchar(50)        
)        
AS        
        
Declare @Inv_Pre nvarchar(50)      
Declare @STO_Pre nvarchar(50)      
Declare @LST_Incr Integer      
Declare @TaxPerc Decimal(18,6)      
Declare @AlterSQL nvarchar(4000)      
Declare @UpdateSQL nvarchar(4000)      
Declare @SelectSQL nvarchar(4000)      
Declare @Field_Str nvarchar(4000)     
Declare @Field_Str1 nvarchar(4000)       
Declare @Field_Str2 nvarchar(4000)     
Declare @Field_Str3 nvarchar(4000)     
Declare @DocType Integer      
Declare @DocID Integer      
Declare @SalesVal Decimal(18,6)      
Declare @TaxVal Decimal(18,6)      
Declare @TaxPer Decimal(18,6)      
Declare @PerLevel nvarchar(255)      
      
Create Table #Customer (CustomerID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
Create Table #WareHouse (WareHouseID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
  
IF @CustomerType = N'TIN Customers'   
Begin  
 Insert into #Customer select CustomerID from customer where Len(TIN_Number) > 0   
 Insert into #WareHouse select WareHouseID from WareHouse where Len(TIN_Number) > 0   
End  
Else IF @CustomerType = N'Non TIN Customers'   
Begin  
 Insert into #Customer select CustomerID from customer where Len(TIN_Number) = 0  
 Insert into #WareHouse select WareHouseID from WareHouse where Len(TIN_Number) = 0   
End  
Else  
Begin  
 Insert into #Customer select CustomerID from customer  
 Insert into #WareHouse select WareHouseID from WareHouse  
End  
  
-------------------------- Prefix for Invoice and STO -------------------------------------      
SELECT @Inv_Pre = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'      
SELECT @STO_Pre = Prefix FROM VoucherPrefix WHERE TranID = N'STOCK TRANSFER OUT'      
      
--Temp Table #SalesVAT used to store DocumentID, Date, NetValue etc from Invoices, STO       
Create Table #SalesVAT (DocType nvarchar(5) COLLATE SQL_Latin1_General_CP1_CI_AS, TempDocID Integer, DocuDate DateTime, DocuID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, DocRef nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, Cust_Name nvarchar(
255) COLLATE SQL_Latin1_General_CP1_CI_AS, NetValue Decimal(18,6), [TIN Number] nVarchar(50),[Discount Value] Decimal(18,6),[Credit Note Adjusted Amount] Decimal(18,6),[F11 Adjustment] Decimal(18,6))      
      
Insert into #SalesVAT (DocType, TempDocID, DocuDate ,DocuID , DocRef,  Cust_Name, NetValue, [TIN Number],[Discount Value],[Credit Note Adjusted Amount],[F11 Adjustment])       
Select N'I', DocumentID, InvoiceAbstract.InvoiceDate, @Inv_Pre + Cast(DocumentID as nvarchar), Cast(DocReference As nVarchar), Customer.Company_Name, InvoiceAbstract.NetValue, Customer.TIN_Number,
IsNull(DiscountValue,0)+IsNull(AddlDiscountValue,0)+IsNull(ProductDiscount,0)+IsNull(SchemeDiscountAmount,0),IsNull(AdjustedAmount,0),IsNull(AdjustmentValue,0)                
From InvoiceAbstract, Customer      
Where InvoiceAbstract.CustomerID = Customer.CustomerID And      
Customer.CustomerID In (Select CustomerID From #Customer) And  
InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
And InvoiceType in (1,3)      
And (isnull(Status, 0) & 192) = 0      
Union      
Select N'S', DocumentID, StockTransferOutAbstract.DocumentDate, @STO_Pre + Cast(DocumentID as nvarchar), N'',  WareHouse_Name,       
StockTransferOutAbstract.NetValue, WareHouse.TIN_Number,0,0,0          
From  StockTransferOutAbstract, WareHouse      
Where StockTransferOutAbstract.WareHouseID = WareHouse.WareHouseID And      
WareHouse.WareHouseID In (Select WareHouseID From #WareHouse) And   
(isnull(Status, 0) & 192) = 0 And      
StockTransferOutAbstract.DocumentDate Between @From_Date and @To_Date      
Union      
Select N'R', DocumentID, InvoiceAbstract.InvoiceDate, @Inv_Pre + Cast(DocumentID as nvarchar), DocReference, Customer.Company_Name,InvoiceAbstract.NetValue, Customer.TIN_Number,
IsNull(DiscountValue,0)+IsNull(AddlDiscountValue,0)+IsNull(ProductDiscount,0)+IsNull(SchemeDiscountAmount,0),IsNull(AdjustedAmount,0),IsNull(AdjustmentValue,0)                
From InvoiceAbstract, Customer      
Where InvoiceAbstract.CustomerID = Customer.CustomerID And      
Customer.CustomerID In (Select CustomerID From #Customer) And  
InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
And InvoiceType = 2      
And (isnull(Status, 0) & 192) = 0      
Union      
Select N'R', DocumentID, InvoiceAbstract.InvoiceDate, @Inv_Pre + Cast(DocumentID as nvarchar), DocReference, Customer.Company_Name, 0 - InvoiceAbstract.NetValue, Customer.TIN_Number,
IsNull(DiscountValue,0)+IsNull(AddlDiscountValue,0)+IsNull(ProductDiscount,0)+IsNull(SchemeDiscountAmount,0),IsNull(AdjustedAmount,0),IsNull(AdjustmentValue,0)                
From InvoiceAbstract, Customer      
Where InvoiceAbstract.CustomerID = Customer.CustomerID And      
Customer.CustomerID In (Select CustomerID From #Customer) And  
InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
And InvoiceType in (5, 6)      
And (isnull(Status, 0) & 192) = 0      
Union  
Select N'I', DocumentID, InvoiceAbstract.InvoiceDate, @Inv_Pre + Cast(DocumentID as nvarchar), DocReference, Customer.Company_Name, 0 - InvoiceAbstract.NetValue, Customer.TIN_Number,
IsNull(DiscountValue,0)+IsNull(AddlDiscountValue,0)+IsNull(ProductDiscount,0)+IsNull(SchemeDiscountAmount,0),IsNull(AdjustedAmount,0),IsNull(AdjustmentValue,0)                
From InvoiceAbstract, Customer      
Where InvoiceAbstract.CustomerID = Customer.CustomerID And      
Customer.CustomerID In (Select CustomerID From #Customer) And  
InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
And InvoiceType In (4)      
And (isnull(Status, 0) & 192) = 0      
      
------------------Cursor used to stored both the CST and LST Percentage -------------------      
Declare LST_Tax Cursor For      
Select Distinct Cast(Percentage as nvarchar) from Tax      
Where Percentage <> 0 --And Active = 1    
Union      
Select Distinct Cast(CST_Percentage as nvarchar) from Tax        
Where CST_Percentage <> 0  --And Active = 1      
      
Declare CST_Tax Cursor For      
Select Distinct Cast(Percentage as nvarchar) from Tax        
Where Percentage <> 0 --And Active = 1      
Union      
Select Distinct Cast(CST_Percentage as nvarchar) from Tax      
Where CST_Percentage <> 0  --And Active = 1    
      
------------------------ Adding CST as Column for Outstation Invoices------------------------      
Set @Field_Str = N''      
Open CST_Tax       
Fetch from CST_Tax Into @TaxPerc      
 SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Outstation (Exempt) Sales Value' + N'] Decimal(18,6) null'                     
 Set @Field_Str = N'[Outstation (Exempt) Sales Value], '      
 EXEC sp_executesql @AlterSQL                    
      
 SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Outstation (0%) Sales Value' + N'] Decimal(18,6) null'                     
 Set @Field_Str = @Field_Str + N'[Outstation (0%) Sales Value], '      
 EXEC sp_executesql @AlterSQL       
       
WHILE @@FETCH_STATUS = 0                    
BEGIN      
      
 SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Outstation (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value' + N'] Decimal(18,6) null'            
 Set @Field_Str = @Field_Str + N'[Outstation (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value], '      
 EXEC sp_executesql @AlterSQL                    
       
 SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Outstation (' + Cast(@TaxPerc as nvarchar) + N'%) VAT' + '] Decimal(18,6) null'                     
 Set @Field_Str = @Field_Str + N'[Outstation (' + Cast(@TaxPerc as nvarchar) + N'%) VAT], '      
 EXEC sp_executesql @AlterSQL                     
      
FETCH NEXT FROM CST_Tax INTO @TaxPerc         
END      
      
---------------------------Adding LST as Column for STO-------------------------------------      
Set @Field_Str1 = N''          
Open LST_Tax       
Fetch from LST_Tax Into @TaxPerc      
SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'STO (Exempt) Sales Value' + N'] Decimal(18,6) null'                     
Set @Field_Str1 = @Field_Str1 + N'[STO (Exempt) Sales Value], '      
EXEC sp_executesql @AlterSQL                    
      
SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'STO (0%) Sales Value' + N'] Decimal(18,6) null'                     
Set @Field_Str1 = @Field_Str1 + N'[STO (0%) Sales Value], '      
EXEC sp_executesql @AlterSQL                               
      
WHILE @@FETCH_STATUS = 0                    
BEGIN      
  SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'STO (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value' + N'] Decimal(18,6) null'                     
 Set @Field_Str1 = @Field_Str1 + N'[STO (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value], '      
 EXEC sp_executesql @AlterSQL                    
      
  SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'STO (' + Cast(@TaxPerc as nvarchar) + N'%) VAT' + N'] Decimal(18,6) null'                     
 Set @Field_Str1 = @Field_Str1 + N'[STO (' + Cast(@TaxPerc as nvarchar) + N'%) VAT], '      
 EXEC sp_executesql @AlterSQL                  
       
            
FETCH NEXT FROM LST_Tax INTO @TaxPerc         
End      
Close LST_Tax      
      
---------------------------Adding LST as Column for Invoices---------------------------------      
Set @Field_Str2 = N''            
Open LST_Tax       
Fetch from LST_Tax Into @TaxPerc      
SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Invoice (Exempt) Sales Value' + N'] Decimal(18,6) null'                     
Set @Field_Str2 = @Field_Str2 + N'[Invoice (Exempt) Sales Value], '      
EXEC sp_executesql @AlterSQL                    
      
SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Invoice (0%) Sales Value' + N'] Decimal(18,6) null'                     
Set @Field_Str2 = @Field_Str2 + N'[Invoice (0%) Sales Value], '       
EXEC sp_executesql @AlterSQL                               
      
WHILE @@FETCH_STATUS = 0                    
BEGIN      
  SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Invoice (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value' + N'] Decimal(18,6) null'                     
 Set @Field_Str2 = @Field_Str2 + N'[Invoice (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value], '      
 EXEC sp_executesql @AlterSQL                    
      
  SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Invoice (' + Cast(@TaxPerc as nvarchar) + N'%) VAT' + N'] Decimal(18,6) null'                     
 Set @Field_Str2 = @Field_Str2 + N'[Invoice (' + Cast(@TaxPerc as nvarchar) + N'%) VAT], '      
 EXEC sp_executesql @AlterSQL                  
       
            
FETCH NEXT FROM LST_Tax INTO @TaxPerc         
End      
Close LST_Tax    
      
------------------------Adding LST as Column for Retail Invoices----------------------------      
Set @Field_Str3 = N''                
Open LST_Tax       
Fetch from LST_Tax Into @TaxPerc      
SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Retail (Exempt) Sales Value' + N'] Decimal(18,6) null'                     
Set @Field_Str3 = @Field_Str3 + N'[Retail (Exempt) Sales Value], '       
EXEC sp_executesql @AlterSQL                    
      
SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Retail (0%) Sales Value' + N'] Decimal(18,6) null'                     
Set @Field_Str3 = @Field_Str3 + N'[Retail (0%) Sales Value], '       
EXEC sp_executesql @AlterSQL             
      
WHILE @@FETCH_STATUS = 0                    
BEGIN      
  SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Retail (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value' + N'] Decimal(18,6) null'                   
 Set @Field_Str3 = @Field_Str3 + N'[Retail (' + Cast(@TaxPerc as nvarchar) + N'%) Sales Value], '       
 EXEC sp_executesql @AlterSQL                    
      
  SET @AlterSQL = N'ALTER TABLE #SalesVAT Add [' + N'Retail (' + Cast(@TaxPerc as nvarchar) + N'%) VAT' + N'] Decimal(18,6) null'                     
 Set @Field_Str3 = @Field_Str3 + N'[Retail (' + Cast(@TaxPerc as nvarchar) + N'%) VAT],'      
 EXEC sp_executesql @AlterSQL                  
       
            
FETCH NEXT FROM LST_Tax INTO @TaxPerc         
End      
Close LST_Tax      
      
-- Fields Concadinated for select stat.      
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
      
-- Cursor for Storing Sales Value and VAT for Invoices (Outstation Customers), STO, Invoices, Retail Invoices      
      
Declare TaxVal Cursor for      
------------------------ Invoices for Outstation Customers-------------------------------      
Select 1, DocumentID, Sum(Amount) - Sum(CSTPayable), Sum(CSTPayable), InvoiceDetail.TaxCode2,      
Cast((Case When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax = 0 Then N'Exempt'       
When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax <> 0 Then N'0%'       
Else Cast(Cast(InvoiceDetail.TaxCode2 as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)      
from InvoiceAbstract
Inner Join  InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID      
Left Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode2 = Tax.Percentage              
Inner Join Customer On invoiceAbstract.CustomerID = Customer.CustomerID      
Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code            
Where Customer.CustomerID In (Select CustomerID From #Customer)  
And InvoiceType in (1,3)      
And Customer.Locality = 2      
And (isnull(Status, 0) & 128) = 0      
And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
Group By DocumentID, InvoiceDetail.TaxCode2, Items.Sale_Tax    
union  all    
-------------------------------------------- STO-----------------------------------------       
Select 2, DocumentID, Sum(Amount), Sum(StockTransferOutDetail.TaxAmount), StockTransferOutDetail.TaxSuffered,       
Case       
When StockTransferOutDetail.TaxSuffered = 0 and Items.Sale_Tax <> 0 Then N'0%'      
When StockTransferOutDetail.TaxSuffered = 0 and Items.Sale_Tax = 0 Then N'Exempt'      
Else Cast( Cast(StockTransferOutDetail.TaxSuffered as Decimal(18,6)) as nvarchar) + N'%' End      
From  StockTransferOutDetail, StockTransferOutAbstract, Items      
Where StockTransferOutDetail.DocSerial = StockTransferOutAbstract.DocSerial      
And StockTransferOutDetail.product_Code = Items.Product_Code      
And (isnull(Status, 0) & 128) = 0      
and StockTransferOutAbstract.DocumentDate Between @From_Date and @To_Date   
Group by StockTransferOutDetail.TaxSuffered, DocumentID, Items.Sale_Tax      
Union  all    
------------------------------------------ Invoices----------------------------------------      
Select 3, DocumentID, Sum(Amount) - Sum(STPayable), Sum(STPayable), InvoiceDetail.TaxCode,      
Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'Exempt'       
When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax <> 0 Then N'0%'      
Else Cast(Cast(InvoiceDetail.TaxCode as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)      
from InvoiceAbstract
Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID     
Left Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode = Tax.Percentage             
Inner Join Customer On invoiceAbstract.CustomerID = Customer.CustomerID  
Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code             
Where Customer.CustomerID In (Select CustomerID From #Customer)      
And InvoiceType in (1,3)      
And Customer.Locality = 1      
And (isnull(Status, 0) & 128) = 0      
And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
Group By DocumentID, InvoiceDetail.TaxCode, Items.Sale_Tax    
Union  all    
------------------------------------- Retail Invoices--------------------------------------      
Select 4, DocumentID, Sum(Amount) - Sum(STPayable), Sum(STPayable), InvoiceDetail.TaxCode,      
Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'Exempt'       
When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax <> 0 Then N'0%'      
Else Cast(Cast(InvoiceDetail.TaxCode as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)      
from InvoiceAbstract
Inner Join InvoiceDetail On  InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID      
Left Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode = Tax.Percentage          
Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID      
Inner Join Items On InvoiceDetail.product_Code = Items.Product_Code             
Where Customer.CustomerID In (Select CustomerID From #Customer)  
And InvoiceType in (2)  
And (isnull(Status, 0) & 128) = 0      
And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
Group By DocumentID, InvoiceDetail.TaxCode, Items.Sale_Tax    
Union  all    
------------------Sales Return for Retail Invoices-----------------------------------------  
Select 7, DocumentID, 0 - (Sum(Amount) - Sum(STPayable)), 0 - Sum(STPayable), InvoiceDetail.TaxCode,      
Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'Exempt'       
When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax <> 0 Then N'0%'      
Else Cast(Cast(InvoiceDetail.TaxCode as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)      
from InvoiceAbstract
 Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID      
Left Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode = Tax.Percentage           
Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID      
Inner Join  Items  On InvoiceDetail.product_Code = Items.Product_Code      
Where Customer.CustomerID In (Select CustomerID From #Customer)  
And InvoiceType in (5, 6)  
And (isnull(Status, 0) & 128) = 0      
And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
Group By DocumentID, InvoiceDetail.TaxCode, Items.Sale_Tax    
Union  all    
  
------------------ Sales Return for invoices (Local Customers) ---------------------------      
Select 5, DocumentID, 0 - (sum(Amount) - sum(STPayable)), 0 - sum(STPayable), InvoiceDetail.TaxCode,      
Cast((Case When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax = 0 Then N'Exempt'       
When InvoiceDetail.TaxCode = 0 and Items.Sale_Tax <> 0 Then N'0%'       
Else Cast(Cast(InvoiceDetail.TaxCode as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)      
from InvoiceAbstract
Inner Join  InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID      
Left Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode = Tax.Percentage              
Inner Join Customer On invoiceAbstract.CustomerID = Customer.CustomerID 
Inner Join  Items On InvoiceDetail.product_Code = Items.Product_Code      
Where --And Customer.CustomerID In (Select CustomerID From #Customer)      
 InvoiceType in (4)      
And Customer.Locality = 1      
And (isnull(Status, 0) & 128) = 0      
And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date      
Group By DocumentID, InvoiceDetail.TaxCode, Items.Sale_Tax      
Union  all    
----------------- Sales Return for invoices (Outstation Customers)-------------------------      
Select 6, DocumentID, 0 - (sum(Amount) - sum(CSTPayable)), 0 - sum(CSTPayable), InvoiceDetail.TaxCode2,        
Cast((Case When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax = 0 Then N'Exempt'         
When InvoiceDetail.TaxCode2 = 0 and Items.Sale_Tax <> 0 Then N'0%'        
Else Cast(Cast(InvoiceDetail.TaxCode2 as  Decimal(18,6)) as nvarchar) + N'%' End) as nvarchar)        
from InvoiceAbstract
Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID        
Left Outer Join Tax On Tax.Tax_Code = InvoiceDetail.TaxID And InvoiceDetail.TaxCode2 = Tax.CST_Percentage                 
Inner Join  Customer On invoiceAbstract.CustomerID = Customer.CustomerID  
Inner Join  Items On InvoiceDetail.product_Code = Items.Product_Code        
Where   Customer.CustomerID In (Select CustomerID From #Customer)        
And InvoiceType in (4)        
And Customer.Locality = 2        
And (isnull(Status, 0) & 128) = 0        
And InvoiceAbstract.InvoiceDate Between @From_Date and @To_Date        
Group By DocumentID, InvoiceDetail.TaxCode2, Items.Sale_Tax          
      
------------------- Updating Sales Value and VAT for all Tax levels ------------------------      
Open TaxVal       
Fetch From TaxVal Into @DocType, @DocID, @SalesVal, @TaxVal, @TaxPer, @PerLevel      
      
WHILE @@FETCH_STATUS = 0                    
BEGIN      
      
IF @DocType = 1 Or @DocType = 6         
Begin        
  
  SET @UpdateSQL = N'Update #SalesVAT Set [Outstation (' + @PerLevel + N') Sales Value] = isnull([Outstation (' + @PerLevel + N') Sales Value],0) + ' + cast (@SalesVal as nvarchar) + N' Where TempDocID = '''+ Cast(@DocID as nvarchar)  +''' and DocType = 
''I'''  
   
  
   
                
  exec sp_executesql @UpdateSQL                   
        
  if @PerLevel <> N'Exempt' and @PerLevel <> N'0%'         
  begin      
  SET @UpdateSQL = N'Update #SalesVAT Set [Outstation (' + @PerLevel + N') VAT] = isnull([Outstation (' + @PerLevel + N') VAT],0) + ' + cast (@TaxVal as nvarchar) + N' Where TempDocID = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''I'''             
   
  exec sp_executesql @UpdateSQL                   
  end      
End         
Else If @DocType = 2        
Begin       
  SET @UpdateSQL = N'Update #SalesVAT Set [STO (' + @PerLevel + N') Sales Value] = isnull([STO (' + @PerLevel + N') Sales Value],0) + ' + cast (@SalesVal as nvarchar) + N' Where TempDocID  = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''S'''        
       
  
  
  exec sp_executesql @UpdateSQL                   
        
  if @PerLevel <> N'Exempt' and @PerLevel <> N'0%'         
  begin      
  SET @UpdateSQL = N'Update #SalesVAT Set [STO (' + @PerLevel + N') VAT] = isnull([STO (' + @PerLevel + N') VAT],0) + ' + cast (@TaxVal as nvarchar) + N' Where TempDocID  = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''S'''               
  exec sp_executesql @UpdateSQL                   
  end      
End         
Else If @DocType = 3 or @DocType = 5         
Begin        
  SET @UpdateSQL = N'Update #SalesVAT Set [Invoice (' + @PerLevel + N') Sales Value] = isnull([Invoice (' + @PerLevel + N') Sales Value],0) + ' + cast (@SalesVal as nvarchar) + N' Where TempDocID  = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''I'''
        
  
  
  exec sp_executesql @UpdateSQL                   
        
  if @PerLevel <> N'Exempt' and @PerLevel <> N'0%'          
  begin      
  SET @UpdateSQL = N'Update #SalesVAT Set [Invoice (' + @PerLevel + N') VAT] = isnull([Invoice (' + @PerLevel + N') VAT],0) + ' + cast (@TaxVal as nvarchar) + N' Where TempDocID = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''I'''        
  exec sp_executesql @UpdateSQL           
  end      
End         
Else If @DocType = 4 or @DocType = 7  
Begin   
  SET @UpdateSQL = N'Update #SalesVAT Set [Retail (' + @PerLevel + N') Sales Value] = isnull([Retail (' + @PerLevel + N') Sales Value],0) + ' + cast (@SalesVal as nvarchar) + N' Where TempDocID  = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''R'''  
      
  exec sp_executesql @UpdateSQL                   
        
  if @PerLevel <> N'Exempt' and @PerLevel <> N'0%'         
  begin      
  SET @UpdateSQL = N'Update #SalesVAT Set [Retail (' + @PerLevel + N') VAT] = isnull([Retail (' + @PerLevel + N') VAT],0) + ' + cast (@TaxVal as nvarchar) + N' Where TempDocID = '''+ Cast(@DocID as nvarchar)  +''' and DocType = ''R'''        
  exec sp_executesql @UpdateSQL                   
  end      
End         
      
Fetch Next From TaxVal Into @DocType, @DocID, @SalesVal, @TaxVal, @TaxPer, @PerLevel      
END      
      
Close CST_Tax      
DeAllocate CST_Tax      
DeAllocate LST_Tax      
Close TaxVal      
DeAllocate TaxVal      
  
exec (N'Select DocuDate, ''Document Date'' = DocuDate, ''Document ID '' = DocuID , ''Document Ref'' = DocRef, ''Customer/Branch'' = Cust_Name, [TIN Number], NetValue,[Discount Value],[Credit Note Adjusted Amount],[F11 Adjustment]' + @Field_Str + @Field_Str1+@Field_Str2+@Field_Str3+ ' From  #SalesVAT Order by DocuDate,DocuID')      
Drop Table #SalesVAT      
Drop table #Customer  
Drop table #WareHouse  
  
