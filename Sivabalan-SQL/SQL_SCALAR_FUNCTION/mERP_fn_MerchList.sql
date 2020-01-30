CREATE Function [dbo].[mERP_fn_MerchList](@CustID nVarchar(20))
Returns nVarchar(4000)
AS
BEGIN
Declare @count Int
Declare 

@Inc Int
Declare @MerID Int
Declare @MerName nVarchar(256)
Declare @Mer nVarchar(4000)

Declare MerList Cursor For
Select 

MerchandiseID, Merchandise From Merchandise
Where MerchandiseID In (Select MerchandiseID From CustMerchandise
Where 

CustomerID = @CustID)

Set @Inc = 1
Set @Mer  = ''
Select @count = Count(*) From Merchandise
Where MerchandiseID In (Select 

MerchandiseID From CustMerchandise
Where CustomerID = @CustID)

Open MerList
Fetch From MerList Into @MerID, @MerName
While 

@@fetch_status = 0
Begin
--		select @MerID, @MerName

Set @Mer = @Mer + '' + @MerName + ''

If @Inc < @count
Begin
Set @Mer = @Mer	+ ' ' + char(124) + ' '
Set @Inc = @Inc + 1
End

Fetch Next From MerList Into @MerID, @MerName
End
Close MerList
Deallocate MerList

--select char(124)
--select ascii('|')
Return @Mer
End
