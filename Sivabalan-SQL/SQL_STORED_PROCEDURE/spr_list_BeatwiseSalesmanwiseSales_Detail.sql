CREATE Procedure spr_list_BeatwiseSalesmanwiseSales_Detail (@BSID nvarchar(20), @FromDate DateTime, @ToDate DateTime)      
As    
Declare @Prefix nvarchar(20)
Select @Prefix = Prefix From VoucherPrefix Where TranID = N'Invoice'
Declare @FIndex Int    
Set @FIndex = CharIndex(N'$',@BSID)    
Select SalesmanID, (@Prefix + Cast(DocumentID As nvarchar)) "Invoice ID", DocReference, InvoiceDate, cu.Company_Name "Customer",       
(Case When InvoiceType In (4) Then -1 When InvoiceType in (1, 3) Then 1 End) * NetValue "Net Value (%c)",      
(Case When InvoiceType In (4) Then -1 When InvoiceType In (1, 3) Then 1 End) * Balance "Balance (%c)"  From       
InvoiceAbstract ia Join Customer cu On ia.CustomerID = cu.CustomerID Where       
(IsNull(Status, 0) & 192) = 0 And InvoiceType Not In (2)       
And IsNull(SalesmanID, N'') = Substring(@BSID, @FIndex + 1, Len(@BSID))  And     
IsNull(BeatID, N'') = Substring(@BSID, 1, @FIndex - 1)      
And InvoiceDate Between  @FromDate And @ToDate      


