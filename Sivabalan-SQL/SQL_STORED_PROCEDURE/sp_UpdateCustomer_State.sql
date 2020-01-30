CREATE PROCEDURE [dbo].[sp_UpdateCustomer_State](@CustomerID [nvarchar](15),@BillingState nvarchar(255))
AS 
Begin
    Declare @StateID as int
    Declare @CityID as int
    If Exists(Select isnull(Flag,0) from tbl_mERP_ConfigAbstract where ScreenCode ='GSTaxEnabled' and ISNULL(Flag ,0) = 1)
    Begin
		If @BillingState <> ''
		Begin
			If Exists (select StateID from State where State = @BillingState)
			Begin
				select distinct @StateID =  StateID from state where State = @BillingState
				select @StateID
			end
			else
			begin
				INSERT INTO [State] ( [State]) VALUES (@BillingState)
				select @StateID = @@identity
			end
			
			Update Customer set StateID = @StateID where CustomerID  = @CustomerID
			
			select distinct @CityID =  CityID  from Customer where CustomerID  = @CustomerID
			
			Update City set StateID = @StateID where CityID = @CityID
		End
	End
	
End
