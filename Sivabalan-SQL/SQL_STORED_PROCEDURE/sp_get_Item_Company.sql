CREATE Procedure sp_get_Item_Company
As
Select Case IsNull(ItemsReceivedAbstract.PartyName, N'')
When N'' Then
ItemsReceivedAbstract.ForumCode
Else
ItemsReceivedAbstract.PartyName
End,
"Count Of Items" = (Select Count(Product_Code)
From ItemsReceivedDetail
Where PartyID In (Select A.ID From ItemsReceivedAbstract as A 
Where A.ForumCode = ItemsReceivedAbstract.ForumCode) And
IsNull(Flag, 0) & 32 = 0),
ItemsReceivedAbstract.ForumCode 
From ItemsReceivedAbstract
Where IsNull(Flag, 0) & 32 = 0
Group By ItemsReceivedAbstract.ForumCode, ItemsReceivedAbstract.PartyName
