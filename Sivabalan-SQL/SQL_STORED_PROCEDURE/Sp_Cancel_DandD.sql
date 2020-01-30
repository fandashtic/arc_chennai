Create Procedure Sp_Cancel_DandD @ID Int,@UserName nvarchar(256)=''
AS
Begin
	Set dateformat dmy	
	Declare @ClaimID int
	Declare @CurrentDate datetime
	set @CurrentDate=getdate()
	Update DandDAbstract Set Status = 192, ClaimStatus = 192, CancelUser = @UserName, CancelDate = GetDate()  Where ID = @ID
	Select @ClaimID=ClaimId from DandDAbstract where ID=@ID
	If exists(select 'x' from claimsdetail where claimid=@ClaimID)
	BEGIN
		exec sp_cancel_Claims @ClaimID,'',@UserName,@CurrentDate
	END
	Select 1
End

