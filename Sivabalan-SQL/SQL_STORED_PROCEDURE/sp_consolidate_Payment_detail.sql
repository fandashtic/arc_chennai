
CREATE PROCEDURE sp_consolidate_Payment_detail(	@PAYMENTID int,
						@DOCUMENTDATE datetime,
						@PAYMENTDATE datetime,
						@DOCUMENTID int,
						@DOCUMENTTYPE int,
						@ADJUSTEDAMOUNT Decimal(18,6),
						@ORIGINALID nvarchar(50),
						@DOCUMENTVALUE Decimal(18,6),
						@DocumentReference nvarchar(255))
AS
INSERT INTO PaymentDetail(	PaymentID,
				DocumentDate,
				PaymentDate,
				DocumentID,
				DocumentType,
				AdjustedAmount,
				OriginalID,
				DocumentValue,
				DocumentReference)
VALUES(
				@PAYMENTID,
				@DOCUMENTDATE,
				@PAYMENTDATE,
				@DOCUMENTID,
				@DOCUMENTTYPE,
				@ADJUSTEDAMOUNT,
				@ORIGINALID,
				@DOCUMENTVALUE,
				@DocumentReference)

