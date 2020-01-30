CREATE procedure Sp_Acc_SaveItemDetails (@PriceListID Int,@ItemID nVarchar(30),
@TaxSuffered Int,@TaxApplicable Int)
as
Insert into PriceListItem (PriceListID,Product_Code,TaxSuffered,TaxApplicable)
Values (@PriceListID,@ItemID,@TaxSuffered,@TaxApplicable)


