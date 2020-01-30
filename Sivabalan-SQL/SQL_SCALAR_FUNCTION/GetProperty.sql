CREATE Function GetProperty (@ItemCode nvarchar(20), @NProperty decimal(18,6))
Returns nvarchar(255)
As
Begin
Declare @Property nvarchar(255)
Declare @PropertyCache nvarchar(255)
Declare @PropertyID int

DECLARE FetchProperty CURSOR STATIC FOR
Select Value From Item_Properties Where Product_Code = @ItemCode

Set @PropertyID = 1
Open FetchProperty
Fetch From FetchProperty into @PropertyCache
While @@Fetch_Status  = 0
Begin
	IF @PropertyID = @NProperty 
	begin
		SET @Property = @PropertyCache
		Goto FetchProperty2
	end
	Set @PropertyID = @PropertyID + 1
	Fetch Next From FetchProperty into @PropertyCache
End
FetchProperty2:
Close FetchProperty
DeAllocate FetchProperty
Return @Property
End
