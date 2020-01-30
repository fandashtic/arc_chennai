CREATE Procedure sp_acc_Insert_ReceivedPriceListItemDetails(@ReceiveDocID Int, @ForumCode	VarChar(50), 
@PTS Decimal(18,6), @PTR Decimal(18,6), @ECP Decimal(18,6), @PurchasePrice Decimal(18,6),
@SalePrice Decimal(18,6),@MRP Decimal(18,6),@SpecialPrice Decimal(18,6), @TaxSuffered Int,@TaxApplicable Int)
As
Insert Into ReceivePriceListItemDetail(ReceiveDocID, ForumCode, PTS, PTR, ECP, PurchasePrice, 
SalePrice, MRP, SpecialPrice, TaxSuffered, TaxApplicable)
Values (@ReceiveDocID, @ForumCode, @PTS, @PTR, @ECP, @PurchasePrice, @SalePrice, 
@MRP, @SpecialPrice, @TaxSuffered, @TaxApplicable)

