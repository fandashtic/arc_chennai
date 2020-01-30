Create Function dbo.GetlastProperty (@Product_Code Nvarchar(255),@PropertyId Int)
Returns @Value Table(Product_Code Nvarchar(255),PropertyId Int,Data Nvarchar(Max))
As
Begin
	Insert Into @Value
	Select Top 1 @Product_Code,@PropertyId,Value From Item_Properties Where Product_Code = @Product_Code and PropertyId = @PropertyId Order By CreationDate Desc
Return 
End
