Create Procedure mERP_sp_GetEditMarginConfig(@CompanyID NVarchar(255))
AS
Begin
	Declare @UserName nVarchar(50)
	Declare @Password nVarchar(50)
    Declare @RecCount Int
    Select @RecCount = Count(*) From Users Where Active=1 and GroupName ='Administrator' and UserName like '%MERP'

	If (Select isNull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'EDTMAR01') = 1
	Begin
        If IsNull(@RecCount,0) = 1 
          Select top 1 @UserName = UserName From Users Where GroupName = N'Administrator' And UserName like '%MERP'
        Else
            Select top 1 @UserName = UserName From Users Where GroupName = N'Administrator' And UserName like '%ad'

		SELECT @Password = Password FROM ForumMessageClient.dbo.R1ATH_Client_Cfg_Details WHERE CompanyID = @CompanyID AND UserID = @UserName
		Select 1,(Select isNull(Value,3) From tbl_mERP_ConfigDetail Where ScreenCode = 'EDTMAR01'),@UserName,@Password
	End
	Else
	Begin
		Select 0,0,'',''
	End

End
