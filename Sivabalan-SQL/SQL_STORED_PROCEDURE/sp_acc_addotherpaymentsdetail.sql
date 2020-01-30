CREATE procedure sp_acc_addotherpaymentsdetail(@paymentid int,@documentid int,
@documenttype int,@documentdate datetime,@paymentdate datetime,@adjustedamount decimal(18,6),
@originalid nvarchar(20),@documentvalue decimal(18,6),@extracol decimal(18,6),
@adjustment decimal(18,6),@mode int,@transactionid int,@documentreference nvarchar(50))
as
Declare @DIRECT int
Declare @INDIRECT int

set @DIRECT =1
set @INDIRECT=2

insert PaymentDetail (PaymentID,
		      DocumentID,
		      DocumentType,
		      DocumentDate,
		      PaymentDate,		 		
		      AdjustedAmount, 
		      OriginalID,
		      DocumentValue,
		      ExtraCol,
		      Adjustment,
		      DocumentReference)
		
               values(@paymentid,
		      @documentid,
		      @documenttype,
		      @documentdate,
		      @paymentdate,
		      @adjustedamount,
                      @originalid,
                      @documentvalue,
                      @extracol,
                      @adjustment,
		      @documentreference)
if @mode = @DIRECT 
begin
	update Payments
	set Balance = Balance  - @adjustedamount
	where DocumentID = @transactionid
end


