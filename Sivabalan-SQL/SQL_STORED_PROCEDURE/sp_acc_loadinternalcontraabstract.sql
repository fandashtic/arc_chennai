CREATE procedure sp_acc_loadinternalcontraabstract(@fromdate datetime,@todate datetime,@mode int)
as
Declare @prefix as nvarchar(20)
Declare @CLOSE_CONTRA int
Declare @VIEW_CONTRA int

Set @CLOSE_CONTRA = 2
Set @VIEW_CONTRA = 3

select @prefix = Prefix
from VoucherPrefix
where TranID = N'INTERNALCONTRA'

if @mode = @CLOSE_CONTRA
begin
	select ContraID,ContraDate,'DocumentID' = @prefix + cast(DocumentID as nvarchar(20)),
	FromUser,ToUser,TotalAmountTransferred,'Status'=isnull(Status,0)
	from ContraAbstract where dbo.stripdatefromtime(ContraDate) between @fromdate and @todate and
	isnull(Status,0)<> 192
end
else if @mode = @VIEW_CONTRA 
begin
	select ContraID,ContraDate,'DocumentID' = @prefix + cast(DocumentID as nvarchar(20)),
	FromUser,ToUser,TotalAmountTransferred,'Status' = isnull(Status,0)
	from ContraAbstract where dbo.stripdatefromtime(ContraDate) between @fromdate and @todate
end
 


 








