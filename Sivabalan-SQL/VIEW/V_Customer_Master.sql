Create VIEW  [V_Customer_Master]  
([Customer_ID],[Customer_Name],[Channel_Type],[Customer_Category],[Sub_Channel],[Phone_Number],[Email],
	[Default_Payment_Mode],[Contact_Person],  
	[Billing_Address],[Shipping_Address],[DefaultBeat],[Area],[CG_CreditLimit_YN],[Credit_Term],
	[Credit_Limit],[No_of_Open_Invoices],[Creation_Date],[Modified_Date],[Active],[TrackPoints],[BalancePoints], 
	[MobileNo], [SMSAlert], [Latitude], [Longitude],[Channel_Type_Desc],[Outlet_Type_Desc],[Loyalty_Program_Desc] 
)  
AS
SELECT distinct cus.CustomerID,  
Company_Name,  
ChannelType,  
CustomerCategory,  
SubChannelID,  
Phone,  
Email,  
Payment_Mode,  
ContactPerson,  
BillingAddress,  
ShippingAddress,  
DefaultBeatID,  
AreaID,   
"CG_CreditLimit_YN"= case when (Select count(*) from CustomerCreditLimit 
	where CustomerID=cus.CustomerID and CreditLimit > 0 ) = 0 Then 2 else 1 End,  
CreditTerm,  
cus.CreditLimit,  
NoOFBillsOutstanding,  
cus.CreationDate,  
cus.Modifieddate,  
cus.Active,  
TrackPoints,  
CollectedPoints, 
MobileNumber, 
Case When IsNull(SMSAlert, 0) = 0 Then 'No' Else 'Yes' End, 
geo.Latitude, 
geo.Longitude,
olc.Channel_Type_desc, olc.Outlet_Type_Desc, olc.SubOutlet_type_desc as Loyalty_Program_Desc
 FROM  Customer cus Left Outer Join OutletGeo geo on geo.CustomerID = cus.CustomerID 
 Left Outer Join CustomerCreditLimit On cus.Customerid = CustomerCreditLimit.CustomerID  
 left outer join tbl_mERP_OLClassMapping map on map.CustomerID = cus.CustomerID and map.active=1
 left outer join tbl_mERP_OLClass olc on olc.id=map.OLClassID 
