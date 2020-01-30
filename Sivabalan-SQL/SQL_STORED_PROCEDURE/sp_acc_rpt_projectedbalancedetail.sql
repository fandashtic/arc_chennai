CREATE Procedure sp_acc_rpt_projectedbalancedetail(@PostDate DateTime,@ProjectedDate DateTime,@BankAccountID Int)      
As      
Declare @LastBalance as Decimal(18,6)      
Declare @BankBalance as Decimal(18,6)      
Declare @ChequeinHand as Decimal(18,6)      
Declare @PDChequeinHand as Decimal(18,6)      
Declare @PDChequeIssued as Decimal(18,6)      
Declare @Currentdate as DateTime    
Declare @CurrentDatePair as datetime      
--Declare @MaxPostDated as DateTime      
--Declare @LoopDate as DateTime      
Set @Currentdate=dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))      
Set @CurrentDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @Currentdate))    
      
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
      
--Set @MaxPostDated=(Select Max(Cheque_Date) from Payments where dbo.StripDatefromTime(Cheque_Date)>@Currentdate and (Status & 192) <> 192)      
--If dbo.stripdatefromtime(@MaxPostDated) > @PostDate       
--Begin      
-- Set @LoopDate =dbo.stripdatefromtime(@MaxPostDated)      
--End      
--Else      
--Begin      
-- Set @LoopDate =@PostDate       
--End      
Create Table #Temp(Datewise DateTime,CurrentBalance Decimal(18,6), ChequeinHand Decimal(18,6),PDCHequeinHand Decimal(18,6),      
PDChequeIssued Decimal(18,6),ProjectedBalance Decimal(18,6),HighLight Int)      
While @CurrentDate<=@PostDate      
Begin      
 If @CurrentDate > dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))      
 Begin      
  Set @PDChequeinHand=isnull((Select sum(Value) from collections       
  where chequeDate between @CurrentDate and @CurrentDatePair    
  and (isnull(DepositID,0)=0) and PaymentMode>0      
  and (isnull(Status,0) & 64) = 0),0)      
      
  Set @PDChequeIssued=isnull((Select sum(Value) from Payments       
  where cheque_Date between @CurrentDate and @CurrentDatePair and     
  PaymentMode>0 and BankID=(Select BankID from Bank where AccountID=@BankAccountID)      
  and (isnull(Status,0) & 64) = 0),0)      
      
 End      
 Else      
 Begin      
  Set @ChequeinHand=isnull((Select sum(Value) from collections       
  where chequeDate <= @CurrentDatePair      
  and (isnull(DepositID,0)=0) and PaymentMode>0      
  and (isnull(Status,0) & 64) = 0),0)      
 End      
 Insert #Temp      
 Select 'Date'=@CurrentDate,'Current Bank balance'=isnull(@BankBalance,0),'Cheque in Hand'=isnull(@ChequeinHand,0),'PDCheque in Hand'=isnull(@PDChequeinHand,0),      
 'PDCheque Issued'=isnull(@PDChequeIssued,0),'Projected Bank Balance'=isnull(@BankBalance,0) + (isnull(@ChequeinHand,0)+ isnull(@PDChequeinHand,0)-isnull(@PDChequeIssued,0)),      
 Case when (@CurrentDate=@ProjectedDate) then 1 else 5 end -- 1-color, 5-no color, both-no next level      
       
 Set @BankBalance=isnull(@BankBalance,0) + (isnull(@ChequeinHand,0)+ isnull(@PDChequeinHand,0)-isnull(@PDChequeIssued,0))      
 Set @CurrentDate=DateAdd(day,1,@CurrentDate)      
 Set @CurrentDatePair=DateAdd(day,1,@CurrentDatePair)      
 Set @ChequeinHand=0      
 Set @PDChequeinHand=0      
 Set @PDChequeIssued=0      
End      
      
Select 'Date'=Datewise,'Current Balance'=CurrentBalance,'Cheque in Hand'=ChequeinHand,'PDCheque in Hand'=PDChequeinHand,      
'PDCheque Issued'=PDChequeIssued,'Projected Balance'=ProjectedBalance,'HighLight'=HighLight from #Temp      
Drop Table #Temp 

