




CREATE procedure sp_acc_loadpaymenttransactions(@accountid integer,@fromdate datetime,@todate datetime,@mode integer,@accountoption integer) 
as
DECLARE @documentid integer
DECLARE @documentdate datetime 
DECLARE @value decimal(18,6)
DECLARE @paymentmode integer
DECLARE @bankid integer
DECLARE @chequenumber integer
DECLARE @chequedate datetime
DECLARE @fulldocid nvarchar(10)
DECLARE @chequeid integer
DECLARE @bankcode integer
DECLARE @branchcode integer
DECLARE @others integer
DECLARE @denominations nvarchar(2000)
DECLARE @paymentcount integer
DECLARE @account nvarchar(30)
DECLARE @status integer



DECLARE @CANCEL integer
DECLARE @VIEW integer
DECLARE @ALLACCOUNTS integer
DECLARE @SPECIFICACCOUNT integer 


SET @CANCEL = 2
SET @VIEW =3
SET @ALLACCOUNTS =1
SET @SPECIFICACCOUNT=2


set dateformat dmy

/*if @mode = @CANCEL 
begin
	if @accountoption = @ALLACCOUNTS  
	begin
		select @documentid = [DocumentID],@documentdate = [DocumentDate],@value= [Value],
		@paymentmode = [PaymentMode],@account = dbo.getaccountname(Others),@fulldocid=[FullDocID],@status = isnull([Status],0) from Payments 
		where dbo.stripdatefromtime([DocumentDate]) between @fromdate and @todate and (isnull(Status,0) & 64)= 0 order by [Others]     
	end
	else if @accountoption = @SPECIFICACCOUNT
	begin
		select @documentid = [DocumentID],@documentdate = [DocumentDate],@value= [Value],
		@paymentmode = [PaymentMode],@account = dbo.getaccountname(Others),@fulldocid=[FullDocID],@status = isnull([Status],0) from Payments where [Others]=@accountid
		and dbo.stripdatefromtime([DocumentDate]) between @fromdate and @todate and (isnull(Status,0) & 64)= 0 order by [Others]    		
	end	
end
else
begin
	if @accountoption = @ALLACCOUNTS 
	begin
		select @documentid = [DocumentID],@documentdate = [DocumentDate],@value= [Value],
		@paymentmode = [PaymentMode],@account = dbo.getaccountname(Others),@fulldocid=[FullDocID],@status = isnull([Status],0) from Payments
		where dbo.stripdatefromtime([DocumentDate]) between @fromdate and @todate order by [Others] 
	end
	else if @accountoption = @SPECIFICACCOUNT
	begin
		select @documentid = [DocumentID],@documentdate = [DocumentDate],@value= [Value],
		@paymentmode = [PaymentMode],@account = dbo.getaccountname(Others),@fulldocid=[FullDocID],@status = isnull([Status],0) from Payments where [Others]=@accountid
		and dbo.stripdatefromtime([DocumentDate]) between @fromdate and @todate order by [Others] 
	end
end


if @@ROWCOUNT > 0 
begin
	select @documentid,@fulldocid,@documentdate,@value,@paymentmode,@status,@account
end
else*/
---begin
	if @mode = @CANCEL 
	begin	
		if @accountoption =@ALLACCOUNTS
		begin
			select [PaymentID],dbo.getfulldocumentid(PaymentID),dbo.stripdatefromtime([PaymentDetail].[DocumentDate]),
			[AdjustedAmount],[Payments].[PaymentMode],isnull([Payments].[Status],0),
			dbo.getaccountname([PaymentDetail].[Others]),[PaymentDetail].[Others] 
			from PaymentDetail,Payments where dbo.stripdatefromtime([PaymentDetail].[DocumentDate]) between @fromdate and @todate
			and isnull([Payments].[VendorID],0)=N'0' and (isnull([Payments].[Status],0) & 64)= 0 
			and [Payments].[DocumentID] = [PaymentDetail].[PaymentID]
			order by [PaymentDetail].[Others]
		end
		else if @accountoption =@SPECIFICACCOUNT
		begin
			select [PaymentID],dbo.getfulldocumentid(PaymentID),dbo.stripdatefromtime([PaymentDetail].[DocumentDate]),
			[AdjustedAmount],[Payments].[PaymentMode],isnull([Payments].[Status],0),dbo.getaccountname([PaymentDetail].[Others]),
			[PaymentDetail].[Others] from PaymentDetail,Payments where [PaymentDetail].[Others]= @accountid 
			and dbo.stripdatefromtime([PaymentDetail].[DocumentDate]) between @fromdate and @todate 
			and (isnull([Payments].[Status],0) & 64)= 0 and [Payments].[DocumentID] = [PaymentDetail].[PaymentID] 
			order by [PaymentDetail].[Others]
		end
	end
	else
	begin
		if @accountoption =@ALLACCOUNTS
		begin
			select [PaymentID],dbo.getfulldocumentid(PaymentID),dbo.stripdatefromtime([PaymentDetail].[DocumentDate]),
			[AdjustedAmount],[Payments].[PaymentMode],isnull([Payments].[Status],0),
			dbo.getaccountname([PaymentDetail].[Others]),[PaymentDetail].[Others] 
			from PaymentDetail,Payments where dbo.stripdatefromtime([PaymentDetail].[DocumentDate]) between @fromdate and @todate 
			and isnull([Payments].[VendorID],0)=N'0' and [Payments].[DocumentID] = [PaymentDetail].[PaymentID]
			order by [PaymentDetail].[Others]
		end
		else if @accountoption = @SPECIFICACCOUNT
		begin
			select [PaymentID],dbo.getfulldocumentid(PaymentID),dbo.stripdatefromtime([PaymentDetail].[DocumentDate]),
			[AdjustedAmount],[Payments].[PaymentMode],isnull([Payments].[Status],0),dbo.getaccountname([PaymentDetail].[Others]),
			[PaymentDetail].[Others] from PaymentDetail,Payments where [PaymentDetail].[Others]= @accountid 
			and dbo.stripdatefromtime([PaymentDetail].[DocumentDate]) between @fromdate and @todate 
			and [Payments].[DocumentID] = [PaymentDetail].[PaymentID] order by [PaymentDetail].[Others]
		end
	end
---end












