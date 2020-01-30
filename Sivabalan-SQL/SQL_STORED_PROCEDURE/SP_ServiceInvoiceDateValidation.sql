CREATE procedure SP_ServiceInvoiceDateValidation
@TransDate datetime
As
BEGIN
set dateformat dmy
declare @maxtransdate datetime
select @maxtransdate =   Max(TransactionDate) from ServiceAbstract
If(dbo.StripDateFromTime(@TransDate) <  dbo.StripDateFromTime(@maxtransdate))
Select 0 as Id,'Transaction Date should not be less than last Service invoice date('+ Convert(nvarchar,@maxtransdate,103)+')' as 'Message'
Else
Select 1 as Id,'' as 'Message'
END
