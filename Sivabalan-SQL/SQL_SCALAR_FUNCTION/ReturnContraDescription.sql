



create function ReturnContraDescription(@transactiontype integer)
returns nvarchar(200)
as
begin
DECLARE @description nvarchar(200)

DECLARE @CASHDEPOSIT integer
DECLARE @CASHWIDTHDRAWL integer
DECLARE @TOPETTYCASH integer
DECLARE @FROMPETTYCASH integer

SET @CASHDEPOSIT =1
SET @CASHWIDTHDRAWL =2
SET @TOPETTYCASH =3
SET @FROMPETTYCASH =4

if @transactiontype = @CASHDEPOSIT
begin
	set @description = 'Cash deposited in bank'
end
else if @transactiontype = @CASHWIDTHDRAWL
begin
	set @description = 'Cash widthdrawed from bank'
end
else if @transactiontype = @TOPETTYCASH
begin
	set @description = 'Cash transferred to petty cash'
end
else if @transactiontype = @TOPETTYCASH
begin
	set @description = 'Patty Cash transferred to cash'
end
return dbo.LookupDictionaryItem(@description,default)
end




