Create Procedure sp_UpdateItemDetails(@ItemID Int,@Type Int)
As
Declare @ForumCode nvarchar(255)
Declare @ItemCode nvarchar(30)
Declare @ItemName nvarchar(255)


IF (@Type=2) --Product Name Is NEw But Product_Code Already Exists
	Update Items Set ProductName=(Select ProductName From ItemsReceivedDetail 
	Where ID=@ItemID) Where Product_Code =(Select Product_Code From ItemsReceivedDetail 
	Where ID=@ItemID)
Else IF (@Type=3) --Product Code Is NEw But ProductName Already Exists
	Update ItemsReceivedDetail Set ProductName=Product_Code Where ID=@ItemID
Else IF (@Type=4) --ForumCode AlreadyExists
	Update ItemsReceivedDetail Set ForumCode=Product_Code Where ID=@ItemID


Select @ForumCode = ForumCode, @ItemCode = Product_Code
From ItemsReceivedDetail Where ID = @ItemID

IF exists(Select Product_Code from Items Where Product_Code <> @ItemCode and Alias =
	@FORUMCODE)
Begin
	Update ItemsReceivedDetail Set ForumCode=Product_Code Where ID=@ItemID
End



