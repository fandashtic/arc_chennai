

CREATE function GetChequeNumber(@chequeid int,@chequenumber int)
returns nvarchar(30)
as
begin
Declare @chequeno nvarchar(30)

select @chequeno = Cheque_Book_Name
from Cheques where [ChequeID]=@chequeid
set @chequeno = @chequeno + '-' 
set @chequeno = @chequeno + cast(@chequenumber as nvarchar(30))
return @chequeno
end




