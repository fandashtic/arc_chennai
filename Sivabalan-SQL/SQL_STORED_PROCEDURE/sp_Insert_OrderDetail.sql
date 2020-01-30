Create Procedure sp_Insert_OrderDetail
						(@DocSerial Integer, @Product_Code nvarchar(20),
						 @Serial Int)
As

Insert into OrderDetail (DocSerial, Product_Code, Serial)
	Values(@DocSerial, @Product_Code, @Serial)

