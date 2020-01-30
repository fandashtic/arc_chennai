




CREATE procedure sp_acc_insert_Receiptdetail(	@CollectionID integer,
						@DocumentDate datetime,
						@PaymentDate datetime,
						@AdjustedAmount float, 
						@DocumentValue float,
						@Others Integer)
as
insert into CollectionDetail(	
				CollectionID,
				DocumentDate,
				PaymentDate,
				AdjustedAmount,
				DocumentValue,
				Others)
values
				(@CollectionID,
				@DocumentDate,
				@PaymentDate,
				@AdjustedAmount,
				@DocumentValue,
				@Others)








