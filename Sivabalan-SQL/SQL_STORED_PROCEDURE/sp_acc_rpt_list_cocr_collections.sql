CREATE procedure [dbo].[sp_acc_rpt_list_cocr_collections](@FromDate datetime,  
        @ToDate datetime)  
As
select DocumentID, "Collection ID" =  Collections.FullDocID,
"Document Ref" = DocReference,  
"Date" = Collections.DocumentDate,
"Payment Mode" = case Collections.PaymentMode   
	When 0 then 'Cash'
	When 1 then 'Cheque'
	When 2 then 'DD'
	When 3 then 'Credit Card'
	When 4 then 'Bank Transfer'
	When 5 Then 'Coupon'
	End,  
"Amount" = Value,
"Bank" = BankMaster.BankName,
"Card Holder" = CardHolder,
"Credit Card Number" = CreditCardNumber
From Collections
Left Join BankMaster on Collections.BankCode = BankMaster.BankCode

where 
--Collections.BankCode *= BankMaster.BankCode And 
Collections.PaymentMode In (3, 4, 5, 6) And
(IsNull(Collections.Status, 0) & 64) = 0 And (IsNull(Collections.Status, 0) & 128) = 0 And
dbo.stripdatefromtime(Collections.DocumentDate) Between @FromDate And @ToDate
Order By Collections.DocumentDate

