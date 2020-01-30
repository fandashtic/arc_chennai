CREATE Procedure sp_acc_SendPriceListItemDetails(@DocumentID As Int)
As
Select 'ItemAlias'=(Select Alias from Items Where Items.Product_Code = SendPriceListItem.Product_Code),
'PTS'=PTS, 'PTR'=PTR, 'ECP'=ECP, 'PurchasePrice'=PurchasePrice,
'SellingPrice'=SellingPrice, 'MRP'=MRP, 'SpecialPrice'=SpecialPrice,
'PurTaxID'=IsNULL(TaxSuffered,0), 'SalTaxID'=IsNULL(TaxApplicable,0)
from SendPriceListItem Where DocumentID = @DocumentID


