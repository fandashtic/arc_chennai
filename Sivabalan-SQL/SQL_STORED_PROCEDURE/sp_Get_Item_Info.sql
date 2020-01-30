CREATE Procedure sp_Get_Item_Info (@ID Int)
As
Declare @RecCount Int
Declare @flag int

If exists (Select Product_Code From Items Where Product_Code In
(Select Product_Code From ItemsReceivedDetail Where ID = @ID) And
ProductName In (Select ProductName From ItemsReceivedDetail Where ID = @ID))
Begin
	Select @RecCount=Count(Product_Code) From Items Where Product_Code In 
	(Select Product_Code From ItemsReceivedDetail Where ID = @ID) And
	ProductName In (Select ProductName From ItemsReceivedDetail Where ID = @ID)
	IF(@RecCount)=1		
		sELECT @FLAG=1
	Else
		sELECT @FLAG=5 ---No Case
End
Else If exists (Select Product_Code From Items Where Product_Code In 
(Select Product_Code From ItemsReceivedDetail Where ID = @ID) And 
ProductName Not In (Select ProductName From ItemsReceivedDetail Where ID = @ID))	
Begin
	Select @RecCount=Count(Product_Code) From Items Where Product_Code In 
	(Select Product_Code From ItemsReceivedDetail Where ID = @ID) OR
	ProductName In (Select ProductName From ItemsReceivedDetail Where ID = @ID)
	IF(@RecCount)=1	
		Select @fLAG=2    ---Received ProductCode to be Replaced by Received productname And Add as new item.
	Else
		Select @fLAG=5		---No Case
End
Else If exists (Select Product_Code From Items Where Product_Code Not In 
(Select Product_Code From ItemsReceivedDetail Where ID = @ID) And 
ProductName In (Select ProductName From ItemsReceivedDetail Where ID = @ID))
BEgin
	Select @RecCount=Count(Product_Code) From Items Where Product_Code In 
	(Select Product_Code From ItemsReceivedDetail Where ID = @ID) OR
	ProductName In (Select ProductName From ItemsReceivedDetail Where ID = @ID)
	IF(@RecCount)=1	
		Select @Flag=3 ---Received ProductName to be Replaced by Received productCode And Add as new item.
	Else
		Select @Flag=5 ---No Case
End
Else
Begin
	If exists (Select Alias From Items Where Alias In 
	(Select ForumCode From ItemsReceivedDetail Where ID = @ID))
		Select @Flag=4
	Else
		Select @Flag=0
End

If(@Flag <> 5)
Begin
	If exists (Select * From Items, ItemsReceivedDetail IRD  
				Where Items.Alias  = IRD.ForumCode 
					and IRD.ID = @ID
					and Items.Product_Code <> IRD.Product_Code 
					and IRD.Product_Code = IRD.ForumCode)
			Select @Flag = 5
End		

Select @Flag

