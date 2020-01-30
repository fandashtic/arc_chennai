CREATE Procedure [dbo].[mERP_get_CustomerDetails]
(
@CustID Int
)
As
--Declare @CustID Int
--Set @CustID = 1

Declare @ProcessStatus Int
Declare @Customerid nVarchar(30)
Declare @Customid nVarchar(30)
Declare @HHOutletname nVarchar(255)
Declare @HHmarketInfo nVarchar(255)
Declare @SMSAlerts nVarchar(255)
Declare @Latitude Decimal(18,6)
Declare @Longitude  Decimal(18,6)

Select @ProcessStatus = [Confirmation Status], @Customerid = HHCustID ,@HHOutletname = [HHOutlet name] from HHCustomer Where ID = @CustID

--Select @ProcessStatus,@Customerid,@HHOutletname

If Isnull(@ProcessStatus,0) = 1
Begin
Select @Customid = Customerid FROM Customer WHERE RecHHCustomerID = @Customerid  AND CustomerCategory <> 4

Select @HHmarketInfo = Cast(MI.MarketID as nVarchar(10))+ N'-'+MI.MarketName
from MarketInfo MI, CustomerMarketInfo C
Where C.Active = 1 and C.MMID = MI.MMID
and Ltrim(Rtrim(C.CustomerCode)) = @Customid

Select @Latitude = isnull(Latitude,0) , @Longitude = isnull(Longitude,0)  from OutletGeo where customerId=@Customid


Select @SMSAlerts = Case When isnull(SMSAlert,0) = 0 Then 'Yes' Else 'No' End  from Customer where customerID= @Customid




SELECT  customer.Customerid,Customer.Company_Name,
Isnull(@Customerid,'') As HHCustomerid,
Isnull(@HHOutletname,'') As HHCustomerName,
Isnull(ContactPerson,'') ContactPerson,
Isnull(BillingAddress,'') BillingAddress,
Isnull(ShippingAddress,'') ShippingAddress,
Isnull((SELECT Top 1 Area FROM Areas WHERE AreaID = Customer.AreaID  AND ACTIVE = 1 And Isnull(PreDefFlag,0) = 0),'') Areas,
Isnull((SELECT Top 1 CityName FROM City WHERE CityID = Customer.CityID  AND ACTIVE = 1 And Isnull(PreDefFlag,0) = 0),'') CityName,
Isnull((Select Top 1 State from State where StateID = Customer.StateID),'') StateID,
Isnull((select Top 1 Country from Country where CountryID = Customer.CountryID),'') CountryID,
Phone,
(Select Isnull(Description,0) from  CreditTerm where CreditID = Customer.CreditTerm) CreditTerm,
Case When Isnull(CreditLimit,0) < 0 then 0 Else Isnull(CreditLimit,0) End CreditLimit,
Isnull((Select ChannelDesc from Customer_Channel where ChannelType = Customer.ChannelType),'') ChannelType,
Case When IsNull(Payment_Mode,2) = 2 Then 'Credit'
When IsNull(Payment_Mode,2) = 1 Then 'Cheque'
When IsNull(Payment_Mode,2) = 3 Then 'DD'
Else
'Cash'
End As 'Payment_Mode',

Isnull((SELECT DistrictName FROM District WHERE DistrictID = Customer.District And Isnull(PreDefFlag,0) = 0),'') District,
PinCode,
Isnull((Select Description from SubChannel where SubChannelID = Customer.SubChannelID),'') SubChannelID,
MobileNumber,
NoOfBillsOutstanding,
Isnull((Select Isnull(ZoneName,'') from tbl_mERP_Zone where ZoneID = Customer.ZoneID),'') ZoneID,
PANNumber,
(Select ForumStateCode + ' - ' + StateName from StateCode where StateID = isnull(BillingStateID, 0))BillStateID,
(Select ForumStateCode + ' - ' + StateName from StateCode where StateID = isnull(ShippingStateID, 0))ShipStateID,
isnull(GSTIN, '') GSTIN,
Case When isnull(IsRegistered,0) = 1 Then 'Registered' Else 'Unregistered' End IsRegistered,
@HHmarketInfo MarketInfo,
@Latitude Latitude,
@Longitude Longitude,
@SMSAlerts SMSAlerts,
Case When @ProcessStatus = 0 Then 'Pending'
When @ProcessStatus = 1 Then 'Processed'
When @ProcessStatus = 2 Then 'Rejected'
Else
'Expired'
End As 'Status',
Isnull((Select Description from Beat where Beatid = Customer.DefaultBeatid),'') As Beatid
FROM Customer WHERE RecHHCustomerID = @Customerid  AND CustomerCategory <> 4
End
Else
Begin
Select
Isnull((Select SalesMan_name from Salesman where SalesManid = HHCustomer.DSID),'') As DSID,
Isnull((Select Description from Beat where BeatID = HHCustomer.BeatID),'') As BeatID,
Isnull(HHCustID,'') HHCustID,
Isnull([HHOutlet name],'') [HHOutlet name],
Isnull(Address,'') Address,
Isnull((Select ChannelDesc from Customer_Channel where ChannelType = CustomerType),'') As 'CustomerType',
Isnull((Select Description from SubChannel where SubChannelID = SubOutletType),'') As 'SubOutletType',
--CustomerType,
--SubOutletType,
MobileNo,
Case When RegisteredStatus = 1 Then 'Registered' else 'Unregistered' End As 'RegisteredStatus',
Isnull(GSTIN,'') GSTIN,
Latitude,
Longitude,
Isnull([Rejection Reason],'') As "Rejection Reason",
Case When Isnull([Confirmation Status],0) = 0 Then 'Pending'
When Isnull([Confirmation Status],0) = 1 Then 'Processed'
When Isnull([Confirmation Status],0) = 2 Then 'Rejected'
Else
'Expired'
End As 'Status'
from HHCustomer Where ID = @CustID
End
