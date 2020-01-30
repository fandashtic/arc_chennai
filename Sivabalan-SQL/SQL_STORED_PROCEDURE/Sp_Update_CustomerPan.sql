Create procedure Sp_Update_CustomerPan
(
 @CustomerID nvarchar(15),
 @PanNo      nvarchar(100),
 @BStateID Int = 0,
 @SStateID Int = 0,
 @GSTIN nVarChar(15) = N'',
 @IsRegistered int = 0 ,
 @BillingAddress nVarchar(500),
 @ShippingAddress nVarchar(500)
)
As
Begin

Declare @StateID as int
Declare @CityID as int
Declare @NewStateID as int
Declare @BillingState nvarchar(255)

  Update customer set PANNumber=@PanNo, 
  BillingStateID = @BStateID, ShippingStateID = @SStateID, GSTIN = @GSTIN,[IsRegistered] = @IsRegistered  
  where CustomerID=@CustomerID
  If @BillingAddress <> '' 
	  Update customer set BillingAddress = @BillingAddress where CustomerID=@CustomerID
  If @ShippingAddress <> '' 
	  Update customer set ShippingAddress = @ShippingAddress where CustomerID=@CustomerID 	

If Exists(Select isnull(Flag,0) from tbl_mERP_ConfigAbstract where ScreenCode ='GSTaxEnabled' and ISNULL(Flag ,0) = 1)
Begin
		
		Select @BillingState = ForumStateCode + '-' + StateName From StateCode Where StateID = @BStateID		
		
		If IsNull(@BillingState,'') <> ''
		Begin
			If Exists (select StateID from State where State = @BillingState)
			Begin
				select Top 1 @NewStateID =  StateID from state where State = @BillingState			
			End
			Else
			Begin
				INSERT INTO [State] ( [State]) VALUES (@BillingState)
				select @NewStateID = @@identity
			End			
			
			Select Distinct @CityID =  CityID  from Customer where CustomerID  = @CustomerID
			
			IF @NewStateID > 0 
			Begin
				Update Customer Set StateID = @NewStateID where CustomerID=@CustomerID
				Update City set StateID = @NewStateID where CityID = @CityID
			End			
		End
End


End
