


CREATE procedure sp_acc_updatefadenominations(@mode int,@denomination decimal(18,6),
@denominationtitle nvarchar(10))
as 
Declare @ADD int
Declare @REPLACE int

Set @ADD =1
Set @REPLACE =2

If not exists(Select Top 1 DenominationCount from Denominations where DenominationTitle=@denominationtitle)
Begin
	Insert Into Denominations(DenominationTitle,DenominationCount) values(@denominationtitle,@denomination)
End
else
begin
	if @mode = @ADD
	begin
		update Denominations 
		set DenominationCount = DenominationCount + @denomination 
		where DenominationTitle = @denominationtitle
	end
	else if @mode = @REPLACE 
	begin
		update Denominations 
		set DenominationCount =	@denomination 
		where DenominationTitle = @denominationtitle
	end
end





