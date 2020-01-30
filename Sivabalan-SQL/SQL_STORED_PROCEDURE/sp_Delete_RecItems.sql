Create Procedure sp_Delete_RecItems (@ID int)
As
Declare @CntItems Int
Declare @PartyID Int

Update ItemsReceivedDetail Set Flag = 32 Where ID = @ID
Select @CntItems = Count(Product_Code)
From ItemsReceivedDetail Where
IsNull(Flag, 0) & 32 = 0 And
PartyID = (Select PartyID From ItemsReceivedDetail Where ID = @ID)
Group By PartyID
If IsNull(@CntItems, 0) = 0
Begin
	Select @PartyID = PartyID From ItemsReceivedDetail Where ID = @ID
	Update ItemsReceivedAbstract Set Flag = 32 Where ID = @PartyID
End
