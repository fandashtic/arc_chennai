CREATE Procedure spr_list_Userwise_Retail_Sales (@FromDate datetime,                          
      @ToDate datetime,@UserName nvarchar(2550),@PaymentMode nvarchar(50))                          
As     
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
Create table #tmpUsers(UsrName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
if @UserName=N'%'       
   Insert into #tmpUsers select UserName from Users      
Else      
   Insert into #tmpUsers select * from dbo.sp_SplitIn2Rows(@UserName,@Delimeter)      
declare @paymode int    
declare @value nvarchar(50)    
declare @ColName nvarchar(100)    
Declare @StrSql nvarchar(2000)        
Declare @StrSql1 nvarchar(2000)     
declare @PaymodeValue nvarchar(100)    
declare @User nvarchar(50)    
declare @Amt Decimal(18,6)        
-- Create Table #Temp(PaymentMode int null,Amount Decimal(18,6) null, UserName nvarchar(50))    
--     
-- DECLARE PayModeDetails CURSOR for Select Mode,value from PaymentMode where value like @PaymentMode
-- OPEN PayModeDetails              
-- FETCH FROM PayModeDetails INTO @PayMode,@Value              
-- WHILE @@Fetch_status = 0        
--    BEGIN                       
--  Insert into #Temp     
-- -- Select @PayMode, "Value" = IsNull(Sum(dbo.GetAmountCollected(PaymentDetails, Rtrim(@Value) + ':')), 0),"UserName" = UserName                                 
--  Select @PayMode, "Value" = (select sum(NetRecieved) from Retailpaymentdetails where
--  PaymentMode=@PayMode and RetailInvoiceID=InvoiceAbstract.InvoiceID),"UserName" = UserName                                 
--  From InvoiceAbstract                          
--  Where InvoiceType = 2 And                          
--  IsNull(Status, 0) & 128 = 0 And                          
--  UserName In (select UsrName from #tmpUsers) And                    
--  InvoiceDate Between @FromDate And @ToDate              
--  Group by username,InvoiceAbstract.InvoiceID                     
--  FETCH NEXT FROM PayModeDetails INTO @PayMode,@Value          
--    END      
--       
-- CLOSE PayModeDetails              
-- DEALLOCATE PayModeDetails     
    
-- Select "Payment Mode" = value,    
-- "Value" = Sum(Amount),                     
-- "UserName" = UserName  Into #Temp1                    
-- From #Temp,PaymentMode where mode = PaymentMode     
-- Group By value,UserName Having Sum(Amount) <> 0      
      
Select "Payment Mode" = pm.Value, "Value" = Sum(rpd.AmountReceived - rpd.AmountReturned), 
	"Username" = us.UserName 
	Into #Temp1 From 
    PaymentMode pm, Users us, 
	InvoiceAbstract ia, RetailPaymentDetails rpd Where ia.InvoiceDate Between @FromDate And @ToDate  and
	pm.Mode = rpd.PaymentMode And rpd.RetailInvoiceID = ia.InvoiceID And
    ia.UserName = us.UserName And pm.Value Like @PaymentMode And
	us.UserName In (Select UsrName COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpUsers)
    Group By pm.Value, us.UserName


Select Username,"TotalValue"= sum(value) into #Temp2 from #Temp1 group by username     
    
Declare getPaymentMode CURSOR for Select distinct [payment mode] from #Temp1        
open getPaymentMode      
Fetch from getPaymentMode into @ColName      
while @@Fetch_status = 0      
Begin      
set @StrSql = N'Alter Table #Temp2 Add [' + @ColName + N'] Decimal(18,6)'      
exec sp_executesql @StrSql          
Fetch Next from getPaymentMode into @ColName      
end      
close getPaymentMode      
deallocate getPaymentMode      
      
      
Declare InsertValues CURSOR for Select * from #Temp1      
open InsertValues      
Fetch from InsertValues into @PaymodeValue,@Amt,@User      
while @@Fetch_status = 0      
Begin      
set @StrSql1 = N'Update #Temp2 set [' + @PaymodeValue + N'] = ' + cast(@Amt as nvarchar) + N' Where Username = ''' + @User + ''''        
exec sp_executesql @StrSql1          
Fetch Next from InsertValues into @PaymodeValue,@Amt,@User      
end      
close InsertValues      
deallocate InsertValues      
      
select @PaymentMode +N':'+ UserName,* from #Temp2        
      
--drop table #Temp    
drop table #Temp1    
Drop table #Temp2      
Drop table #tmpUsers    

