CREATE Procedure [dbo].[sp_acc_yearend_settingofaccounts](@YearEndDate DateTime)
As
Declare @TransactionID Int
Declare @YEARENDTYPE Int
Declare @OPENINGSTOCKACCOUNT Int
Declare @CLOSINGSTOCKACCOUNT Int
Declare @TAXONOPENINGSTOCKACCOUNT Int
Declare @TAXONCLOSINGSTOCKACCOUNT Int
Declare @TRADINGACCOUNT Int
Declare @DocumentNumber Int
Declare @TODATE datetime
Declare @FROMDATE datetime
Set @TODATE=dbo.stripdatefromtime(@YearEndDate)
Set @FROMDATE=(Select OpeningDate from SetUp)

Set @YEARENDTYPE=27
Set @OPENINGSTOCKACCOUNT=22
Set @CLOSINGSTOCKACCOUNT=23
Set @TAXONOPENINGSTOCKACCOUNT=89
Set @TAXONCLOSINGSTOCKACCOUNT=88
Set @TRADINGACCOUNT=16

Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation

--Debit the trading Account and Crediting the OpeningStock
Declare @Value Decimal(18,6)
Set @Value=isnull((Select OpeningBalance from AccountsMaster where AccountID=@OPENINGSTOCKACCOUNT and Active=1),0)
If @Value=0
Begin
Set @Value=isnull((Select sum(opening_Value) from OpeningDetails where Opening_Date=@FROMDATE),0)
End

If @Value>0
Begin
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran

	execute sp_acc_insertGJ @TransactionID,@TRADINGACCOUNT,@TODATE,@Value,0,0,@YEARENDTYPE,"Year End",@DocumentNumber
	execute sp_acc_insertGJ @TransactionID,@OPENINGSTOCKACCOUNT,@TODATE,0,@Value,0,@YEARENDTYPE,"Year End",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@TRADINGACCOUNT)	
	Insert Into #TempBackdatedAccounts(AccountID) Values(@OPENINGSTOCKACCOUNT)	
End
Set @Value=0
/*If @OpeningStock<0
Begin
	-- Entry for Customer Account
	execute sp_acc_insertGJ @TransactionID,@TRADINGACCOUNT,@Todate,0,@Value,0,@YEARENDTYPE,"Year End"
	execute sp_acc_insertGJ @TransactionID,@OPENINGSTOCK,@ToDate,@Value,0,0,@YEARENDTYPE,"Year End"
End
*/
--Debit the trading Account and Crediting the TaxOnOpeningStock
Set @Value=isnull((Select OpeningBalance from AccountsMaster where AccountID=@TAXONOPENINGSTOCKACCOUNT and Active=1),0)
If @Value=0
Begin
    Select @Value = Sum(Case When IsNull(Items.VAT,0) = 1 Then       
    (Case When (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0)) <> 0 Then      
    (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0))/100 Else 0 End) Else      
    (Case When (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0)) <> 0 Then      
    (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0))/100 Else 0 End) End)      
    from OpeningDetails, Items Where OpeningDetails.Product_Code = Items.Product_Code      
    And Opening_Date = @FromDate      
    Set @Value =isnull(@Value,0)
End

If @Value>0
Begin
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran

	execute sp_acc_insertGJ @TransactionID,@TRADINGACCOUNT,@TODATE,@Value,0,0,@YEARENDTYPE,"Year End",@DocumentNumber
	execute sp_acc_insertGJ @TransactionID,@TaxONOPENINGSTOCKACCOUNT,@TODATE,0,@Value,0,@YEARENDTYPE,"Year End",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@TRADINGACCOUNT)	
	Insert Into #TempBackdatedAccounts(AccountID) Values(@TaxONOPENINGSTOCKACCOUNT)	
End
Set @Value=0
/*If @OpeningStock<0
Begin
	-- Entry for Customer Account
	execute sp_acc_insertGJ @TransactionID,@TRADINGACCOUNT,@Todate,0,@Value,0,@YEARENDTYPE,"Year End"
	execute sp_acc_insertGJ @TransactionID,@TAXONOPENINGSTOCK,@ToDate,@Value,0,0,@YEARENDTYPE,"Year End"
End
*/

--Debit Trading Account and Credit Purchase Account
Declare @PURCHASEGROUP Int
Set @PURCHASEGROUP=27
Execute sp_acc_yearend_recursiveaccountsetting @PURCHASEGROUP,@TRADINGACCOUNT,@TODATE,@YEARENDTYPE

--Debit Trading Account and Credit Direct Expense Account
Declare @DIRECTEXPENSEGROUP Int
Set @DIRECTEXPENSEGROUP=24
Execute sp_acc_yearend_recursiveaccountsetting @DIRECTEXPENSEGROUP,@TRADINGACCOUNT,@TODATE,@YEARENDTYPE

--Debit Sales Account and Credit Trading Account Account
Declare @SALESGROUP Int
Set @SALESGROUP=28
Execute sp_acc_yearend_recursiveaccountsetting @SALESGROUP,@TRADINGACCOUNT,@TODATE,@YEARENDTYPE

--Debit Direct Income Account and Credit Trading Account Account
Declare @DIRECTINCOMEGROUP Int
Set @DIRECTINCOMEGROUP=26
Execute sp_acc_yearend_recursiveaccountsetting @DIRECTINCOMEGROUP,@TRADINGACCOUNT,@TODATE,@YEARENDTYPE

--Debit Closing Stock and Credit Trading Account
 
If @Todate< dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))
Begin
	Set @Value = isnull((Select sum(opening_Value) from OpeningDetails where Opening_Date=dateadd(day,1,@ToDate)),0)
End
Else
Begin
		Declare @ClosingStockValue Decimal(18,6)
		Set @Value=isnull(dbo.sp_acc_getclosingstock(),0) End
If @Value>0
Begin
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran
	
	execute sp_acc_insertGJ @TransactionID,@CLOSINGSTOCKACCOUNT,@TODATE,@Value,0,0,@YEARENDTYPE,"Year End",@DocumentNumber
	execute sp_acc_insertGJ @TransactionID,@TRADINGACCOUNT,@TODATE,0,@Value,0,@YEARENDTYPE,"Year End",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@CLOSINGSTOCKACCOUNT)	
	Insert Into #TempBackdatedAccounts(AccountID) Values(@TRADINGACCOUNT)	
End
Else If @Value<0
Begin
	Set @Value=abs(@Value)
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran
	
	execute sp_acc_insertGJ @TransactionID,@TRADINGACCOUNT,@Todate,@Value,0,0,@YEARENDTYPE,"Year End",@DocumentNumber
	execute sp_acc_insertGJ @TransactionID,@CLOSINGSTOCKACCOUNT,@ToDate,0,@Value,0,@YEARENDTYPE,"Year End",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@TRADINGACCOUNT)	
	Insert Into #TempBackdatedAccounts(AccountID) Values(@CLOSINGSTOCKACCOUNT)	
End
Set @Value=0

--Debit Tax on Closing Stock and Credit Trading Account
 /* As per the change request need to remove "Tax on Closing Stock and Credit Trading Account"*/ 
/*
If @Todate< dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))
Begin
   Select @Value = Sum(Case When IsNull(Items.VAT,0) = 1 Then     
   (Case When (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0)) <> 0 Then    
   (IsNULL(Opening_Value,0) * IsNULL(CST_TaxSuffered,0))/100 Else 0 End) Else    
   (Case When (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0)) <> 0 Then    
   (IsNULL(Opening_Value,0) * IsNULL(TaxSuffered_Value,0))/100 Else 0 End) End)    
   from OpeningDetails, Items Where OpeningDetails.Product_Code = Items.Product_Code    
   And Opening_Date = DateAdd(Day,1,@ToDate)  
   Set @Value =Isnull(@Value,0)
End
Else
Begin
		Set @Value=isnull(dbo.sp_acc_getTaxonClosingStock(),0)
End
If @Value>0
Begin
	
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran
	
	execute sp_acc_insertGJ @TransactionID,@TAXONCLOSINGSTOCKACCOUNT,@TODATE,@Value,0,0,@YEARENDTYPE,"Year End",@DocumentNumber
	execute sp_acc_insertGJ @TransactionID,@TRADINGACCOUNT,@TODATE,0,@Value,0,@YEARENDTYPE,"Year End",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@TAXONCLOSINGSTOCKACCOUNT)	
	Insert Into #TempBackdatedAccounts(AccountID) Values(@TRADINGACCOUNT)	
End
Else If @Value<0
Begin
	Set @Value=abs(@Value)
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran
	
	execute sp_acc_insertGJ @TransactionID,@TRADINGACCOUNT,@Todate,@Value,0,0,@YEARENDTYPE,"Year End",@DocumentNumber
	execute sp_acc_insertGJ @TransactionID,@TAXONCLOSINGSTOCKACCOUNT,@ToDate,0,@Value,0,@YEARENDTYPE,"Year End",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@TRADINGACCOUNT)	
	Insert Into #TempBackdatedAccounts(AccountID) Values(@TAXONCLOSINGSTOCKACCOUNT)	
End
Set @Value=0

*/
/*  IF GROSS PROFIT then DEBIT the TRADING A/C and CREDIT the GROSS PROFIT A/C
			and DEBIT the GROSS PROFIT A/C and CREDIT the P/L A/C
    Else Vice versa
*/
Declare @GROSSPROFITACCOUNT Int, @GROSSLOSSACCOUNT Int, @PLACCOUNT Int
Set @GROSSPROFITACCOUNT=18
Set @GROSSLOSSACCOUNT=19
Set @PLACCOUNT=17

Set @Value=isnull((Select sum(isnull(Debit,0)-isnull(Credit,0)) from GeneralJournal where
AccountID=@TRADINGACCOUNT and TransactionDate=@TODATE),0)

If @Value>0
Begin
--Gross Loss

	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran
	
	execute sp_acc_insertGJ @TransactionID,@GROSSLOSSACCOUNT,@Todate,@Value,0,0,@YEARENDTYPE,"Year End",@DocumentNumber
	execute sp_acc_insertGJ @TransactionID,@TRADINGACCOUNT,@ToDate,0,@Value,0,@YEARENDTYPE,"Year End",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@GROSSLOSSACCOUNT)	
	Insert Into #TempBackdatedAccounts(AccountID) Values(@TRADINGACCOUNT)	

	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran
	
	execute sp_acc_insertGJ @TransactionID,@PLACCOUNT,@Todate,@Value,0,0,@YEARENDTYPE,"Year End",@DocumentNumber
	execute sp_acc_insertGJ @TransactionID,@GROSSLOSSACCOUNT,@ToDate,0,@Value,0,@YEARENDTYPE,"Year End",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@PLACCOUNT)	
	Insert Into #TempBackdatedAccounts(AccountID) Values(@GROSSLOSSACCOUNT)	
End
Else If @value<0
Begin
	Set @Value=abs(@Value)
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran
	
	execute sp_acc_insertGJ @TransactionID,@TRADINGACCOUNT,@Todate,@Value,0,0,@YEARENDTYPE,"Year End",@DocumentNumber
	execute sp_acc_insertGJ @TransactionID,@GROSSPROFITACCOUNT,@ToDate,0,@Value,0,@YEARENDTYPE,"Year End",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@TRADINGACCOUNT)	
	Insert Into #TempBackdatedAccounts(AccountID) Values(@GROSSPROFITACCOUNT)	

	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran
	
	execute sp_acc_insertGJ @TransactionID,@GROSSPROFITACCOUNT,@Todate,@Value,0,0,@YEARENDTYPE,"Year End",@DocumentNumber
	execute sp_acc_insertGJ @TransactionID,@PLACCOUNT,@ToDate,0,@Value,0,@YEARENDTYPE,"Year End",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@GROSSPROFITACCOUNT)	
	Insert Into #TempBackdatedAccounts(AccountID) Values(@PLACCOUNT)	
End
Set @Value=0

-- Debit the P/L account and credit all Indirect expense account
Declare @INDIRECTEXPENSEGROUP Int
Set @INDIRECTEXPENSEGROUP=25
Execute sp_acc_yearend_recursiveaccountsetting @INDIRECTEXPENSEGROUP,@PLACCOUNT,@TODATE,@YEARENDTYPE

-- Debit all Indirect income account and credit the P/L account 
Declare @INDIRECTINCOMEGROUP Int
Set @INDIRECTINCOMEGROUP=31
Execute sp_acc_yearend_recursiveaccountsetting @INDIRECTINCOMEGROUP,@PLACCOUNT,@TODATE,@YEARENDTYPE
/*  IF NET PROFIT then DEBIT the PL A/C and CREDIT the NET PROFIT A/C
			and DEBIT the NET PROFIT A/C and CREDIT the CAPITAL A/C
    Else Vice versa
*/
Declare @NETPROFITACCOUNT Int, @NETLOSSACCOUNT Int, @CAPITALACCOUNT Int
Set @NETPROFITACCOUNT=20
Set @NETLOSSACCOUNT=21
Set @CAPITALACCOUNT=24

Declare @OrgType Int,@PartnerCount Int,@DrawingAccountFlag Int,@ShareProfitValue Decimal(18,6),@ShareLossValue Decimal(18,6)
Declare @ShareProfit Decimal(18,6),@ShareLoss Decimal(18,6),@PartnerAccountID Int,@PartnerDrawingAccountID Int
Select @OrgType=OrganisationType,@PartnerCount=Numberofpartners,@DrawingAccountFlag=DrawingAccountFlag from setup

Set @Value=isnull((Select sum(isnull(Debit,0)-isnull(Credit,0)) from GeneralJournal where
AccountID=@PLACCOUNT and TransactionDate=@TODATE),0)

If @Value>0
Begin
--Net Loss
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran
	
	execute sp_acc_insertGJ @TransactionID,@NETLOSSACCOUNT,@Todate,@Value,0,0,@YEARENDTYPE,"Year End",@DocumentNumber
	execute sp_acc_insertGJ @TransactionID,@PLACCOUNT,@ToDate,0,@Value,0,@YEARENDTYPE,"Year End",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@NETLOSSACCOUNT)	
	Insert Into #TempBackdatedAccounts(AccountID) Values(@PLACCOUNT)	

	-- Get the last TransactionID from the DocumentNumbers table
 	begin tran
 		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
 		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
 	Commit Tran
 	
 	-- Get the last TransactionID from the DocumentNumbers table
 	begin tran
 		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
 		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
 	Commit Tran

	DECLARE scansetupdetail CURSOR KEYSET FOR
	Select ShareofLoss,AccountID,DrawingAccountID from setupdetail
	OPEN scansetupdetail
	FETCH FROM scansetupdetail INTO @ShareLoss,@PartnerAccountID,@PartnerDrawingAccountID
	WHILE @@FETCH_STATUS=0
	Begin
		If @ShareLoss <> 0
		Begin
			Set @ShareLossValue=@Value*(@ShareLoss/100)
			If @DrawingAccountFlag=1 
			Begin
			 	execute sp_acc_insertGJ @TransactionID,@PartnerDrawingAccountID,@Todate,@ShareLossValue,0,0,@YEARENDTYPE,"Year End",@DocumentNumber
				Insert Into #TempBackdatedAccounts(AccountID) Values(@PartnerDrawingAccountID)	
			End
			Else
			Begin
				execute sp_acc_insertGJ @TransactionID,@PartnerAccountID,@Todate,@ShareLossValue,0,0,@YEARENDTYPE,"Year End",@DocumentNumber
				Insert Into #TempBackdatedAccounts(AccountID) Values(@PartnerAccountID)	
			End
		End
		FETCH NEXT FROM scansetupdetail INTO @ShareLoss,@PartnerAccountID,@PartnerDrawingAccountID
	End
	ClOSE scansetupdetail
	DEALLOCATE scansetupdetail

 	execute sp_acc_insertGJ @TransactionID,@NETLOSSACCOUNT,@ToDate,0,@Value,0,@YEARENDTYPE,"Year End",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@NETLOSSACCOUNT)	
End
Else If @value<0
Begin
	Set @Value=abs(@Value)
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
	Commit Tran
	-- Get the last TransactionID from the DocumentNumbers table
	begin tran
		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
	Commit Tran
	
	execute sp_acc_insertGJ @TransactionID,@PLACCOUNT,@Todate,@Value,0,0,@YEARENDTYPE,"Year End",@DocumentNumber
	execute sp_acc_insertGJ @TransactionID,@NETPROFITACCOUNT,@ToDate,0,@Value,0,@YEARENDTYPE,"Year End",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@PLACCOUNT)	
	Insert Into #TempBackdatedAccounts(AccountID) Values(@NETPROFITACCOUNT)	
	-- Get the last TransactionID from the DocumentNumbers table
 	begin tran
 		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
 		Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
 	Commit Tran
 	begin tran
 		update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
 		Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
 	Commit Tran

 	execute sp_acc_insertGJ @TransactionID,@NETPROFITACCOUNT,@Todate,@Value,0,0,@YEARENDTYPE,"Year End",@DocumentNumber
	Insert Into #TempBackdatedAccounts(AccountID) Values(@NETPROFITACCOUNT)	

	DECLARE scansetupdetail CURSOR KEYSET FOR
	Select ShareofProfit,AccountID,DrawingAccountID from setupdetail
	OPEN scansetupdetail
	FETCH FROM scansetupdetail INTO @ShareProfit,@PartnerAccountID,@PartnerDrawingAccountID
	WHILE @@FETCH_STATUS=0
	Begin
		If @ShareProfit <> 0
		Begin
			Set @ShareProfitValue=@Value*(@ShareProfit/100)
			If @DrawingAccountFlag=1 
			Begin
				execute sp_acc_insertGJ @TransactionID,@PartnerDrawingAccountID,@ToDate,0,@ShareProfitValue,0,@YEARENDTYPE,"Year End",@DocumentNumber
				Insert Into #TempBackdatedAccounts(AccountID) Values(@PartnerDrawingAccountID)	
			End
			Else
			Begin
				execute sp_acc_insertGJ @TransactionID,@PartnerAccountID,@ToDate,0,@ShareProfitValue,0,@YEARENDTYPE,"Year End",@DocumentNumber
				Insert Into #TempBackdatedAccounts(AccountID) Values(@PartnerAccountID)	
			End
		End
		FETCH NEXT FROM scansetupdetail INTO @ShareProfit,@PartnerAccountID,@PartnerDrawingAccountID
	End
	ClOSE scansetupdetail
	DEALLOCATE scansetupdetail
End
Set @Value=0

/*Backdated Operation */
--Get the server date
Declare @ServerDate Datetime
set @ServerDate = dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))

If @YearEndDate < @ServerDate
Begin
	Declare @TempAccountID Int
	DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR
	Select AccountID From #TempBackdatedAccounts
	OPEN scantempbackdatedaccounts
	FETCH FROM scantempbackdatedaccounts INTO @TempAccountID
	WHILE @@FETCH_STATUS =0
	Begin
		Exec sp_acc_backdatedaccountopeningbalance @TODATE,@TempAccountID
		FETCH NEXT FROM scantempbackdatedaccounts INTO @TempAccountID
	End
	CLOSE scantempbackdatedaccounts
	DEALLOCATE scantempbackdatedaccounts
	Drop Table #TempBackdatedAccounts
End
--Updating last transaction date
Update Setup Set TransactionDate =@YearEndDate

