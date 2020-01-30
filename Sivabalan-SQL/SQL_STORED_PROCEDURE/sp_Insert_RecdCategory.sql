Create Procedure sp_Insert_RecdCategory (@CategoryName nvarchar(255),
					 @Description nvarchar(255),
					 @Parent nvarchar(255),
					 @TrackInventory Int,
					 @PriceOption Int,
					 @Level Int,
					 @CreationDate Datetime,
					 @ModifiedDate Datetime,
					 @PropertyCount Int)
As
Insert Into CategoryReceived (CategoryName, Description, Parent, TrackInventory, PriceOption,
Level, CreationDate, ModifiedDate, PropertyCount) 
Values (@CategoryName, @Description, @Parent, @TrackInventory, @PriceOption, @Level,
@CreationDate, @ModifiedDate, @PropertyCount)
Select @@Identity
