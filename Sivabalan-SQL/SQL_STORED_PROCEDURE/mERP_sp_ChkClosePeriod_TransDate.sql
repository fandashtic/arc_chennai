
CREATE Procedure mERP_sp_ChkClosePeriod_TransDate
As  
Declare @OpeningDate DateTime   
Declare @FiscalYear Int  
Declare @OperatingDate DateTime  
Declare @diff int
Begin  
  set dateformat dmy
  Declare @DummyDate As nVarchar(20)
  Declare @OperYear As nVarchar(20)

  SELECT TOP 1 @FiscalYear = FiscalYear, @OperYear = OperatingYear, @OperatingDate = dbo.stripTimeFromDate(IsNull(TransactionDate,GetDate())) FROM Setup  

  select @diff = (Year(TransactionDate) - Year(OpeningDate)) from setup

  If @diff>2 
	Set @OperYear = Right(@OperYear,4)
  else
	Set @OperYear = left(@OperYear,4)

  Set @DummyDate = '01/'+ Cast(@FiscalYear as varchar) + '/' + Cast(@OperYear as varchar)

  Set @OpeningDate = dbo.stripTimeFromDate(Cast(@DummyDate as Datetime))

  IF (SELECT DATEDIFF(Year, @OpeningDate, @OperatingDate)) > 0 and (SELECT DATEDIFF(month, @OpeningDate, @OperatingDate)) >= 12 
      SELECT 1  
  ELSE  
      SELECT 0  
End  

