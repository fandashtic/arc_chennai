


CREATE procedure sp_acc_pettycashpaymentdetail(@paymentid integer,@documentdate datetime,
						 @paymentdate datetime,@adjustedamount decimal(18,6),
						 @documentvalue decimal(18,6),@others integer)
as
DECLARE @documentid integer
DECLARE @DOCUMENTTYPE integer

SET @DOCUMENTTYPE = 0

insert into PaymentDetail(PaymentID,
		DocumentID,
		DocumentDate,
		PaymentDate,
		DocumentType,
		AdjustedAmount,
		DocumentValue,
		Others)

values		(@paymentid,
		0,
		@documentdate,
		@paymentdate,
		@DOCUMENTTYPE,
		@adjustedamount,
		@documentvalue,
		@others)





