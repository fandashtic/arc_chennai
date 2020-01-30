CREATE PROCEDURE [dbo].[sp_Recd_Customer_HH_Info] (
@FromDate DATETIME,
@ToDate DATETIME,
@Status nVarchar(50) = '')
AS

select @ToDate = cast(convert(char(8), @ToDate, 112) + ' 23:59:59.99' as datetime)


If Isnull(@Status,0) = '' or Isnull(@Status,0) = '%'
Begin
Set @Status = 'Pending'
End

If Isnull(@Status,0) = 'All'
Begin
Select Isnull(HHCustID,'') HHCustID ,Isnull([HHOutlet Name],'') [HHOutlet Name],
Isnull((Select Top 1 Description from Beat Where BeatID = HHCustomer.BeatID),'') As 'Beat',
Case When Isnull([Confirmation Status],0) = 0 Then 'Pending'
When Isnull([Confirmation Status],0) = 1 Then 'Processed'
When Isnull([Confirmation Status],0) = 2 Then 'Rejected'
Else
'Expired'
End As 'Status',
Convert(nVarchar(10),[HHCreationDate],103) + N' ' + Convert(nVarchar(8),[HHCreationDate],108) As 'HHCreationDate',
Case When Isnull([Confirmation Status],0) = 3 Then Null Else
Convert(nVarchar(10),[Confirmation Date],103) + N' ' + Convert(nVarchar(8),[Confirmation Date],108) End As 'Confirmation Date',
ID
from HHCustomer where  [HHCreationDate]  Between   dbo.StripTimeFromDate(@FromDate) and  @ToDate

Order by HHCustID,[HHOutlet Name]
End

If Isnull(@Status,0) = 'Pending'
Begin
--Select * from HHCustomer where  [HHCreationDate]  Between  @FromDate and  @ToDate
--And Isnull([Confirmation Status],0) = 0
Select Isnull(HHCustID,'') HHCustID ,Isnull([HHOutlet Name],'') [HHOutlet Name],
Isnull((Select Top 1 Description from Beat Where BeatID = HHCustomer.BeatID),'') As 'Beat',
Case When Isnull([Confirmation Status],0) = 0 Then 'Pending'
When Isnull([Confirmation Status],0) = 1 Then 'Processed'
When Isnull([Confirmation Status],0) = 2 Then 'Rejected'
Else
'Expired'
End As 'Status',
Convert(nVarchar(10),[HHCreationDate],103) + N' ' + Convert(nVarchar(8),[HHCreationDate],108) As 'HHCreationDate',
Case When Isnull([Confirmation Status],0) = 3 Then Null Else
Convert(nVarchar(10),[Confirmation Date],103) + N' ' + Convert(nVarchar(8),[Confirmation Date],108) End As 'Confirmation Date',
ID
from HHCustomer where  [HHCreationDate]  Between   dbo.StripTimeFromDate(@FromDate) and  @ToDate
And Isnull([Confirmation Status],0) =0
Order by HHCustID,[HHOutlet Name]
End

If Isnull(@Status,0) = 'Processed'
Begin
Select Isnull(HHCustID,'') HHCustID ,Isnull([HHOutlet Name],'') [HHOutlet Name],
Isnull((Select Top 1 Description from Beat Where BeatID = HHCustomer.BeatID),'') As 'Beat',
Case When Isnull([Confirmation Status],0) = 0 Then 'Pending'
When Isnull([Confirmation Status],0) = 1 Then 'Processed'
When Isnull([Confirmation Status],0) = 2 Then 'Rejected'
Else
'Expired'
End As 'Status',
Convert(nVarchar(10),[HHCreationDate],103) + N' ' + Convert(nVarchar(8),[HHCreationDate],108) As 'HHCreationDate',
Case When Isnull([Confirmation Status],0) = 3 Then Null Else
Convert(nVarchar(10),[Confirmation Date],103) + N' ' + Convert(nVarchar(8),[Confirmation Date],108) End As 'Confirmation Date',
ID
from HHCustomer where  [HHCreationDate]  Between   dbo.StripTimeFromDate(@FromDate) and  @ToDate
And Isnull([Confirmation Status],0) =1
Order by HHCustID,[HHOutlet Name]
End

If Isnull(@Status,0) = 'Rejected'
Begin
Select Isnull(HHCustID,'') HHCustID ,Isnull([HHOutlet Name],'') [HHOutlet Name],
Isnull((Select Top 1 Description from Beat Where BeatID = HHCustomer.BeatID),'') As 'Beat',
Case When Isnull([Confirmation Status],0) = 0 Then 'Pending'
When Isnull([Confirmation Status],0) = 1 Then 'Processed'
When Isnull([Confirmation Status],0) = 2 Then 'Rejected'
Else
'Expired'
End As 'Status',
Convert(nVarchar(10),[HHCreationDate],103) + N' ' + Convert(nVarchar(8),[HHCreationDate],108) As 'HHCreationDate',
Case When Isnull([Confirmation Status],0) = 3 Then Null Else
Convert(nVarchar(10),[Confirmation Date],103) + N' ' + Convert(nVarchar(8),[Confirmation Date],108) End As 'Confirmation Date',
ID
from HHCustomer where  [HHCreationDate]  Between   dbo.StripTimeFromDate(@FromDate) and  @ToDate
And Isnull([Confirmation Status],0) =2
Order by HHCustID,[HHOutlet Name]
End

If Isnull(@Status,0) = 'Expired'
Begin
Select Isnull(HHCustID,'') HHCustID ,Isnull([HHOutlet Name],'') [HHOutlet Name],
Isnull((Select Top 1 Description from Beat Where BeatID = HHCustomer.BeatID),'') As 'Beat',
Case When Isnull([Confirmation Status],0) = 0 Then 'Pending'
When Isnull([Confirmation Status],0) = 1 Then 'Processed'
When Isnull([Confirmation Status],0) = 2 Then 'Rejected'
Else
'Expired'
End As 'Status',
Convert(nVarchar(10),[HHCreationDate],103) + N' ' + Convert(nVarchar(8),[HHCreationDate],108) As 'HHCreationDate',
Case When Isnull([Confirmation Status],0) = 3 Then Null Else
Convert(nVarchar(10),[Confirmation Date],103) + N' ' + Convert(nVarchar(8),[Confirmation Date],108) End As 'Confirmation Date',
ID
from HHCustomer where  [HHCreationDate]  Between   dbo.StripTimeFromDate(@FromDate) and  @ToDate
And Isnull([Confirmation Status],0) =3
Order by HHCustID,[HHOutlet Name]
End
