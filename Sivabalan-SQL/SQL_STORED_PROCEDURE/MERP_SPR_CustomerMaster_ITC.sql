Create Procedure MERP_SPR_CustomerMaster_ITC
As    

Declare @GOOD NVarchar(50)
Declare @AVERAGE NVarchar(50)
Declare @BAD NVarchar(50)
Declare @BASE NVarchar(50)
Declare @SATELITE NVarchar(50)
Declare @RURAL NVarchar(50)
Declare @URBAN NVarchar(50)
Declare @LOCAL NVarchar(50)
Declare @OUTSTATION NVarchar(50)
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
Set @YES = dbo.LookupDictionaryItem(N'Yes', Default) 

Select Distinct 
C.CustomerId,
"Customer ID" = C.CustomerId,
"Customer Name" = C.Company_Name,
"Contact Person" = C.ContactPerson,
"Customer Category" = CAT.CategoryName, 
"Billing Address" = Replace(Replace(Replace(C.BillingAddress, ',', ''), Char(13), ''), Char(10), ''),
"Shipping Address" = Replace(Replace(Replace(C.ShippingAddress, ',', ''), Char(13), ''), Char(10), ''),
"City" = CY.CityName,
"Country" = CN.Country,
"Area" = A.Area,
"District" = D.DistrictName,
"State" = S.State,
"Phone" = C.Phone,
"EMail" = C.Email,
"DL20" = C.DLNumber,
"DL21" = C.DLNumber21,
"FSSAINo" = C.TNGST,
"CST" = C.CST,
"Credit Limit" = Case When C.CreditLimit = -1 Then 'N/A' Else Cast(C.CreditLimit as Varchar) End,
"Forum Code" = C.AlternateCode,
"Channel Type" = CC.ChannelDesc,
"Beat" = (SELECT Description from Beat where 
	BeatId = C.DefaultBeatID),
"Discount" = C.Discount,
"Credit Rating" = (Case C.CreditRating  
	 When 1 then
	 @GOOD
	 When 2 then
	 @AVERAGE
	 When 3 then
	 @BAD
	 else
	 N'' 
	 end),
"Credit Term" = Case When C.CreditTerm = -1 Then 'N/A' Else CT.Description End,
"Locality" = (case isnull(C.Locality,0) 
	when 1 Then @LOCAL
	when 2 then @OUTSTATION
	else N'' end),
"TIN Number" = C.TIN_Number,
"Alternate Name" = C.Alternate_Name,
"Trade Customer Category" = TCAT.Description,
"NoOfBillsOutstanding" = Case When C.NoOfBillsOutstanding = -1 Then 'N/A' Else Cast(C.NoOfBillsOutstanding as Varchar) End,
"Track points" = (case isnull(C.TrackPoints,0) 
	when 1 then @YES
    else N'' end),
"Collected Points" = C.CollectedPoints,
"Pincode" = C.Pincode,
"Town Classification" = (case isnull(C.TownClassify,0) 
	when 1 Then @BASE
	When 2 Then @SATELITE
	When 3 Then @RURAL
	When 4 Then @URBAN
	else N'' end),
"Sub Channel" = SC.Description,
"RCS ID" = C.RCSOutLetID,
"Zone" = (Select ZoneName From tbl_mERP_Zone zn 
	Where C.ZoneID = zn.ZoneID) ,
"Market District" =  cast(Null as Nvarchar(2000)),
"Sub-District" = cast(Null as Nvarchar(2000)),
"Pop Group" = cast(Null as Nvarchar(2000)),
"Base GOI Market" = cast(Null as Nvarchar(2000)) ,
"Latitude" = isnull((Select Top 1 cast((case When Isnull(Latitude,0) = 0 Then '0.000000' Else Isnull(Latitude,0) End) as Nvarchar(50)) from OutletGeo O where O.CustomerID=C.CustomerID),'0.000000'),
"Longitude" = isnull((Select Top 1 cast((case When Isnull(Longitude,0) = 0 Then '0.000000' Else Isnull(Longitude,0) End) as Nvarchar(50)) from OutletGeo O where O.CustomerID=C.CustomerID),'0.000000') 
Into #Temp
From Customer C
Left Outer Join CustomerCategory CAT On C.CustomerCategory = CAT.CategoryId And C.CustomerCategory = CAT.CategoryId
Left Outer Join TradeCustomerCategory TCAT On C.TradeCategoryID = TCAT.TradeCategoryID
Left Outer Join Customer_Channel CC On C.ChannelType = CC.ChannelType
Left Outer Join SubChannel SC On C.SubChannelID = SC.SubChannelID
Left Outer Join Areas A On C.AreaID = A.AreaID
Left Outer Join City CY On C.CityID = CY.CityID 
Left Outer Join District D On C.District = D.DistrictID 
Left Outer Join State S On C.StateId = S.StateId
Left Outer Join Country CN On C.CountryId = CN.CountryId 
Left Outer Join CreditTerm CT On C.CreditTerm = CT.CreditID 
WHERE C.CustomerCategory Not In (4,5)

Update T Set T.[Base GOI Market] = cast((cast(T1.MarketID as Nvarchar) + '-' + T1.MarketName) as Nvarchar),
T.[Market District] = T1.District, T.[Sub-District] = T1.Sub_District, T.[Pop Group] = T1.Pop_Group
From #Temp T, MarketInfo T1,CustomerMarketInfo T2
Where Ltrim(Rtrim(T.[Customer ID])) = Ltrim(Rtrim(T2.CustomerCode))
And T2.Active = 1
And T1.MMID = T2.MMID
--And T1.Active = 1

select * from #Temp

Drop Table #Temp
