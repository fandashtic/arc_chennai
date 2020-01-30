CREATE Function sp_acc_con_getaccountopeningbalance(@accountid integer,@CurrentDate datetime)
Returns Decimal(18,2)
As
Begin
DECLARE @openingvalue decimal(18,2)
DECLARE @balance decimal(18,2)
Set @CurrentDate = dbo.stripdatefromtime(@CurrentDate)

if not exists (select top 1 OpeningValue from accountopeningbalance where [AccountID]=@accountid and OpeningDate = @CurrentDate) 
begin
	Select @openingvalue = isNull(OpeningBalance,0) from AccountsMaster
	where AccountID=@accountID and isnull([Active],0)=1	
end
else
begin
	select @openingvalue = isnull(OpeningValue,0) from accountopeningbalance
	where [AccountID]=@accountid and OpeningDate = @CurrentDate
end
return  isnull(@openingvalue,0)
End

