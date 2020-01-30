CREATE Procedure Sp_Acc_Prn_Cus_MJAbstract (@MJId Int)
As
Declare @Prefix nVarchar(250)
Select @Prefix = Isnull(Prefix,N'') from VoucherPrefix where [TranID]=N'MANUAL JOURNAL' 
Select 
"Transaction ID" = isnull(@Prefix + cast(DocumentNumber as nvarchar(250)),N''),
"Voucher No" = Voucherno,
"Date" = TransactionDate,
"Narration" = 
	(Select top 1 substring(Remarks,1,Datalength(Remarks)) from Generaljournal where 
	TransactionID = @MJId and
	DocumentType in (26,37))
From Generaljournal 
Where 
TransactionID = @MJId
and [DocumentType] in (26,37)
Group By VoucherNo,TransactionDate,DocumentNumber

