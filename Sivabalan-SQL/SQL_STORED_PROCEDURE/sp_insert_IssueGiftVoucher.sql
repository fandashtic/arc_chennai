CREATE procedure sp_insert_IssueGiftVoucher(@SerialNo Int, @CollectionID nvarchar(50),@CollectioDate DateTime,
								  @ModeOfPayment Int,@CollectedAmount Decimal(18,6))
As
		Insert into IssueGiftVoucher(SerialNo,CollectionID,CollectionDate,
									 ModeOfPayment,CollectedAmount,Status
									 )
							  Values(@SerialNo,@CollectionID,@CollectioDate,
									 @ModeOfPayment,@CollectedAmount,0
									 )
					


