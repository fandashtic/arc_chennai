CREATE procedure sp_acc_insert_arvdetail(@DocumentID Int,
					 @Type integer,
					 @AccountID Int,
					 @Value float,
					 @Particular ntext,
					 @TaxPercentage float,
					 @TaxAmount float,
					 @SCAmount float)

as

insert into ARVDetail(DocumentID,
		      Type,
		      AccountID,
		      Amount,
		      Particular,
		      TaxPercentage,
		      TaxAmount,
		      ServiceChargeAmount)

values
		       (@DocumentID,
			@Type,
			@AccountID,
			@Value,
			@Particular,
			@TaxPercentage,
			@TaxAmount,
		        @SCAmount)

