Create Procedure spr_list_Customer_Detail_ITC(@CUSTOMER nvarchar(15))
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
"Sub Channel"=SC.Description,
"Beat"=(SELECT Description from Beat where 
BeatId = C.DefaultBeatID),
"Contact Person"=C.ContactPerson,
"Customer Category"= CAT.CategoryName, 
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
"FSSAI No."=C.TNGST,
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
"Credit Term"= Case When CreditTerm = -1 Then 'N/A' Else CT.Description End,
"Credit Limit"= Case When CreditLimit = -1 Then 'N/A' Else Cast(C.CreditLimit as Varchar) End,
"No Of Bills" = Case When NoOfBillsOutstanding = -1 Then 'N/A' Else Cast(NoOfBillsOutstanding as Varchar) End,
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
when 0 Then @CASH
When 1 Then @CHEQUE
When 2 then @CREDIT
When 3 then @DD
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
From Customer C
Left Outer Join Customer_Channel CC On C.ChannelType = CC.ChannelType 
Left Outer Join SubChannel SC On C.SubChannelID = SC.SubChannelID
Left Outer Join Areas A On C.AreaID = a.AreaID
Left Outer Join City CY On C.CityID = CY.CityID 
Left Outer Join District D On C.District = D.DistrictID 
Left Outer Join State S On C.StateId = S.StateId 
Left Outer Join  Country CN On C.CountryId = CN.CountryId
Left Outer Join CreditTerm CT On C.CreditTerm = CT.CreditID
Inner Join CustomerCategory CAT On C.CustomerCategory =CAT.CategoryId  
WHERE C.CustomerId=@CUSTOMER 
End 
