CREATE procedure sp_acc_updatecollectiondetail(	@CollectionID integer,
						@DocumentID integer,
						@DocumentType integer,
						@DocumentDate datetime,
						@PaymentDate datetime,
						@AdjustedAmount float, 
						@OriginalID nVarchar(128),
						@DocumentValue float)
as
insert into CollectionDetail(	
				CollectionID,
				DocumentID,
				DocumentType,
				DocumentDate,
				PaymentDate,
				AdjustedAmount,
				OriginalID,
				DocumentValue)
values
				(@CollectionID,
				@DocumentID,
				@DocumentType,
				@DocumentDate,
				@PaymentDate,
				@AdjustedAmount,
				@OriginalID,
				@DocumentValue)

Select @@RowCount 




