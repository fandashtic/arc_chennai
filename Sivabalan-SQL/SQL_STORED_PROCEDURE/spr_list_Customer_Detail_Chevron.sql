CREATE procedure [dbo].[spr_list_Customer_Detail_Chevron](@CUSTOMER nvarchar(15))
as
Begin
Declare @GOOD NVarchar(50)
Declare @AVERAGE NVarchar(50)
Declare @BAD NVarchar(50)
Declare @BASE NVarchar(50)
Declare @SATELITE NVarchar(50)
Declare @RURAL NVarchar(50)
Declare @URBAN NVarchar(50)
Declare @LOCAL NVarchar(50)
Declare @OUTSTATION NVarchar(50)
Declare @CASH NVarchar(50)
Declare @CHEQUE NVarchar(50)
Declare @CREDIT NVarchar(50)
Declare @DD NVarchar(50)
Declare @KEY NVarchar(50)
Declare @NORMAL NVarchar(50)
Declare @SUNDRY NVarchar(50)
Declare @YES NVarchar(50)


Set @GOOD = dbo.LookupDictionaryItem(N'Good', Default) 
Set @AVERAGE = dbo.LookupDictionaryItem(N'Average', Default) 
Set @BAD = dbo.LookupDictionaryItem(N'Bad', Default) 
Set @BASE = dbo.LookupDictionaryItem(N'Base Town', Default) 
Set @SATELITE = dbo.LookupDictionaryItem(N'Satellite', Default) 
Set @RURAL = dbo.LookupDictionaryItem(N'Rural Rural', Default) 
Set @URBAN = dbo.LookupDictionaryItem(N'Rural Urban', Default) 
Set @LOCAL = dbo.LookupDictionaryItem(N'Local', Default) 
Set @OUTSTATION = dbo.LookupDictionaryItem(N'OutStation', Default) 
Set @CASH = dbo.LookupDictionaryItem(N'Cash', Default) 
Set @CHEQUE = dbo.LookupDictionaryItem(N'Cheque', Default) 
Set @CREDIT = dbo.LookupDictionaryItem(N'Credit', Default) 
Set @DD = dbo.LookupDictionaryItem(N'DD', Default) 
Set @KEY = dbo.LookupDictionaryItem(N'Key Account', Default) 
Set @NORMAL = dbo.LookupDictionaryItem(N'Normal Account', Default) 
Set @SUNDRY = dbo.LookupDictionaryItem(N'Sundry Debtors', Default) 
Set @YES = dbo.LookupDictionaryItem(N'Yes', Default) 

select distinct
C.CustomerId,
"Customer Id"= C.CustomerId,
"Customer Name"=C.Company_Name,
"Channel Type"=CC.ChannelDesc,
"Customer Segment"=CS.SegmentName,
"Beat"=(SELECT Description from Beat where 
BeatId =
(select beatId from Beat_Salesman where CustomerId=C.CustomerID)),
"Contact Person"=C.ContactPerson,
"Billing Address"=C.BillingAddress,
"Shipping Address"=ShippingAddress,
"Pincode"=C.Pincode,
"Office Phone"=C.Phone,
"Recidence Phone"=C.Residence,
"Mobile"=C.MobileNumber,
"Email"=Email,
"Area"=A.Area,
"City"=CY.CityName,
"District"=D.DistrictName,
"State"=S.State,
"Country"=CN.Country,
"DL Number 20"=C.DLNumber,
"DL Number 21"=C.DLNumber21,
"ST Registration"=C.TNGST,
"CST Registration"=C.CST,
"TIN_Number"=TIN_Number,
"Town Classification"=(case isnull(TownClassify,0) 
when 1 Then @BASE
When 2 Then @SATELITE
When 3 Then @RURAL
When 4 Then @URBAN
else N'' end),
"Potential"=Potential,
"Alternate Name"=Alternate_Name,
"Discount(%)"=Discount,
"Credit Term"=CT.Description,
"Credit Limit"=C.CreditLimit,
"Forum Code"=AlternateCode,
"Credit Rating"=(Case CreditRating  
 When 1 then
 @GOOD
 When 2 then
 @AVERAGE
 When 3 then
 @BAD
 else
 N'' 
 end),
"Locality"=(case isnull(Locality,0) 
when 1 Then @LOCAL
when 2 then @OUTSTATION
else N'' end),
"Payment Mode"=(case isnull(Payment_Mode,0) 
when 1 Then @CASH
When 2 Then @CHEQUE
When 3 then @CREDIT
When 4 then @DD
else N'' end),
"Account Type"=(case isnull(AccountType,0) 
when 1 then @KEY 
when 2 then @NORMAL
else N'' end),
"Account Group"=@SUNDRY,
"Track Point"=(case isnull(TrackPoints,0) 
when 1 then @YES
 else N'' end),
"CollectedPoints"=CollectedPoints
From Customer C,Customer_Channel CC, Areas A,City CY ,District D,
State S,Country CN,CreditTerm CT, CustomerSegment CS
WHERE C.CustomerId=@CUSTOMER And
C.SegmentID = CS.SegmentID And
C.ChannelType *= CC.ChannelType And
C.AreaID *= a.AreaID And
C.CityID *= CY.CityID And
C.District *= D.DistrictID And
C.StateId *= S.StateId And
C.CountryId *= CN.CountryId And
C.CreditTerm *= CT.CreditID 
End
