CREATE Procedure sp_get_AllSOAbstract_ITC(
@SOFromDate Datetime,
@SOToDate datetime,
@Salesman nVarchar(500)= N'',
@Beat nVarchar(500) = N'',
@Channel Int = 0,
@Subchannel Int = 0)
as
Begin
set Dateformat DMY
Declare @Expirydate datetime
set @Expirydate= dbo.getSOExpiryDate()
Create Table #tblSalesman(SalesManID Int)
Create Table #tblBeat(BeatID Int)
Create Table #tblChannel(ChannelID Int)
Create Table #tblSubChannel(SubChannelID Int)

If @SalesMan = N''
Begin
Insert Into #tblSalesman Values(0)
Insert InTo #tblSalesman Select SalesmanID From SalesMan Where Active = 1
End
Else
Insert InTo #tblSalesman Select * From sp_SplitIn2Rows(@SalesMan,N',')


If @Beat = N''
Begin
Insert Into #tblBeat Values(0)
Insert InTo #tblBeat Select BeatID From Beat Where Active = 1
End
Else
Insert InTo #tblBeat Select * From sp_SplitIn2Rows(@Beat,N',')

If @Channel = 0
Begin
Insert Into #tblChannel Values(0)
Insert Into #tblChannel Select ChannelType From Customer_Channel Where Active = 1
End
Else
Insert Into #tblChannel Values(@Channel)

If @SubChannel = 0
Begin
Insert Into #tblSubChannel Values(0)
Insert Into #tblSubChannel Select  SubChannelID From SubChannel Where Active =1
End
Else
Insert Into #tblSubChannel Values(@SubChannel)


Select
Customer.CustomerID, Customer.Company_Name, SOAbstract.SONumber,
SOAbstract.SODate,Value, DeliveryDate, PODocReference, DocumentID,
dbo.mERP_fn_Get_GroupNames(IsNull(SOAbstract.GroupID,-1)),
Case When soabstract.OrderType > 0 Then
(Select Distinct Isnull(Description,'') from VirtualOrders_Master V Where V.ID = SOAbstract.OrderType)
Else
''
End As 'ForumSC'
from
SOAbstract,Customer
where
((SOAbstract.Status & 192) = 0)
And Customer.CustomerID=SOAbstract.CustomerID
and (SOAbstract.SODate between @SOFromDate and @SOToDate)
And Isnull(SOAbstract.BeatID,0) In (Select  BeatId From #tblBeat)
And Isnull(SOAbstract.SalesmanID,0) In (Select SalesmanID From #tblSalesman)
And IsNull(Customer.ChannelType,0) In (Select ChannelID From #tblChannel)
And IsNull(Customer.SubChannelID, 0) In (Select SubChannelID From #tblSubChannel)
-- order by Customer.Company_Name, SOAbstract.SONumber
And Convert(Nvarchar(10),SOAbstract.SODate,103) > @Expirydate
order by SOAbstract.DocumentID

Drop Table #tblSalesman
Drop Table #tblBeat
Drop Table #tblChannel
Drop Table #tblSubChannel


End
