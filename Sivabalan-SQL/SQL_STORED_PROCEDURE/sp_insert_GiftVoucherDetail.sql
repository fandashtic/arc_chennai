CREATE procedure sp_insert_GiftVoucherDetail(@VoucherID Int,
		@SequenceNumber nvarchar(250),@Amount Decimal(18,6),
		@IssueDate DateTime,@ExpiryDate DateTime,
		@AmountReceived Decimal(18,6),@AmountRedeemed Decimal(18,6),
		@Status Int,@CustomerID nvarchar(50))
As
		Insert into GiftVoucherDetail(VoucherID,
								   	  SequenceNumber,Amount,
									  IssueDate,ExpiryDate,
									  AmountReceived,AmountRedeemed,
									  Status,CustomerID)				
							   Values(@VoucherID,
								   	  @SequenceNumber,@Amount,
									  @IssueDate,@ExpiryDate,
									  @AmountReceived,@AmountRedeemed,
									  @Status,@CustomerID)


