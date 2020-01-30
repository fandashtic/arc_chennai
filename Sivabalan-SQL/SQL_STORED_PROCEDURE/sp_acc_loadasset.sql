CREATE procedure sp_acc_loadasset(@accountid int)
as
Declare @TempStartDate nvarchar(50)
Declare @StartDate datetime
Declare @EndDate datetime

--Select @TempStartDate =cast('01/' + cast(IsNull(FiscalYear,4) as varchar)
--+ '/' + Cast(Year(OpeningDate) As Varchar(50)) as varchar) From Setup

Select @StartDate = dbo.sp_acc_GetFiscalYearStart()
--set @StartDate = Cast(@TempStartDate As DateTime)
Set @EndDate =Cast(@StartDate As DateTime)
set @EndDate = DateAdd(m, 12, @EndDate)  
set @EndDate = DateAdd(d, 0-1, @EndDate)

select 'SerialNumber'=BatchNumber,Rate,MfrDate,Location,
'Supplier'= dbo.getaccountname(isnull(SupplierID,0)),SupplierID,
BillNo,BillDate,AssetsMfrNo,InspectionDate,WarrantyPeriod,
InsuranceFromDate,InsuranceToDate,AMCFromDate,AMCToDate,
PersonResponsible,BillAmount,APVID,BatchCode,OPWDV,
'Saleable'= isnull(Saleable,0),OldBillDate
from Batch_Assets where [AccountID]= @accountid
and ((APVID is null and dbo.stripdatefromtime(CreationTime) < dbo.stripdatefromtime(@StartDate)
and Saleable = 1) or (APVID is null and dbo.stripdatefromtime(CreationTime) >= dbo.stripdatefromtime(@StartDate))
or (APVID is not null and dbo.stripdatefromtime(APVDate) < dbo.stripdatefromtime(@StartDate)
and Saleable = 1))


