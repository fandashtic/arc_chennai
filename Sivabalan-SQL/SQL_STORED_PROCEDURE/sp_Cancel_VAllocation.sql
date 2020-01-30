CREATE PROCEDURE sp_Cancel_VAllocation
(         
	@VAllocID Int,
	@UserName nVarChar(50)
)
AS  
Begin

	If (Select Status & 64 From VAllocAbstract Where ID = @VAllocID) = 0
	Begin
		Update VAllocAbstract Set Status = Status | 64 ,CancelUserName = @UserName , CancelDate = GETDATE() Where ID = @VAllocID
		Select 1,"StatusVal" = VAA.Status, "Status" = Case When VAA.Status & 64 <> 0 Then 'Canceled' Else 'Open'  End 
			From  VAllocAbstract VAA Where ID = @VAllocID		
	End
	Else
	Begin
		Select 0,"StatusVal" = VAA.Status, "Status" = Case When VAA.Status & 64 <> 0 Then 'Canceled' Else 'Open'  End 
			From  VAllocAbstract VAA Where ID = @VAllocID	
	End

	
	Select 
	"StatusVal" = VAA.Status,
	"Status" = Case When VAA.Status & 64 <> 0 Then 'Canceled' Else 'Open'  End 
	From  VAllocAbstract VAA Where ID = @VAllocID

End
