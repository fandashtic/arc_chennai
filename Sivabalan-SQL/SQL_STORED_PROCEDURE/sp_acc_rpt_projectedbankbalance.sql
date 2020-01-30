CREATE Procedure sp_acc_rpt_projectedbankbalance(@PostDate dateTime,@BankAccountID Int)    
As    
Declare @LastBalance as Decimal(18,6)    
Declare @BankBalance as Decimal(18,6)    
Declare @ChequeinHand as Decimal(18,6)    
Declare @PDChequeinHand as Decimal(18,6)    
Declare @PDChequeIssued as Decimal(18,6)    
Declare @ChequeinHand2 as Decimal(18,6)    
Declare @PDChequeinHand2 as Decimal(18,6)    
Declare @PDChequeIssued2 as Decimal(18,6)    
Declare @Currentdate as DateTime  
Declare @CurrentDatePair as datetime, @PostDatePair as Datetime, @MaxPostDatedPair as DateTime    
Declare @MaxPostDated as DateTime  
Set @Currentdate=dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))    
Set @CurrentDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @Currentdate))  
Set @PostDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @Postdate))    
    
If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@CurrentDate and AccountID =@BankAccountID)    
Begin    
 Select @LastBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId =@BankAccountID --and isnull(Active,0)=1    
End    
Else    
Begin     
 set @LastBalance= isnull((Select OpeningValue from AccountOpeningBalance where OpeningDate=@CurrentDate and AccountID=@BankAccountID),0)    
End    
set @BankBalance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal     
where [TransactionDate] between @CurrentDate and @CurrentDatePair and AccountID=@BankAccountID    
and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)),0)    
set @BankBalance=@BankBalance + @LastBalance    
    
Set @ChequeinHand=isnull((Select sum(Value) from collections     
where (chequeDate <= @CurrentDatePair)    
and (isnull(DepositID,0)=0) and PaymentMode>0  and (isnull(Status,0) & 64) = 0),0)    
    
Set @PDChequeinHand=isnull((Select sum(Value) from collections     
where (chequeDate between dateadd(day,1,@CurrentDate) and @PostDatePair)    
and (isnull(DepositID,0)=0) and PaymentMode>0  and (isnull(Status,0) & 64) = 0),0)    
    
Set @PDChequeIssued=isnull((Select sum(Value) from Payments     
where (cheque_Date between dateadd(day,1,@CurrentDate) and @PostDatePair) and    
PaymentMode>0 and BankID=(Select BankID from Bank where AccountID=@BankAccountID)  and (isnull(Status,0) & 64) = 0),0)    
    
Create Table #Temp(FromDate DateTime,ToDate DateTime,PostDate DateTime,CurrentBalance Decimal(18,6),    
ChequeinHand Decimal(18,6),PDChequeinHand Decimal(18,6),PDChequeIssued Decimal(18,6),ProjectedBalance Decimal(18,6),HighLight Int)    
    
Insert into #Temp    
Select @CurrentDate,@PostDate,@PostDate,@BankBalance,@ChequeinHand,@PDChequeinHand,@PDChequeIssued,    
(@BankBalance + (@ChequeinHand+@PDChequeinHand-@PDChequeIssued)),6    
    
Set @MaxPostDated=(Select Max(Cheque_Date) from Payments where     
Cheque_Date > @CurrentDatePair and (isnull(Status,0) & 64) = 0)    
Set @MaxPostDatedPair = DateAdd(s, 0-1, DateAdd(dd, 1, @MaxPostDated))  
If dbo.stripdatefromtime(@MaxPostDated) > @PostDatePair    
Begin    
     
 /*Set @ChequeinHand2=isnull((Select sum(Value) from collections     
 where (dbo.stripdatefromtime(chequeDate) between @PostDate and dbo.stripdatefromtime(@MaxPostDated))    
 and isnull(DepositID,0)=0 and PaymentMode>0 and ((Status & 192) <> 192)),0)    
 Set @ChequeIssued2=isnull((Select sum(Value) from Payments     
 where (dbo.stripdatefromtime(cheque_Date) between @PostDate and dbo.stripdatefromtime(@MaxPostDated))    
 and PaymentMode>0 and BankID=(Select BankID from Bank where AccountID=@BankAccountID) and ((Status & 192) <> 192)),0)    
 */    
 Set @ChequeinHand2=isnull((Select sum(Value) from collections     
 where (chequeDate <= @CurrentDatePair)    
 and (isnull(DepositID,0)=0) and PaymentMode>0  and (isnull(Status,0) & 64) = 0),0)    
 Set @PDChequeinHand2=isnull((Select sum(Value) from collections     
 where (chequeDate between dateadd(day,1,@CurrentDate) and @MaxPostDatedPair)    
 and isnull(DepositID,0)=0 and PaymentMode>0 and (isnull(Status,0) & 64) = 0),0)    
 Set @PDChequeIssued2=isnull((Select sum(Value) from Payments     
 where (cheque_Date between dateadd(day,1,@CurrentDate) and @MaxPostDatedPair)    
 and PaymentMode>0 and BankID=(Select BankID from Bank where AccountID=@BankAccountID) and (isnull(Status,0) & 64) = 0),0)    
 Insert into #Temp    
 Select @CurrentDate,dbo.stripdatefromtime(@MaxPostDated),@PostDate,@BankBalance,@ChequeinHand2,@PDChequeinHand2,@PDChequeIssued2,    
 (@BankBalance + (@ChequeinHand2+@PDChequeinHand2-@PDChequeIssued2)),0    
    
End    
Select 'Current Date'=FromDate,'Projected Date'=ToDate,@PostDate,@BankAccountID,'Current Balance'=CurrentBalance,    
'Cheque Collected'=ChequeinHand,'PDCheque Collected'=PDChequeinHand,'PDCheque Issued'=PDChequeIssued,    
'Projected Balance'=ProjectedBalance,'HighLight'=HighLight from #Temp -- 0 next level 

