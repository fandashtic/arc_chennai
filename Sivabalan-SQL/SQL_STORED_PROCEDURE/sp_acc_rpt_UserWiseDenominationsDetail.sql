CREATE procedure sp_acc_rpt_UserWiseDenominationsDetail(@UserName nvarchar(255),@FromDate DateTime,@ToDate DateTime)
As  
Declare @CASH Int  
Declare @ContraID nVarchar(255)  
Declare @Denomination nVarchar(2000)  
Declare @ThousandTotal Int  
Declare @FiveHundredTotal Int  
Declare @HundredTotal Int  
Declare @FiftyTotal Int  
Declare @TwentyTotal Int  
Declare @TenTotal Int  
Declare @FiveTotal Int  
Declare @TwoTotal Int  
Declare @OneTotal Int  
Declare @CoinsTotal Decimal(18,6)  
Declare @i Int,@PrevUserName nVarchar (255)  
Declare @TotalAmount Decimal(18,6)  
  
Set @CASH = 3  
  
Create table #TempDenominations (ContraID nVarchar(255),Thousand Int,FiveHundred Int,  
Hundred Int,Fifty Int,Twenty Int,Ten Int,Five Int,Two Int,One Int,Coins Decimal(18,6),  
Amount Decimal(18,6),SerialNo Int)   
  
Declare ScanDeno Cursor Keyset For  
Select ContraAbstract.ContraID,Denominations  
from ContraDetail,AccountsMaster,ContraAbstract  
where dbo.stripdatefromtime(ContraDate) Between @FromDate and @ToDate  
and ToAccountID = @CASH and AccountsMaster.AccountID = ContraDetail.FromAccountID  
and IsNull(ContraAbstract.Status,0) <> 192  
and ContraAbstract.ContraID = ContraDetail.ContraID and UserName = @UserName
Open ScanDeno  
Fetch From ScanDeno Into @ContraID,@Denomination  
While @@Fetch_Status = 0   
Begin  
 Insert #TempDenominations  
 Exec sp_acc_rpt_retrievedenominations @Denomination,@ContraID  
   
 Fetch Next From ScanDeno Into @ContraID,@Denomination  
End  
Close ScanDeno  
DeAllocate ScanDeno  
  
Select @ThousandTotal = Sum(IsNull(Thousand,0)), @FiveHundredTotal = Sum(IsNull(FiveHundred,0)),  
@HundredTotal = Sum(IsNull(Hundred,0)),@FiftyTotal = Sum(IsNull(Fifty,0)),   
@TwentyTotal = Sum(IsNull(Twenty,0)),@TenTotal = Sum(IsNull(Ten,0)),  
@FiveTotal = Sum(IsNull(Five,0)),@TwoTotal = Sum(IsNull(Two,0)),  
@OneTotal= Sum(IsNull(One,0)),@CoinsTotal = Sum(IsNull(Coins,0)),  
@TotalAmount = ((Sum(IsNull(Thousand,0)) * 1000) + (Sum(IsNull(FiveHundred,0)) * 500)  
+ (Sum(IsNull(Hundred,0)) * 100) + (Sum(IsNull(Fifty,0)) * 50) + (Sum(IsNull(Twenty,0)) * 20)  
+ (Sum(IsNull(Ten,0)) * 10) + (Sum(IsNull(Five,0)) * 5) + (Sum(IsNull(Two,0))* 2)  
+ (Sum(IsNull(One,0)) * 1) + Sum(IsNull(Coins,0)))  
from #TempDenominations   
  
Insert #TempDenominations   
select ContraID, Sum(IsNull(Thousand,0)), Sum(IsNull(FiveHundred,0)),  
Sum(IsNull(Hundred,0)),Sum(IsNull(Fifty,0)),Sum(IsNull(Twenty,0)),  
Sum(IsNull(Ten,0)), Sum(IsNull(Five,0)),Sum(IsNull(Two,0)),Sum(IsNull(One,0)),  
Sum(IsNull(Coins,0)),((Sum(IsNull(Thousand,0)) * 1000) + (Sum(IsNull(FiveHundred,0)) * 500)  
+ (Sum(IsNull(Hundred,0)) * 100)+ (Sum(IsNull(Fifty,0)) * 50) + (Sum(IsNull(Twenty,0)) * 20)  
+ (Sum(IsNull(Ten,0)) * 10) + (Sum(IsNull(Five,0)) * 5)  
+ (Sum(IsNull(Two,0)) * 2) + (Sum(IsNull(One,0)) * 1) + Sum(IsNull(Coins,0))),0
from #TempDenominations Group by ContraID  
  
Delete #TempDenominations Where IsNull(SerialNo,0) = 1   
  
Insert #TempDenominations   
Select 'Total',@ThousandTotal,@FiveHundredTotal,@HundredTotal,  
@FiftyTotal,@TwentyTotal,@TenTotal,@FiveTotal,@TwoTotal,@OneTotal,@CoinsTotal,@TotalAmount,1  

Select 'Transaction ID' = Case When (ContraID <> N'Total') then (dbo.getvoucherprefix('INTERNALCONTRA') + Cast ((Select DocumentID from ContraAbstract where ContraAbstract.ContraID=#TempDenominations.ContraID) as nvarchar)) Else ContraID End,
'1000'= IsNull(Thousand,0),'500' = IsNull(FiveHundred,0),'100' = IsNull(Hundred,0),'50' = IsNull(Fifty,0),  
'20' = IsNull(Twenty,0),'10' = IsNull(Ten,0),'5'= IsNull(Five,0),  
'2' = IsNull(Two,0),'1' = IsNull(One,0),'Coins' = IsNull(Coins,0),'Amount' = IsNull(Amount,0),
SerialNo from #TempDenominations Order By SerialNo
  
Drop Table #TempDenominations  

