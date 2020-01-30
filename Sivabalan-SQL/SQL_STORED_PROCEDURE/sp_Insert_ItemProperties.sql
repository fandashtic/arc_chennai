Create Procedure sp_Insert_ItemProperties(@ID int, @ItemCode nvarchar(255))
As
	Declare @PCode as nvarchar(255)
	Declare @PID as int
	Declare @Value as nvarchar(255)
	DELETE Item_Properties WHERE Product_Code = @ItemCode

	Declare ItemProperties Cursor for
	Select ItemsReceivedDetail.Product_Code,Properties.PropertyID,ItemPropReceived.PropertyValue 
	From ItemPropReceived, Properties,ItemsReceivedDetail 
	Where ItemPropReceived.PropertyName = Properties.Property_Name And ItemID = @ID And ItemsReceivedDetail.ID = @ID
	Open ItemProperties
	Fetch Next from ItemProperties into @PCode, @PID, @Value
	While @@Fetch_Status = 0
	Begin
		Delete From Item_Properties where Product_Code = @PCode and PropertyID = @PID
		Insert Into Item_Properties(Product_Code, PropertyID, Value)
        Values(@PCode, @PID, @Value)
		Fetch Next from ItemProperties into @PCode, @PID, @Value
	End
	Close ItemProperties
	Deallocate ItemProperties
