create procedure sp_acc_insert_customercheques
(@custID nvarchar(30),@chqStNo Int,@chqEndNo Int,@BankCode nvarchar(40),@BranchCode nvarchar(40))
as
Declare @Loop Int
Declare @ChqCnt Int
set @ChqCnt = 0
While @chqStNo <= @chqEndNo
Begin

	Insert into customercheques (CustomerID,ChequeNumber,BankCode,BranchCode,Active,CreationDate)
	values (@custID,@chqStNo,@BankCode,@BranchCode,1,Getdate())

	set @chqStNo = @chqStNo + 1
	set @ChqCnt = @ChqCnt + 1
End
select @ChqCnt

