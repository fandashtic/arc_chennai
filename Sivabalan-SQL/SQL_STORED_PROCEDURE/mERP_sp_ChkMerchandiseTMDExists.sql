Create Procedure mERP_sp_ChkMerchandiseTMDExists(@CustID nVarchar(500))
As
Begin
	Declare @Merchandise Int
	Declare @TMD Int
	
	If Exists(Select * From CustMerchandise Where CustomerID = @CustID )
		Set @Merchandise = 1

	If Exists(Select  * From Cust_TMD_Details Where CustomerID = @CustID)
		Set @TMD = 1
	
	If 	(@Merchandise = 1  Or @TMD = 1 )
		Select 1
	Else
		Select 0
End

