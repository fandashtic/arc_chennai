CREATE Procedure [dbo].[sp_modify_warehouse] (@WareHouseID nvarchar(25), @WareHouse_Name nvarchar (50), @Address nvarchar(255), @City int, @State int, @Country int, @ForumID nvarchar(20), @Active int, @TINNUMBER nvarchar(20) = N'', 
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

	
	update stocktransferoutabstractreceived set warehouseid = @WareHouseID where docserial in ( select docserial from stocktransferoutabstractreceived where forumcode = @ForumID )
	update warehouse set  address = @address , city = @City , state = @state,
	country = @country , forumid = @forumid ,active = @active, TIN_Number = @TINNUMBER,
	[BillingStateID]=@BStateID , [GSTIN] = @GSTIN 
	where warehouseid = @warehouseid
End
