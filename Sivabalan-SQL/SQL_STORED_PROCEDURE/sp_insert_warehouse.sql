CREATE Procedure [dbo].[sp_insert_warehouse]( @Warehouseid nvarchar(25), @WareHouse_Name nvarchar (50), 
	@Address nvarchar(255), @City int, @State int, @Country int, @ForumID nvarchar(20), @TINNUMBER nvarchar(20) = N'',
	 @BStateID Int = 0, @GSTIN nVarChar(15) = N'')
AS
Begin

Declare @NewStateID as int
Declare @BillingState nvarchar(255)

If Exists(Select isnull(Flag,0) from tbl_mERP_ConfigAbstract where ScreenCode ='GSTaxEnabled' and ISNULL(Flag ,0) = 1)
Begin
	IF IsNull(@BStateID,0) > 0
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
			
			Set @State = @NewStateID
			
		End				
	End
End     
Else
Begin
	if IsNull(@City,0) > 0
	Begin
		Select Top 1 @NewStateID = StateID from City Where CityID = @City
		Set @State = @NewStateID
	End
End



	Insert into warehouse (Warehouseid , warehouse_name, address, city, state, country, forumid,active,
	TIN_Number,[BillingStateID], [GSTIN]) 
	Values (@WareHouseID , @WareHouse_Name , @Address , @City  , @State  , @Country , @ForumID , 1,
	@TINNUMBER, @BStateID ,@GSTIN)
End
