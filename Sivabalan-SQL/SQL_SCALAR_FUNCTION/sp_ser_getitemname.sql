CREATE function sp_ser_getitemname(@ItemCode nvarchar(15))
Returns Varchar(255)
as
Begin
Declare @ItemName nvarchar(255)
Select @ItemName = ProductName from Items
where Product_Code = @ItemCode
return @ItemName 
End


