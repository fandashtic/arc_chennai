CREATE procedure sp_acc_updatecontrabstract(@contradate datetime,@remarks nvarchar(2000),
@fromuser nvarchar(50),@touser nvarchar(50),@totalamount decimal(18,6))
as
Declare @documentid int

begin tran
	update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 58
	select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 58
commit tran

insert ContraAbstract(ContraDate,DocumentID,Remarks,CreationDate,
FromUser,ToUser,TotalAmountTransferred)
values(@contradate,@documentid,@remarks,getdate(),@fromuser,@touser,@totalamount)

select @@identity




