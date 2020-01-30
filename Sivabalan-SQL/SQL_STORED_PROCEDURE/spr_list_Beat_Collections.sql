CREATE procedure spr_list_Beat_Collections(@BeatName nvarchar(2550),        
        @FromDate datetime,        
        @ToDate datetime)        
as        

Declare @OTHERS NVarchar(50)
Declare @CASH NVarchar(50)
Declare @CHEQUE NVarchar(50)
Declare @DD NVarchar(50)
Declare @BTRANSFER NVarchar(50)


Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)
Set @CASH = dbo.LookupDictionaryItem(N'Cash', Default)
Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque', Default)
Set @DD = dbo.LookupDictionaryItem(N'DD', Default)
Set @BTRANSFER = dbo.LookupDictionaryItem(N'Bank Transfer', Default)



Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  

Create table #tmpBeat(BeatName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @BeatName=N'%'
   insert into #tmpBeat select Description from Beat
else
   insert into #tmpBeat select * from dbo.sp_SplitIn2Rows(@BeatName ,@Delimeter)

select DocumentID, "Collection ID" = FullDocID, "Document Ref" = DocReference, "Date" = DocumentDate,        
"Beat" = case Isnull(collections.BeatID,0)
 when 0 then @OTHERS
 else Beat.Description
end,         
"Customer Name" = Customer.Company_Name,         
"Payment Mode" = case PaymentMode        
when 0 then        
@CASH       
when 1 then        
@CHEQUE        
when 2 then        
@DD
when 4 then        
@BTRANSFER
end,        
"Value" = Collections.Value, "Current Balance" = Collections.Balance,        
"Cheque Number" = 
Case PaymentMode
	When 4 Then Collections.Memo
	Else Cast(Collections.ChequeNumber as nvarchar)
End,
"Cheque Date " =  Case  PaymentMode     
When 0 then    
NULL    
when 1 then    
Collections.ChequeDate        
when 2 then    
Collections.ChequeDate        
when 4 then    
Null
end,     
"Account Number" = 
	Isnull((Select Bank.Account_Number from Bank where Bank.BankId = Isnull(Collections.BankId,0)),N''),
"Bank" = BankMaster.BankName,        
"Branch" = BranchMaster.BranchName        
from Collections 
Inner Join Customer On Customer.CustomerID = Collections.CustomerID 
Left Outer Join Beat On IsNull(Collections.BeatID, 0) = Beat.BeatID 
Left Outer Join BranchMaster On Collections.BranchCode = BranchMaster.BranchCode And
Collections.BankCode = BranchMaster.BankCode
Left Outer Join BankMaster On Collections.BankCode = BankMaster.Bankcode 
where        
Collections.DocumentDate between @FromDate and @ToDate and        
IsNull(Beat.Description, N'') In (select isnull(BeatName,N'') COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpBeat) and        
(IsNull(Collections.Status, 0) & 64) = 0 And
(IsNull(Collections.Status,0) & 128) = 0 
And
ISnull(Cast(Collections.BeatID As nvarchar),N'%') like (Case @BeatName When N'%' Then N'%' Else Cast(Beat.BeatID AS nvarchar) End)

drop table #tmpBeat




