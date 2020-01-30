Create Procedure spr_List_CustomerwiseStatutory
As
Begin
-- Report ID - 1431
Declare @RegOwner nVarchar(50)
Select @RegOwner=RegisteredOwner From Setup

Select "CustID"=CustomerID,"OutletID"=@RegOwner+'-'+CustomerID,"Outlet Name"=Company_Name,"Pan Number"=IsNull(PANNumber,''),
"GSTIN"= GSTIN,
"IsRegistered"=Case When IsNull(IsRegistered,0) = 1 Then 'Yes' Else 'No' End,
"Billing State Code"= BillingStateID ,
"Shipping State Code"=ShippingStateID,
"Billing Address"=IsNull(BillingAddress,''),
"Shipping Address"=IsNull(ShippingAddress,'')
From Customer Where Active = 1 And CustomerCategory Not In  (4, 5)

End
