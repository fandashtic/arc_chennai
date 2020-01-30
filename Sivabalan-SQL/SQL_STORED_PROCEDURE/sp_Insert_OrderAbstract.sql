CREATE Procedure sp_Insert_OrderAbstract
						(@OrderName nvarchar(200), @Description nvarchar(255),
						 @CreationDate DateTime)
As

Insert into OrderAbstract (OrderName, [Description], CreationDate)
	Values(@OrderName, @Description, @CreationDate)

Select @@IDENTITY

