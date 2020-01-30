Create Procedure spr_List_CustomerwisePincode
As
Begin

	Declare @RegOwner nVarchar(50)
	Select @RegOwner=RegisteredOwner From Setup

	Select "CustID"=CustomerID,"OutletID"=@RegOwner+'-'+CustomerID,"Outlet Name"=Company_Name,"Pincode"=IsNull(Pincode,'')	
	From Customer Where Active = 1 And CustomerCategory Not In  (4, 5)

End
