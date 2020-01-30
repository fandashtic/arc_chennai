CREATE Procedure mERP_sp_get_NonQPSDC_ProcessDate  
As  
Begin  
  Declare @ProcessFrom as dateTime, @ProcessTo as DateTime  
  Select @ProcessFrom = Case When (dbo.StripTimeFromDate(ProcessStartDate) < dbo.StripTimeFromDate(ProcessUptoDate)) 
Then dbo.StripTimeFromDate(ProcessUptoDate) Else dbo.StripTimeFromDate(ProcessStartDate) End, 
  @ProcessTo = dbo.StripTimeFromDate(ProcessEndDate)   
  From tbl_mERP_BackDtSchProcessInfo Where Active = 1   
  Select @ProcessFrom, @ProcessTo, DateDiff(day, @ProcessFrom, @ProcessTo) + 1 
--Case When @ProcessFrom = @ProcessTo Then 1 Else DateDiff(day, @ProcessFrom, @ProcessTo) + 1 
End
