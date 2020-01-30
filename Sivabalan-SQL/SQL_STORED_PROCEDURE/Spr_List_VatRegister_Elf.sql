CREATE Procedure [dbo].[Spr_List_VatRegister_Elf]( @FromDate datetime, @ToDate DateTime)      
As      
Declare @INV  NVarchar(15)      
Declare @INB  NVarchar(15)      
Declare @INPR  NVarchar(15)      
Declare @Field_Str NVarchar(4000)      
Declare @Field_Str1 NVarchar(4000)      
Declare @Field_Str2 NVarchar(4000)      
Declare @Field_Str3 NVarchar(4000)      
Declare @TaxPerc Decimal(18,6)              
Declare @AlterSQL nvarchar(4000)              
Declare @UpdateSQL nvarchar(4000)              
Declare @DocType Integer              
Declare @DocID Integer       
Declare @TaxableAmt Decimal(18,6)              
Declare @TaxAmt Decimal(18,6)              
Declare @AmtWithTax Decimal(18,6)              
Declare @PerLevel varchar(255)        
Declare @PerLevel1 varchar(255)        
Declare @Remarks varchar(255)        
      
set NoCount on      
SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'                  
SELECT @INB = Prefix FROM VoucherPrefix WHERE TranID = N'BILL'
SELECT @INPR = Prefix FROM VoucherPrefix WHERE TranID = N'PURCHASE RETURN'                  
      
Create Table #TmpVATRep( [DocType] Nvarchar(5)COLLATE SQL_Latin1_General_CP1_CI_AS , [TempDocId] Int , [I_Date] DateTime, [Date] DateTime, [TaxInvoice No / Bill No] NVarchar(50),[Name of Purchaser] NVarchar(255),      
[Address] NVarchar(255), [Gross Amount] Decimal(18,6), [Credit Note]  Decimal(18,6), [OutPut Tax (%c)] Decimal(18,6),      
[Buyer VAT NO] NVarchar(20))      
Insert into #TmpVATRep ([DocType], [TempDocId], [I_Date], [Date], [TaxInvoice No / Bill No], [Name of Purchaser],      
 [Address], [Gross Amount], [Credit Note], [OutPut Tax (%c)], [Buyer VAT NO])              
--Bill      
  Select 'B', BA.DocumentID,  BA.BillDate, BA.BillDate, --@INB +@INBA+ CAST(BA.DocumentID AS nvarchar),      
 CASE   
 WHEN BA.DocumentReference IS NULL THEN  
 BillPrefix.Prefix + CAST(BA.DocumentID AS nVARCHAR)  
 ELSE  
 BillAPrefix.Prefix + CAST(BA.DocumentID AS nVARCHAR)  
 END,
   VEN.Vendor_Name, VEN.Address, BA.Value,      
   (Select IsNull(Sum(NoteValue),0)as [Credit Note] From CreditNote Where VendorID = VEN.VendorID Group by VendorID), BD.TaxSuffered,  VEN.Tin_Number      
  From BillAbstract BA, BillDetail BD,      
  Vendors VEN, VoucherPrefix BillPrefix,VoucherPrefix BillAPrefix  
  Where               
  BA.BillID = BD.BillID              
  and BA.BillDate between @FromDate and @ToDate              
  and (isnull(BA.Status,0) & 128) = 0              
  and VEN.VendorID = BA.VendorID       
  and BD.Vat = 1 
  and BillAPrefix.TranID = N'BILL AMENDMENT' 
  and BillPrefix.TranID = N'BILL' 
     
  Group by  BA.DocumentID,  BA.BillDate, VEN.Vendor_Name, VEN.Address,      
  BA.Value,BD.TaxSuffered,VEN.Tin_Number,VEN.VendorID, BillPrefix.Prefix,
  BillAPrefix.Prefix, BA.DocumentReference
  Having SUM(BD.Amount + BD.TaxAmount)>0              
Union       
--Invoice       
  Select 'I', IA.DocumentID, IA.InvoiceDate, IA.InvoiceDate,  @INV + CAST(IA.DocumentID AS nvarchar),      
   CUS.Company_Name, CUS.BillingAddress, IA.GrossValue,      
   (Select IsNull(Sum(NoteValue),0)as [Credit Note] From CreditNote Where CustomerID = CUS.CustomerID Group by VendorID),  
 Case When CUS.Locality = 1  Then IDT.TaxCode Else IDT.TaxCode2 End , CUS.Tin_Number      
  From InvoiceAbstract IA, InvoiceDetail IDT,      
  Customer CUS  
  Where               
  IA.InvoiceID = IDT.InvoiceID              
  and IA.InvoiceDate between @FromDate and @ToDate              
  and (Isnull(IA.Status, 0) & 192) = 0               
  and IA.InvoiceType in (1, 3)              
  and CUS.CustomerID = IA.CustomerID              
  and IDT.Vat = 1      
  group by IA.InvoiceDate, IA.InvoiceDate, IA.DocumentID, CUS.Company_Name,      
  CUS.BillingAddress, IA.GrossValue, IDT.TaxCode, CUS.Tin_Number, CUS.CustomerID, CUS.Locality, IDT.TaxCode2  
  having sum(IDt.Amount)>0              
Union       
--Retail Invoice      
  Select  'R', IA.DocumentID, IA.InvoiceDate, IA.InvoiceDate,  @INV + CAST(IA.DocumentID AS nvarchar),      
    CUS.Company_Name, CUS.BillingAddress, IA.GrossValue,      
    (Select IsNull(Sum(NoteValue),0)as [Credit Note] From CreditNote Where CustomerID = CUS.CustomerID Group by VendorID),   
  Case When CUS.Locality = 1  Then IDT.TaxCode Else IDT.TaxCode2 End , CUS.Tin_Number      
  From  InvoiceAbstract IA, InvoiceDetail IDT, Customer CUS  
  Where               
  IA.InvoiceID = IDT.InvoiceID              
  and IA.InvoiceDate between @FromDate and @ToDate              
  and (IA.Status & 192) = 0              
  and IA.InvoiceType in (2)              
  and CUS.CustomerID = IA.CustomerID              
  and IDT.Vat = 1      
   Group by IA.InvoiceDate, IA.InvoiceDate, IA.DocumentID, CUS.Company_Name,       
 CUS.BillingAddress, IA.GrossValue, IDT.TaxCode, CUS.Tin_Number, CUS.CustomerID, CUS.Locality, IDT.TaxCode2  
Union      
--Sales Return      
  Select 'I', IA.DocumentID, IA.InvoiceDate, IA.InvoiceDate,  @INV + CAST(IA.DocumentID AS nvarchar),      
 CUS.Company_Name, CUS.BillingAddress, IA.GrossValue,      
 (Select IsNull(Sum(NoteValue),0)as [Credit Note] From CreditNote Where CustomerID = CUS.CustomerID Group by VendorID),   
  Case When CUS.Locality = 1  Then IDT.TaxCode Else IDT.TaxCode2 End , CUS.Tin_Number      
  From InvoiceAbstract IA, InvoiceDetail IDT,      
  Customer CUS  
  Where               
  IA.InvoiceID = IDT.InvoiceID              
  and IA.InvoiceDate between @FromDate and @ToDate              
  and (Isnull(IA.Status, 0) & 192) = 0               
  and IA.InvoiceType in (4)              
  and CUS.CustomerID = IA.CustomerID              
  and IDT.Vat = 1      
  group by IA.InvoiceDate, IA.InvoiceDate, IA.DocumentID, CUS.Company_Name,      
  CUS.BillingAddress, IA.GrossValue, IDT.TaxCode, CUS.Tin_Number, CUS.CustomerID, CUS.Locality, IDT.TaxCode2  
  having sum(IDt.Amount)>0              
  
------------------Cursor used to stored both the CST and LST Percentage -------------------            
Declare LST_Tax Cursor For            
Select Distinct Cast(Percentage as Varchar) from Tax            
Where Percentage <> 0 And Active = 1          
Union            
Select Distinct Cast(CST_Percentage as Varchar) from Tax              
Where CST_Percentage <> 0  And Active = 1            
            
Declare CST_Tax Cursor For            
Select Distinct Cast(Percentage as Varchar) from Tax              
Where Percentage <> 0 And Active = 1            
Union            
Select Distinct Cast(CST_Percentage as Varchar) from Tax            
Where CST_Percentage <> 0  And Active = 1          
      
------------------------ Adding LST as Column for Bill------------------------            
Set @Field_Str = ''       
Open LST_Tax             
Fetch from LST_Tax Into @TaxPerc            
WHILE @@FETCH_STATUS = 0                          
BEGIN            
            
 SET @AlterSQL = N'ALTER TABLE #TmpVATRep Add [' + 'Bill (' + Cast(@TaxPerc as varchar) + '%) Taxable Amount (%c)' + '] Decimal(18,6) null'                  
 Set @Field_Str = @Field_Str + '[Bill (' + Cast(@TaxPerc as varchar) + '%) Taxable Amount (%c)], '            
 EXEC sp_executesql @AlterSQL                          
             
 SET @AlterSQL = N'ALTER TABLE #TmpVATRep Add [' + 'Bill (' + Cast(@TaxPerc as varchar) + '%) OutPut Tax (%c)' + '] Decimal(18,6) null'                           
 Set @Field_Str = @Field_Str + '[Bill (' + Cast(@TaxPerc as varchar) + '%) OutPut Tax (%c)], '            
 EXEC sp_executesql @AlterSQL                           
      
 SET @AlterSQL = N'ALTER TABLE #TmpVATRep Add [' + 'Bill (' + Cast(@TaxPerc as varchar) + '%) Amount With Tax (%c)' + '] Decimal(18,6) null'                           
 Set @Field_Str = @Field_Str + '[Bill (' + Cast(@TaxPerc as varchar) + '%) Amount With Tax (%c)], '            
 EXEC sp_executesql @AlterSQL                           
            
FETCH NEXT FROM LST_Tax INTO @TaxPerc               
END         
Close LST_Tax       
------------------------ Adding LST as Column for Invoices------------------------            
Set @Field_Str1 = ''       
Open LST_Tax             
Fetch from LST_Tax Into @TaxPerc            
WHILE @@FETCH_STATUS = 0                          
BEGIN            
            
 SET @AlterSQL = N'ALTER TABLE #TmpVATRep Add [' + 'Invoices (' + Cast(@TaxPerc as varchar) + '%) Taxable Amount (%c)' + '] Decimal(18,6) null'                  
 Set @Field_Str1 = @Field_Str1 + '[Invoices (' + Cast(@TaxPerc as varchar) + '%) Taxable Amount (%c)], '            
 EXEC sp_executesql @AlterSQL                          
             
 SET @AlterSQL = N'ALTER TABLE #TmpVATRep Add [' + 'Invoices (' + Cast(@TaxPerc as varchar) + '%) OutPut Tax (%c)' + '] Decimal(18,6) null'                           
 Set @Field_Str1 = @Field_Str1 + '[Invoices (' + Cast(@TaxPerc as varchar) + '%) OutPut Tax (%c)], '            
 EXEC sp_executesql @AlterSQL                           
      
 SET @AlterSQL = N'ALTER TABLE #TmpVATRep Add [' + 'Invoices (' + Cast(@TaxPerc as varchar) + '%) Amount With Tax (%c)' + '] Decimal(18,6) null'                           
 Set @Field_Str1 = @Field_Str1 + '[Invoices (' + Cast(@TaxPerc as varchar) + '%) Amount With Tax (%c)], '            
 EXEC sp_executesql @AlterSQL                           
            
FETCH NEXT FROM LST_Tax INTO @TaxPerc               
END         
Close LST_Tax       
            
------------------------ Adding LST as Column for Retail------------------------            
Set @Field_Str2 = ''       
Open LST_Tax             
Fetch from LST_Tax Into @TaxPerc            
WHILE @@FETCH_STATUS = 0                          
BEGIN            
            
 SET @AlterSQL = N'ALTER TABLE #TmpVATRep Add [' + 'Retail (' + Cast(@TaxPerc as varchar) + '%) Taxable Amount (%c)' + '] Decimal(18,6) null'                  
 Set @Field_Str2 = @Field_Str2 + '[Retail (' + Cast(@TaxPerc as varchar) + '%) Taxable Amount (%c)], '            
 EXEC sp_executesql @AlterSQL                          
             
 SET @AlterSQL = N'ALTER TABLE #TmpVATRep Add [' + 'Retail (' + Cast(@TaxPerc as varchar) + '%) OutPut Tax (%c)' + '] Decimal(18,6) null'                           
 Set @Field_Str2 = @Field_Str2 + '[Retail (' + Cast(@TaxPerc as varchar) + '%) OutPut Tax (%c)], '            
 EXEC sp_executesql @AlterSQL                           
      
 SET @AlterSQL = N'ALTER TABLE #TmpVATRep Add [' + 'Retail (' + Cast(@TaxPerc as varchar) + '%) Amount With Tax (%c)' + '] Decimal(18,6) null'                           
 Set @Field_Str2 = @Field_Str2 + '[Retail (' + Cast(@TaxPerc as varchar) + '%) Amount With Tax (%c)], '            
 EXEC sp_executesql @AlterSQL                           
            
FETCH NEXT FROM LST_Tax INTO @TaxPerc               
END         
Close LST_Tax       
------------------------ Adding CST as Column for Invoices------------------------            
Set @Field_Str3 = ''       
Open CST_Tax             
Fetch from CST_Tax Into @TaxPerc            
WHILE @@FETCH_STATUS = 0                          
BEGIN            
            
 SET @AlterSQL = N'ALTER TABLE #TmpVATRep Add [' + 'Outstation (' + Cast(@TaxPerc as varchar) + '%) Taxable Amount (%c)' + '] Decimal(18,6) null'                  
 Set @Field_Str3 = @Field_Str3 + '[Outstation (' + Cast(@TaxPerc as varchar) + '%) Taxable Amount (%c)], '            
 EXEC sp_executesql @AlterSQL                          
             
 SET @AlterSQL = N'ALTER TABLE #TmpVATRep Add [' + 'Outstation (' + Cast(@TaxPerc as varchar) + '%) OutPut Tax (%c)' + '] Decimal(18,6) null'                           
 Set @Field_Str3 = @Field_Str3 + '[Outstation (' + Cast(@TaxPerc as varchar) + '%) OutPut Tax (%c)], '            
 EXEC sp_executesql @AlterSQL       
      
 SET @AlterSQL = N'ALTER TABLE #TmpVATRep Add [' + 'Outstation (' + Cast(@TaxPerc as varchar) + '%) Amount With Tax (%c)' + '] Decimal(18,6) null'                           
 Set @Field_Str3 = @Field_Str3 + '[Outstation (' + Cast(@TaxPerc as varchar) + '%) Amount With Tax (%c)], '            
 EXEC sp_executesql @AlterSQL          
FETCH NEXT FROM CST_Tax INTO @TaxPerc               
END        
      
----------- Fields Concadinated for select stat.              
Set @Field_Str = Substring(@Field_Str, 1, Len(@Field_Str) - 1)               
IF len(@Field_Str)>0          
 Set @Field_Str = ','+@Field_Str          
Set @Field_Str1 = Substring(@Field_Str1, 1, Len(@Field_Str1) - 1)               
          
IF Len(@Field_Str1)>0          
 Set @Field_Str1 = ','+@Field_Str1          
          
Set @Field_Str2= Substring(@Field_Str2, 1, Len(@Field_Str2) - 1)               
IF Len(@Field_Str2)>0          
 Set @Field_Str2= ','+@Field_Str2          
          
Set @Field_Str3 = Substring(@Field_Str3, 1, Len(@Field_Str3) - 1)               
IF Len(@Field_Str3)>0          
 Set @Field_Str3=','+@Field_Str3       
      
-- Cursor for Storing Taxable Amount, OutPut Tax  and Amount With Tax for  Invoices, Retail Invoices, Sales Return and Invoices (Outstation Customers)              
Declare TaxVal Cursor for       
  Select 1, BA.DocumentID, ((BD.Quantity*BD.PurchasePrice)-Bd.Discount),BD.TaxAmount,(((BD.Quantity*BD.PurchasePrice)-Bd.Discount)+ BD.TaxAmount),      
  Cast( Cast(Cast(BD.TaxSuffered as Decimal(18,6)) as Varchar) + '%' as Varchar)      From BillAbstract BA
  Inner Join BillDetail BD On BA.BillID = BD.BillID              
  Inner Join Vendors VEN On VEN.VendorID = BA.VendorID       
  Left Outer Join Tax On Tax.Tax_Code = BD.TaxCode and BD.TaxCode = Tax.Percentage                              
  Where BA.BillDate between @FromDate and @ToDate              
  and (isnull(BA.Status,0) & 128) = 0              
  and BD.Vat = 1      
  Group By BA.DocumentID, ((BD.Quantity*BD.PurchasePrice)-Bd.Discount),BD.TaxAmount,(((BD.Quantity*BD.PurchasePrice)-Bd.Discount)+ BD.TaxAmount), BD.TaxSuffered    
Union       
--Invoice       
  Select 2, IA.DocumentID, (IDT.Quantity * IDT.SalePrice), IDT.Taxamount, (IDT.Amount),      
  Cast( Cast(IDT.TaxCode as Varchar) + '%' as Varchar)              
  From InvoiceAbstract IA
  Inner Join InvoiceDetail IDT On IA.InvoiceID = IDT.InvoiceID              
  Inner Join Customer CUS On CUS.CustomerID = IA.CustomerID              
  Left Outer Join Tax On IDT.TaxCode = Tax.Percentage and Tax.Tax_Code = IDT.TaxID                             
  Where IA.InvoiceDate between @FromDate and @ToDate              
  and (Isnull(IA.Status, 0) & 192) = 0               
  and IA.InvoiceType in (1, 3)              
  and CUS.Locality = 1   
  and IDT.Vat = 1      
   Group By  IA.DocumentID, (IDT.Quantity * IDT.SalePrice), IDT.Taxamount, (IDT.Amount), IDT.TaxCode      
Union       
--Retail Invoice      
  Select 3, IA.DocumentID, (IDT.Quantity * IDT.SalePrice), IDT.Taxamount, (IDT.Amount),      
  Cast( Cast(IDT.TaxCode as Varchar) + '%' as Varchar)      
  From  InvoiceAbstract IA
  Inner Join  InvoiceDetail IDT On IA.InvoiceID = IDT.InvoiceID              
  Inner Join Customer CUS On CUS.CustomerID = IA.CustomerID              
  Left Outer Join Tax On IDT.TaxCode = Tax.Percentage And Tax.Tax_Code = IDT.TaxID                              
  Where IA.InvoiceDate between @FromDate and @ToDate              
  and (IA.Status & 192) = 0              
  and IA.InvoiceType in (2)              
  and CUS.Locality = 1   
  and IDT.Vat = 1      
   Group By  IA.DocumentID, (IDT.Quantity * IDT.SalePrice), IDT.Taxamount, IDT.Amount, IDT.TaxCode      
Union      
--Sales Return      
  Select 4, IA.DocumentID, (IDT.Quantity * IDT.SalePrice), IDT.Taxamount, IDT.Amount,      
  Cast( Cast(IDT.TaxCode as Varchar) + '%' as Varchar)      
  From InvoiceAbstract IA
  Inner Join InvoiceDetail IDT On IA.InvoiceID = IDT.InvoiceID              
  Inner Join Customer CUS On CUS.CustomerID = IA.CustomerID        
  Left Outer Join Tax On IDT.TaxCode = Tax.Percentage And Tax.Tax_Code = IDT.TaxID                                 
  Where IA.InvoiceDate between @FromDate and @ToDate              
  and (Isnull(IA.Status, 0) & 192) = 0               
  and IA.InvoiceType in (4)              
  and CUS.Locality = 1             
  and IDT.Vat = 1      
   Group By  IA.DocumentID, (IDT.Quantity * IDT.SalePrice), IDT.Taxamount, IDT.Amount, IDT.TaxCode      
Union      
--Invoice Outsation      
  Select 5, IA.DocumentID, (IDT.Quantity * IDT.SalePrice), IDT.CSTPayable, (IDT.Amount),      
  Cast( Cast(IDT.TaxCode2 as Varchar) + '%' as Varchar)      
  From InvoiceAbstract IA
  Inner Join  InvoiceDetail IDT On IA.InvoiceID = IDT.InvoiceID              
  Inner Join  Customer CUS On CUS.CustomerID = IA.CustomerID        
  Left Outer Join Tax On IDT.TaxCode = Tax.Percentage And Tax.Tax_Code = IDT.TaxID                                       
  Where IA.InvoiceDate between @FromDate and @ToDate              
  and (Isnull(IA.Status, 0) & 192) = 0               
  and IA.InvoiceType in (1, 3)              
  and CUS.Locality = 2             
  and IDT.Vat = 1      
  Group By  IA.DocumentID, (IDT.Quantity * IDT.SalePrice), IDT.CSTPayable, (IDT.Amount), IDT.TaxCode2      
Union      
--Sales Return Out Station      
  Select 6, IA.DocumentID, (IDT.Quantity * IDT.SalePrice), IDT.CSTPayable, IDT.Amount,      
  Cast( Cast(IDT.TaxCode2 as Varchar) + '%' as Varchar)      
  From InvoiceAbstract IA
  Inner Join InvoiceDetail IDT On IA.InvoiceID = IDT.InvoiceID              
  Inner Join Customer CUS On CUS.CustomerID = IA.CustomerID        
  Left Outer Join Tax On IDT.TaxCode = Tax.Percentage And Tax.Tax_Code = IDT.TaxID                               
  Where IA.InvoiceDate between @FromDate and @ToDate              
  and (Isnull(IA.Status, 0) & 192) = 0               
  and IA.InvoiceType in (4)              
  and CUS.Locality = 2             
  and IDT.Vat = 1      
  Group By  IA.DocumentID, (IDT.Quantity * IDT.SalePrice), IDT.CSTPayable, IDT.Amount, IDT.TaxCode2      
------------------- Updating  Taxable Amount, OutPut Tax(%c) and VAT for all Tax levels ------------------------              
Open TaxVal               
Fetch From TaxVal Into @DocType, @DocID, @TaxableAmt, @TaxAmt, @AmtWithTax, @PerLevel              
              
WHILE @@FETCH_STATUS = 0                            
BEGIN              
          
Set @PerLevel1 = Substring(@PerLevel, 1, Len(@PerLevel) - 1)      
IF @DocType = 1                  
Begin               
  if @PerLevel <> '0.000000%'        
 Begin           
   SET @UpdateSQL = 'Update #TmpVATRep Set [Bill (' + @PerLevel + ') Taxable Amount (%c)] = isnull([Bill (' + @PerLevel + ') Taxable Amount (%c)],0) + '+  Cast(@TaxableAmt as varchar)  + ' Where TempDocID = '''+ Cast(@DocID as Varchar)      
+'''  And [OutPut Tax (%c)] ='+ @PerLevel1 +' and DocType = ''B'''       
   exec sp_executesql @UpdateSQL       
   SET @UpdateSQL = 'Update #TmpVATRep Set [Bill (' + @PerLevel + ') OutPut Tax (%c)] = isnull([Bill (' + @PerLevel + ') OutPut Tax (%c)],0) + '+ Cast(@TaxAmt as varchar) + ' Where TempDocID = '''+ Cast(@DocID as Varchar)      
+'''  And [OutPut Tax (%c)] ='+ @PerLevel1 +' and DocType = ''B'''       
   exec sp_executesql @UpdateSQL          
   SET @UpdateSQL = 'Update #TmpVATRep Set [Bill (' + @PerLevel + ') Amount With Tax (%c)] = isnull([Bill (' + @PerLevel + ') Amount With Tax (%c)],0) + '+ Cast( @AmtWithTax as varchar)  + ' Where TempDocID = '''+ Cast(@DocID as Varchar)     
 +'''  And [OutPut Tax (%c)] ='+ @PerLevel1 +' and DocType = ''B'''       
   exec sp_executesql @UpdateSQL        
 End      
End                 
Else If @DocType = 2 or @DocType = 4      
Begin        
  if @PerLevel <> '0.000000%'        
 Begin                   
  
   SET @UpdateSQL = 'Update #TmpVATRep Set [Invoices (' + @PerLevel + ') Taxable Amount (%c)] = isnull([Invoices (' + @PerLevel + ') Taxable Amount (%c)],0) + '+ cast (@TaxableAmt as varchar) + ' Where TempDocID = '''+ Cast(@DocID as Varchar)      
+'''  And [OutPut Tax (%c)] ='+@PerLevel1 +' and DocType = ''I'''       
   exec sp_executesql @UpdateSQL        
   SET @UpdateSQL = 'Update #TmpVATRep Set [Invoices (' + @PerLevel + ') OutPut Tax (%c)] = isnull([Invoices (' + @PerLevel + ') OutPut Tax (%c)],0) + '+  cast (@TaxAmt as varchar) + ' Where TempDocID = '''+ Cast(@DocID as Varchar)     
 +''' And [OutPut Tax (%c)] ='+@PerLevel1 +'  and DocType = ''I'''  
   exec sp_executesql @UpdateSQL          
   SET @UpdateSQL = 'Update #TmpVATRep Set [Invoices (' + @PerLevel + ') Amount With Tax (%c)] = isnull([Invoices (' + @PerLevel + ') Amount With Tax (%c)],0) + '+  cast (@AmtWithTax as varchar) + ' Where TempDocID = '''+ Cast(@DocID as Varchar)     
 +'''  And [OutPut Tax (%c)] ='+@PerLevel1 +' and DocType = ''I'''       
   exec sp_executesql @UpdateSQL          
 End      
End                 
Else If @DocType = 3                 
Begin          
  if @PerLevel <> '0.000000%'        
 Begin               
   SET @UpdateSQL = 'Update #TmpVATRep Set [Retail (' + @PerLevel + ') Taxable Amount (%c)] = isnull([Retail (' + @PerLevel + ') Taxable Amount (%c)],0) + '+ cast (@TaxableAmt as varchar) + ' Where TempDocID = '''+ Cast(@DocID as Varchar)  +'''    
  And [OutPut Tax (%c)] ='+@PerLevel1 +' and DocType = ''R'''       
   exec sp_executesql @UpdateSQL                           
   SET @UpdateSQL = 'Update #TmpVATRep Set [Retail (' + @PerLevel + ') OutPut Tax (%c)] = isnull([Retail (' + @PerLevel + ') OutPut Tax (%c)],0) + '+  cast (@TaxAmt as varchar) + ' Where TempDocID = '''+ Cast(@DocID as Varchar)  +'''     
And [OutPut Tax (%c)] ='+@PerLevel1 +'  and DocType = ''R'''       
   exec sp_executesql @UpdateSQL          
   SET @UpdateSQL = 'Update #TmpVATRep Set [Retail (' + @PerLevel + ') Amount With Tax (%c)] = isnull([Retail (' + @PerLevel + ') Amount With Tax (%c)],0) + '+  cast (@AmtWithTax as varchar) + ' Where TempDocID = '''+ Cast(@DocID as Varchar)  +'''    
 And [OutPut Tax (%c)] ='+@PerLevel1 +'  and DocType = ''R'''       
   exec sp_executesql @UpdateSQL             
 End      
End                 
Else If  @DocType = 5 or @DocType = 6               
Begin      
  if @PerLevel <> '0.000000%'        
  Begin           
   SET @UpdateSQL = 'Update #TmpVATRep Set [Outstation (' + @PerLevel + ') Taxable Amount (%c)] = isnull([Outstation (' + @PerLevel + ') Amount With Tax (%c)],0) + '+  cast (@TaxableAmt as varchar) + ' Where TempDocID = '''+ Cast(@DocID as Varchar)  +''' 
 
And [OutPut Tax (%c)] ='+@PerLevel1 +' and DocType = ''R'' or DocType = ''I'' and TempDocID = '''+ Cast(@DocID as Varchar) +''''       
   exec sp_executesql @UpdateSQL     
   SET @UpdateSQL = 'Update #TmpVATRep Set [Outstation (' + @PerLevel + ') OutPut Tax (%c)] = isnull([Outstation (' + @PerLevel + ') OutPut Tax (%c)],0) + '+   cast (@TaxAmt as varchar) + ' Where TempDocID = '''+ Cast(@DocID as Varchar)   
+'''  And [OutPut Tax (%c)] ='+@PerLevel1 +' and DocType = ''R'' or  DocType = ''I''  and TempDocID = '''+ Cast(@DocID as Varchar) +''''       
   exec sp_executesql @UpdateSQL          
   SET @UpdateSQL = 'Update #TmpVATRep Set [Outstation (' + @PerLevel + ') Amount With Tax (%c)] = isnull([Outstation (' + @PerLevel + ') Amount With Tax (%c)],0) + '+   cast (@AmtWithTax as varchar) + ' Where TempDocID = '''+ Cast(@DocID as Varchar)     
 
+''' And [OutPut Tax (%c)] ='+@PerLevel1 +' and DocType = ''R'' or DocType = ''I'' and TempDocID = '''+ Cast(@DocID as Varchar) +''''       
   exec sp_executesql @UpdateSQL         
  End                    
End                 
              
Fetch Next From TaxVal Into @DocType, @DocID, @TaxableAmt, @TaxAmt, @AmtWithTax, @PerLevel              
END              
      
Close CST_Tax              
DeAllocate CST_Tax     
DeAllocate LST_Tax              
Close TaxVal              
DeAllocate TaxVal              
      
exec ('Select  [I_Date], [Date], [TaxInvoice No / Bill No], [Name of Purchaser],      
 [Address], [Gross Amount], Isnull([Credit Note],0) as [Credit Note], Isnull([OutPut Tax (%c)],0) as [OutPut Tax (%c)], [Buyer VAT NO]' + @Field_Str + @Field_Str1+@Field_Str2+@Field_Str3+ ' From  #TmpVATRep')                
      
Drop Table #TmpVATRep      
Set NoCount off      
  


