CREATE procedure sp_insert_TradeCustomerCategory(@TradeCustCatDesc nVarchar(255))
As
Declare @TradeCatID Int
Select @TradeCatID=TradeCategoryID From TradeCustomerCategory Where Description=@TradeCustCatDesc
If @TradeCatID >0 
	Select @TradeCatID
Else
	Begin
		Insert Into TradeCustomerCategory (Description) Values (@TradeCustCatDesc)
		Select Max(TradeCategoryId) From TradeCustomerCategory
	End


