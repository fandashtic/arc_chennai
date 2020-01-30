CREATE procedure [dbo].[spr_salesmanwise_collections_details] (@smanid integer,@FROMDATE datetime, @TODATE datetime)        
as        
Declare @MLCash nVarchar(50)
Declare @MLCheque nVarchar(50)
Declare @MLDD nVarchar(50)
Declare @MLCreditCard nVarchar(50)
Declare @MLBankTransfer nVarchar(50)
Declare @MLCoupon nVarchar(50)
Declare @MLCreditNote nVarchar(50)
Declare @MLGiftVoucher nVarchar(50)
Set @MLCash = dbo.LookupDictionaryItem(N'Cash', Default)
Set @MLCheque = dbo.LookupDictionaryItem(N'Cheque', Default)
Set @MLDD = dbo.LookupDictionaryItem(N'DD', Default)
Set @MLCreditCard = dbo.LookupDictionaryItem(N'Credit Card', Default)
Set @MLBankTransfer = dbo.LookupDictionaryItem(N'Bank Transfer', Default)
Set @MLCoupon = dbo.LookupDictionaryItem(N'Coupon', Default)
Set @MLCreditNote = dbo.LookupDictionaryItem(N'Credit Note', Default)
Set @MLGiftVoucher = dbo.LookupDictionaryItem(N'Gift Voucher', Default)

Create Table #temp1        
(        
autoincid integer IDENTITY (1000,1) NOT NULL ,        
DocId integer,
FullDocID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,        
DocRef nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,        
CustName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,        
Value Decimal(18,6),        
Balance Decimal(18,6),        
PaymentMode nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,        
ChequeNo nvarchar(400),        
Chequedate DateTime,        
AccountNumber nvarchar(200),
Bank nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,        
Branch nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,        
Collectionid integer,        
Docnetvalue decimal(18,6),        
totadj decimal(18,6),        
Extracol decimal(18,6),        
CollWriteoff decimal(18,6),        
invadj decimal(18,6),        
pDiscount Decimal(18,6),        
DisAmt Decimal(18,6),        
Doctype integer        
)        
        
        
insert into #temp1 (DocId, FullDocID, DocRef, CustName, Value, Balance,PaymentMode, ChequeNo, Chequedate,AccountNumber,Bank, Branch,         
Collectionid, Docnetvalue, totadj, Extracol, CollWriteoff, invadj, pDiscount, DisAmt, Doctype)        
Select CollectionDetail.CollectionID, "Document ID"=FullDocId,         
"Document Ref" = DocReference,        
"Customer Name"=Company_Name, "Value" = Case Collectiondetail.Documenttype      
--   When 2 then abs(Collectiondetail.AdjustedAmount)      
   When 4 then abs(Collectiondetail.AdjustedAmount)      
   When 5 then abs(Collectiondetail.AdjustedAmount)      
   When 6 then abs(Collectiondetail.AdjustedAmount)      
   Else 0-(abs(Collectiondetail.AdjustedAmount)) End + Collectiondetail.ExtraCollection,       
"Balance" = Balance,       
"Payment Mode"= case PaymentMode            
when 0 then @MLCash
when 1 then @MLCheque            
when 2 then @MLDD      
when 3 then @MLCreditCard
when 4 then @MLBankTransfer
when 5 then @MLCoupon
when 6 then @MLCreditNote
when 7 then @MLGiftVoucher
end,         
"Cheque No" = Case PaymentMode        
When 1 then Cast(ChequeNumber as nvarchar)        
When 4 then Cast(Memo as nvarchar)        
Else N''        
End,         
"Cheque Date" = Case PaymentMode        
When 1 then Cast(ChequeDate as nvarchar)        
Else Null    
End,        
"Account Number" = 
	Isnull((Select Bank.Account_Number from Bank where Bank.BankId = Isnull(Collections.BankId,0)),N''),
"Bank" = BankName,        
"Branch" = BranchName,        
Collectiondetail.Documentid,        
"Doc Net Value" = Case Collectiondetail.Documenttype         
--   When 2 then Collectiondetail.documentvalue      
   When 4 then Collectiondetail.documentvalue      
   When 5 then Collectiondetail.documentvalue      
   When 6 then Collectiondetail.documentvalue      
   Else 0-(Collectiondetail.documentvalue) End,        
"Total Adjusted"=Case Collectiondetail.Documenttype       
--   When 2 then (Collectiondetail.AdjustedAmount+ CollectionDetail.ExtraCollection)        
   When 4 then (Collectiondetail.AdjustedAmount+ CollectionDetail.ExtraCollection)        
   When 5 then (Collectiondetail.AdjustedAmount + CollectionDetail.ExtraCollection)        
   When 6 then (Collectiondetail.AdjustedAmount + CollectionDetail.ExtraCollection)        
   Else 0-(Collectiondetail.AdjustedAmount+Collectiondetail.Extracollection) End,        
"Extra Collection"=Collectiondetail.ExtraCollection,        
"Collection Writeoff"=Collectiondetail.Adjustment,        
"Invoice Adjustments"=Case Collectiondetail.Documenttype         
  When 4 then(Select Isnull(Invoiceabstract.AdjustedAmount,0) From Invoiceabstract        
       Where Invoiceabstract.Invoiceid=Collectiondetail.Documentid        
       and Collectiondetail.Documenttype=4)        
  When 6 then(Select Isnull(Invoiceabstract.AdjustedAmount,0) From Invoiceabstract        
       Where Invoiceabstract.Invoiceid=Collectiondetail.Documentid        
       and Collectiondetail.Documenttype=6)        
  Else 0 End,        
"% Discount"=Case Collectiondetail.Documenttype         
  When 4 then (Select Isnull(Invoiceabstract.DiscountPercentage,0) + IsNull(Invoiceabstract.AdditionalDiscount,0)         
       From Invoiceabstract Where Invoiceabstract.Invoiceid=Collectiondetail.Documentid        
       and Collectiondetail.Documenttype=4)        
  When 6 then (Select Isnull(Invoiceabstract.DiscountPercentage,0) + IsNull(Invoiceabstract.AdditionalDiscount,0)         
       From Invoiceabstract Where Invoiceabstract.Invoiceid=Collectiondetail.Documentid        
       and Collectiondetail.Documenttype=6)        
  Else 0 End,        
"Discount Amount"=Case Collectiondetail.Documenttype         
  When 4 then (Select Isnull(AddlDiscountValue,0) + ISnull(DiscountValue,0) From       
    Invoiceabstract Where Invoiceabstract.Invoiceid=Collectiondetail.Documentid        
       and Collectiondetail.Documenttype=4)        
  When 6 then (Select Isnull(AddlDiscountValue,0) + ISnull(DiscountValue,0) From       
    Invoiceabstract Where Invoiceabstract.Invoiceid=Collectiondetail.Documentid        
       and Collectiondetail.Documenttype=6)      
  Else 0 End,        
Collectiondetail.Documenttype        
        
from Collectiondetail,collections,BankMaster,BranchMaster,Customer         
Where Collectionid in (Select DocumentID From Collections Where       
DocumentDate between @FROMDATE And @TODATE And (IsNull(Collections.Status,0) & 64) = 0       
And (IsNull(Collections.Status, 0) & 128) = 0 And Collections.CustomerID is Not Null         
and Collections.SalesmanID = @smanid) And salesmanid=@smanid And          
Collections.DocumentID = CollectionDetail.CollectionID And       
collections.customerid=customer.customerid And Collections.Bankcode*=BankMaster.bankcode       
And collections.branchcode*=branchMaster.branchcode And            
collections.bankcode*=branchMaster.bankcode And (IsNull(Collections.Status, 0) & 64) = 0       
And (IsNull(Collections.Status,0) & 128) = 0 And collections.value > 0 And       
collections.documentdate between @fromdate And @todate        
      
       
Select * into #temp2 from #temp1         

Declare @invid integer        
        
DECLARE CUR1 CURSOR FOR         
 Select distinct Collectionid from #temp1 Where Doctype In (4, 6)      
        
open CUR1        
fetch next from CUR1 into @invid        
 while @@fetch_status=0        
 begin           
 Update #temp2 Set         
  invadj =0,pDiscount =0,DisAmt=0         
  Where         
  autoincid in         
  (Select t4.autoincid From #temp1 t4 where t4.collectionid=@invid        
   and t4.Doctype In (4, 6))         
  and autoincid not in         
  (Select top 1 t4.autoincid From #temp1 t4 where t4.collectionid=@invid        
   and t4.Doctype In (4, 6))         
   and Doctype In (4, 6)      
  fetch next from CUR1 into @invid        
 end        
close CUR1        
deallocate CUR1        
        
        
Select 
"FullDocID" = #temp2.FullDocID, "FullDocID" = #temp2.FullDocID, "DocRef" = #temp2.DocRef, 
CustName = #temp2.CustName, 
--"Value" = sum(Value), 
"Value" = Collections.Value, "Balance" = #temp2.Balance, 
"PaymentMode" = #temp2.PaymentMode,  "ChequeNo" = #temp2.ChequeNo, 
"Chequedate" = #temp2.Chequedate,
"AccountNumber" = #temp2.AccountNumber, "Bank" = #temp2.Bank, "Branch" = #temp2.Branch, 
"Doc Net Value" = Sum(#temp2.Docnetvalue) ,        
"Total Adjusted" = Sum(#temp2.Totadj), "Extra Collection" = Sum(#temp2.Extracol), 
"Writeoff" = Sum(#temp2.CollWriteoff),
"Invoice Adjustments"=Sum(#temp2.invadj) , "% Discount" = Sum(#temp2.pDiscount), 
"Discount Amount" = Sum(#temp2.DisAmt)        
From #temp2, Collections Where #temp2.DocID = Collections.Documentid
Group by #temp2.FullDocID, #temp2.DocRef, #temp2.CustName, #temp2.Balance, 
#temp2.PaymentMode, #temp2.ChequeNo, Collections.Value,
#temp2.Chequedate, #temp2.Bank, #temp2.Branch, #temp2.AccountNumber
        
Union        
        
Select         
"Document ID"=FullDocId, "Document ID"=FullDocId, "Document Ref" = DocReference,
"Customer Name"=Company_Name, "Value" = Value, "Balance" = Balance,            
"Payment Mode"=      
case PaymentMode            
when 0 then @MLCash
when 1 then @MLCheque            
when 2 then @MLDD      
when 3 then @MLCreditCard
when 4 then @MLBankTransfer
when 5 then @MLCoupon
when 6 then @MLCreditNote
when 7 then @MLGiftVoucher
end,         
"Cheque No" = Case PaymentMode        
When 1 then Cast(ChequeNumber as nvarchar)       
When 4 then Cast(Memo as nvarchar)        
Else N''    
End,    
"Cheque Date" = Case PaymentMode        
When 1 then Cast(ChequeDate as nvarchar)       
Else Null    
End,     
"Account Number" = 
	Isnull((Select Bank.Account_Number from Bank where Bank.BankId = Isnull(Collections.BankId,0)),N''),
"Bank" = BankName,        
"Branch" = BranchName,        
"Doc Net Value"=Value,        
"Total Adjusted"=Value,        
"Extra Collection"=0,        
"Writeoff"=0,        
"Invoice Adjustments"=0,        
"% Discount"=0,        
"Discount Amount"=0        
from Collections,BankMaster,BranchMaster,Customer      
Where documentid not in (Select Distinct(Collectionid) From Collectiondetail        
 Where Collectionid in(Select DocumentID From Collections Col1        
 Where Col1.DocumentDate between @FROMDATE And @TODATE And         
 (IsNull(Col1.Status,0) & 64) = 0 and (IsNull(Col1.Status, 0) & 128) = 0 And         
 Col1.CustomerID is Not Null and Col1.SalesmanID = @smanid))        
And DocumentDate between @FROMDATE And @TODATE And         
(IsNull(Collections.Status,0) & 64) = 0 and        
(IsNull(Collections.Status,0) & 128) = 0 and        
Collections.CustomerID is Not Null         
and Collections.SalesmanID = @smanid and           
collections.customerid=customer.customerid and            
collections.Bankcode*=BankMaster.bankcode and            
collections.branchcode*=branchMaster.branchcode and            
collections.value > 0 and      
collections.bankcode*=branchMaster.bankcode         
         
        
drop table  #temp1        
drop table  #temp2
