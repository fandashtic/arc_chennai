CREATE procedure [dbo].[sp_view_IssueGiftVoucherAbstract](@CollectionID int)          
as          
select "FullDocID" = FullDocID, "DocumentDate" = DocumentDate, 
"Company_Name" = Customer.Company_Name,        
"CustomerID" = GiftVoucherDetail.CustomerID, "PaymentMode" = PaymentMode, 
"ChequeDetails" = ChequeDetails,        
"ChequeNumber" = ChequeNumber, "ChequeDate" = ChequeDate, "Value" = Value, 
"Balance" = Balance,        
"BankCode" = BankMaster.BankCode, "BranchCode" = BranchMaster.BranchCode, 
"BankName" = BankMaster.BankName,         
"BranchName" = BranchMaster.BranchName, "Salesman_Name" = Salesman.Salesman_Name, 
"Status" = Collections.Status,        
"DocReference " = DocReference, "AdjAmount" = Value - Balance,        
"DocID" = Collections.DocumentReference,        
"DocType" = Collections.DocSerialType,        
"TIN Number" = null, "Alternate Name" = null,        
"Billing Address" = null,Collections.Status      
from Collections, Customer, BankMaster, BranchMaster, Salesman ,
IssueGiftVoucher,GiftVoucherDetail          
where IssueGiftVoucher.CollectionID = @CollectionID and
IssueGiftVoucher.CollectionID = Collections.DocumentID and
GiftVoucherDetail.SerialNo = IssueGiftVoucher.SerialNo  and                       
GiftVoucherDetail.CustomerID = Customer.CustomerID and  
Collections.BankCode *= BankMaster.BankCode and          
Collections.BranchCode *= BranchMaster.BranchCode And          
Collections.SalesmanID *= Salesman.SalesmanID          
group by         
FullDocID,DocumentDate,Customer.Company_Name,        
GiftVoucherDetail.CustomerID,PaymentMode,ChequeDetails,        
ChequeNumber,ChequeDate,Value, Balance,        
BankMaster.BankCode,BranchMaster.BranchCode,BankMaster.BankName,         
BranchMaster.BranchName,Salesman.Salesman_Name,  Collections.Status,        
DocReference,         
Collections.DocumentReference,        
Collections.DocSerialType
