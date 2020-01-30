Create function GetQtyAsMultipleAsInt (@MQuantity nVarchar(255))
returns nvarchar(128)            
as            
Begin         
Declare @Quantity nVarchar(128)
Declare @Temp Decimal(18,6)
Declare MCursor Cursor For Select * From Dbo.Sp_Splitin2Rows(@MQuantity,'*')
Open MCursor
Fetch MCursor InTo @Temp
Set @Quantity = Cast(Cast(@Temp As Int) As nVarchar)
Fetch Next From MCursor InTo @Temp
Set @Quantity = @Quantity + '*' + Cast(Cast(@Temp As Int) As nVarchar)
Fetch Next From MCursor InTo @Temp
Set @Quantity = @Quantity + '*' + Cast(Cast(@Temp As Int) As nVarchar)
Close MCursor
Deallocate MCursor
Return @Quantity
End            
