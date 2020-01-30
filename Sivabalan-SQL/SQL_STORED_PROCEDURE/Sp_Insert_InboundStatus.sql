Create Procedure Sp_Insert_InboundStatus
AS
BEGIN
Set Dateformat DMY
Declare @DaycloseDate DateTime
Select @DaycloseDate=dbo.StripDateFromTime(isnull(LastInventoryUpload,GETDATE())) From Setup

Begin
exec sp_Insert_RecdNewCustomer_HH
End
insert into Inbound_Status(LogID,SalesmanID,CreationDate,DaycloseDate)
Select LogID,salesmanID,GETDATE(),@DaycloseDate from Inbound_Log where dbo.StripDateFromTime([date])>@DaycloseDate
And LogId not in (select Distinct LogId from Inbound_Status) and isnull(SalesmanID,0) <> 0
END
