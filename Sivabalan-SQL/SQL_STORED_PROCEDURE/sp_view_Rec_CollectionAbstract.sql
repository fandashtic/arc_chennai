CREATE procedure [dbo].[sp_view_Rec_CollectionAbstract](@CollectionID int)                  
as                  
select "DocSerial" = DocSerial, "DocumentDate" = DocumentDate,       
"Customer Name" = Customer.Company_Name, "CustomerID"=Collections.CustomerID,                  
"PaymentMode" =PaymentMode, "ChequeDetails" =ChequeDetails, "ChequeNumber" =ChequeNumber,      
"ChequeDate" = ChequeDate, "Value" =Value, "Balance" =Balance,      
"BankCode" = isnull(BankMaster.BankCode,N'') , "BranchCode" = isnull(BranchMaster.BranchCode,N'') , "BankName" = isnull(BankMaster.BankName,N'') , "BranchName" = isnull(BranchMaster.BranchName,N''),                   
N'',"Status" =Status, "DocReference" =DocReference, "FullDocID" = FullDocID,"DocumentReference"=DocumentReference                 
from Collectionsreceived Collections , Customer      
, BankMaster, BranchMaster                  
where Collections.CustomerID = Customer.CustomerID and                  
Collections.DocSerial = @CollectionID       
and Collections.Bank *= BankMaster.BankCode and                  
Collections.Branch *= BranchMaster.BranchCode
