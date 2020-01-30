CREATE procedure sp_list_GiftVoucher_CreditNote(@LoyaltyID nVarchar(15),              
          @FromDate datetime,              
          @ToDate datetime)              
as   
--Print @LoyaltyID      
--Print @FromDate
--Print @Todate

Set Dateformat dmy
Begin
select Loyalty.LoyaltyID, Loyalty.Loyaltyname,  Customer.CustomerID, Company_Name, DocumentDate, GiftVoucherNo,  NoteValue
from CreditNote, Loyalty, Customer     
where Loyalty.LoyaltyID like @LoyaltyID  and            
DocumentDate between @FromDate  and @ToDate and   
Loyalty.LoyaltyID = CreditNote.LoyaltyID and 
Customer.CustomerID = CreditNote.CustomerID              
order by Loyalty.Loyaltyname, DocumentDate        
End

--dbo.LookupDictionaryItem(case           
--When Status & 64 <> 0 Then N'Cancelled'            
--When isnull(status,0) = 0  and  isnull(RefDocid,0) = 0  Then N''
--when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then N'Amended'    
--when isnull(status & 128,0 ) = 128 and Balance = 0  then N'Amended'    
--when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then N'Amendment'    
--Else N''            
--end, Default),

