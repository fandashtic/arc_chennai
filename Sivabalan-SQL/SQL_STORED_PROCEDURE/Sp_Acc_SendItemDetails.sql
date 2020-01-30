CREATE Procedure Sp_Acc_SendItemDetails
(@Mode Int,@DocumentID Int,@Product_Code nvarchar(50),
@TaxSuffered Int,@TaxApplicable Int,@PTS Decimal(18,6),
@PTR Decimal(18,6),@ECP Decimal(18,6),@PurchasePrice Decimal(18,6),
@SellingPrice Decimal(18,6),@MRP Decimal(18,6),@SpecialPrice  Decimal(18,6))
as    
if @Mode = 0
Begin
	Insert into SendPriceListItem
 	(DocumentID ,Product_Code ,TaxSuffered ,TaxApplicable ,
	PTS ,PTR ,ECP ,PurchasePrice ,SellingPrice ,MRP ,SpecialPrice)
	Values (@DocumentID,@Product_Code,@TaxSuffered,@TaxApplicable,
	@PTS,@PTR,@ECP,@PurchasePrice,@SellingPrice,@MRP,@SpecialPrice)
End
Else if @Mode = 1
Begin
	Update SendPriceListItem
	set 
	PTS = @PTS,
	PTR = @PTR,
	ECP = @ECP,
	PurchasePrice = @PurchasePrice,
	SellingPrice = @SellingPrice,
	MRP = @MRP,
	SpecialPrice = @SpecialPrice
	Where 
	DocumentID = @DocumentID And
	Product_Code = @Product_Code
End	

