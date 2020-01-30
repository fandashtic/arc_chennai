
CREATE Procedure mERP_spr_HHCustomerDetail (@FromDate DateTime, @ToDate DateTime)
AS
Declare @ExpiryFromDate datetime
Declare @ExpiryToDate Datetime
Declare @WDCode NVarchar(255)
Declare @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload
Select Top 1 @WDCode = RegisteredOwner From Setup

Set Dateformat dmy

If @CompaniesToUploadCode = N'ITC001'
Set @WDDest= @WDCode
Else
Begin
Set @WDDest= @WDCode
Set @WDCode= @CompaniesToUploadCode
End

Declare @CurrentMonth Int
Declare @ServerDate DateTime

Set @ServerDate = Getdate()

SELECT @CurrentMonth = DATEPART(MM, @ServerDate)
Select @CurrentMonth = (@CurrentMonth-3)

Begin
Exec sp_Customer_HH_ExpiryValidation
End

Set @ExpiryFromDate=dbo.mERP_fn_getFromDate(right(convert(varchar(10),dateadd(m,-3,@ToDate),105),7))
Set @ExpiryToDate=dbo.mERP_fn_getToDate(right(convert(varchar(10),dateadd(m,-3,@ToDate),105),7))


Create table #hHcustomer (HHCustomerID nvarchar(15),currentstatus nvarchar(1))
--Processed
insert into #hHcustomer(HHCustomerID,currentstatus)
select HHCustID,'P' from hhcustomer where dbo.StripDateFromTime(isnull([Confirmation Date],getdate())) between @Fromdate and @Todate and [Confirmation Status]=1
--Rejected
insert into #hHcustomer(HHCustomerID,currentstatus)
select HHCustID,'R' from hhcustomer where dbo.StripDateFromTime(isnull([Confirmation Date],getdate())) between @Fromdate and @Todate and [Confirmation Status]=2
--Pending
insert into #hHcustomer(HHCustomerID,currentstatus)
select HHCustID,'W' from hhcustomer where dbo.StripDateFromTime(isnull([HHCreationDate],getdate())) between DATEADD(d,1,@ExpiryToDate) and @Todate and [Confirmation Status] in (0,3)
--Expired
insert into #hHcustomer(HHCustomerID,currentstatus)
select HHCustID,'E' from hhcustomer where dbo.StripDateFromTime(isnull([HHCreationDate],getdate()))
between @ExpiryFromDate
and @ExpiryToDate and [Confirmation Status]=3



Select
ID,
[WD_Code] = @WDCode,
[WD Code] = @WDCode,
[WD Dest] = @WDDest,
[FromDate] = @FromDate,
[ToDate] = @ToDate ,
[DS ID] = Case When Isnull(HH.[Confirmation Status],0) = 1
Then Isnull((Select Top 1 SalesManID from Beat_Salesman where SalesManID= HH.DSID ),0)
Else Isnull(HH.DSID,0)
End,
[DS Name] = Case When Isnull(HH.[Confirmation Status],0) = 1
Then (Select Salesman_Name From Salesman Where SalesmanID = HH.DSID)
Else (Select Salesman_Name From Salesman Where SalesmanID = HH.DSID)
End,
[HH Cust ID]=HH.HHCustID,
[Forum Cust ID] = Case When Isnull(HH.[Confirmation Status],0) = 1
Then Isnull(C.CustomerID,'')
Else Isnull(HH.HHCustID,'')
End,
[HH Cust Name]= Isnull(HH.[HHOutlet Name],''),
[Forum Cust Name] = Case When Isnull(HH.[Confirmation Status],0) = 1
Then Isnull(C.Company_Name,'')
Else Isnull(HH.[HHOutlet Name],'')
End,
[Is Register]= Case When Isnull(HH.[Confirmation Status],0) = 1
Then Case When Isnull(IsRegistered,0) = 1 Then 'Yes' Else 'No' End
Else
Case When Isnull(HH.[RegisteredStatus],0) = 1 Then 'Yes' Else 'No' End
End,
[GSTIN] = Case When Isnull(HH.[Confirmation Status],0) = 1
Then Isnull(C.GSTIN,'')
Else Isnull(HH.[GSTIN],'')
End,
[Beat Name] = Case When Isnull(HH.[Confirmation Status],0) = 1
Then (Select Description from Beat where Beatid = C.DefaultBeatID And CustomerID = C.CustomerID)
Else (Select Description from Beat where Beatid = HH.Beatid)
End,
[Latitude] = Case When Isnull(HH.[Confirmation Status],0) = 1
Then Cast(isnull((Select Top 1 cast((case When Isnull(O.Latitude,0) = 0 Then '0.000000'
Else Isnull(O.Latitude,0) End) as Nvarchar(50)) from OutletGeo O where O.CustomerID=C.Customerid),'0.000000') As nvarchar(50))
Else Cast(Isnull(HH.Latitude,0) As nvarchar(50))
End,
[Longitude] = Case When Isnull(HH.[Confirmation Status],0) = 1
Then Cast (isnull((Select Top 1 cast((case When Isnull(O.Longitude,0) = 0 Then '0.000000' Else Isnull(O.Longitude,0) End) as Nvarchar(50)) from OutletGeo O where O.CustomerID=C.CustomerID),'0.000000') As nVarchar(50))
Else Cast(Isnull(HH.Longitude,0) As nVarchar(50))
End,
[Outlet Status]= Case When isnull(HC.currentstatus,'')= 'W' then 'Pending'
When isnull(HC.currentstatus,'')= 'P' then 'Confirmed'
When isnull(HC.currentstatus,'') = 'R'  then 'Rejected'
When isnull(HC.currentstatus,'') = 'E' then 'Expired' End,
[Reason]=Isnull(HH.[Rejection Reason],''),
[HHCaptureDate]=Convert(nVarchar(10),HHCaptureDate,103) + N' ' + Convert(nVarchar(8),HHCaptureDate,108),
[ReceivedDate]= Convert(nVarchar(10),HH.HHCreationDate,103) + N' ' + Convert(nVarchar(8),HH.HHCreationDate,108),
[Process Date and Time]= case  When isnull(HC.currentstatus,'') in ('W', 'E') then '' else Convert(nVarchar(10),HH.[Confirmation Date],103) + N' ' + Convert(nVarchar(8),HH.[Confirmation Date],108) end
Into #TempDetails
From  HHCustomer HH Left outer Join Customer c on HH.HHCUSTID=C.RecHHCustomerID
Inner Join #hHcustomer HC on HH.HHCustID = HC.HHCustomerID
Order By HH.HHCUSTID


Update #TempDetails set [DS ID] = '' Where Isnull([DS Name],'') = ''

Select [WD_Code],[WD Code], [WD Dest],[FromDate],[ToDate],[DS ID],[DS Name],[HH Cust ID],[Forum Cust ID],[HH Cust Name],[Forum Cust Name],
[Is Register],[GSTIN],[Beat Name],[Latitude],[Longitude],[Outlet Status],[Reason],[HHCaptureDate],[ReceivedDate],[Process Date and Time]
from #TempDetails

Drop Table #TempDetails
Drop Table #hHcustomer
