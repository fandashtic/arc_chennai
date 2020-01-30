CREATE Procedure sp_acc_rpt_netprofitdetail(@NetValue Decimal(18,6))
As
Declare @ShareLoss Decimal(18,6),@ShareProfit Decimal(18,6),@PartnerAccountID Int,@PartnerDrawingAccountID Int
Declare @ShareLossValue Decimal(18,6),@ShareProfitValue Decimal(18,6),@DrawingAccountFlag Int

Select @DrawingAccountFlag=DrawingAccountFlag from setup

Create table #PartnerDetail(PartnerName nVarchar(255),ShareRatio Decimal(18,6),ShareValue Decimal(18,6),HighLight Int)

If @NetValue>0
Begin
	DECLARE scansetupdetail CURSOR KEYSET FOR
	Select ShareofProfit,AccountID,DrawingAccountID from setupdetail
	OPEN scansetupdetail
	FETCH FROM scansetupdetail INTO @ShareProfit,@PartnerAccountID,@PartnerDrawingAccountID
	WHILE @@FETCH_STATUS=0
	Begin
		If @ShareProfit=0
		Begin
			Set @ShareProfitValue=0
		End
		Else
		Begin
			Set @ShareProfitValue=@NetValue*(@ShareProfit/100)
		End
			
		If @DrawingAccountFlag=1 
		Begin
			Insert #PartnerDetail
			Select dbo.getaccountname(@PartnerDrawingAccountID),@ShareProfit,@ShareProfitValue,5 -- Last level
		End
		Else
		Begin
			Insert #PartnerDetail
			Select dbo.getaccountname(@PartnerAccountID),@ShareProfit,@ShareProfitValue,5
		End
		FETCH NEXT FROM scansetupdetail INTO @ShareProfit,@PartnerAccountID,@PartnerDrawingAccountID
	End
	ClOSE scansetupdetail
	DEALLOCATE scansetupdetail

	Insert #PartnerDetail
	Select 'Total',Sum(ShareRatio),Sum(ShareValue),1 from #PartnerDetail -- Last Level with highlight

	Select PartnerName,'ShareRatio(%)' = ShareRatio,ShareValue,HighLight from #PartnerDetail
	Drop Table #PartnerDetail
End
Else If @NetValue<0
Begin
	Set @NetValue=Abs(@NetValue)
	DECLARE scansetupdetail CURSOR KEYSET FOR
	Select ShareofLoss,AccountID,DrawingAccountID from setupdetail
	OPEN scansetupdetail
	FETCH FROM scansetupdetail INTO @ShareLoss,@PartnerAccountID,@PartnerDrawingAccountID
	WHILE @@FETCH_STATUS=0
	Begin
		If @ShareLoss=0
		Begin
			Set @ShareLossValue=0
		End
		Else
		Begin
			Set @ShareLossValue=@NetValue*(@ShareLoss/100)
		End
		
		If @DrawingAccountFlag=1 
		Begin
			Insert #PartnerDetail
			Select dbo.getaccountname(@PartnerDrawingAccountID),@ShareLoss,@ShareLossValue,5
		End
		Else
		Begin
			Insert #PartnerDetail
			Select dbo.getaccountname(@PartnerAccountID),@ShareLoss,@ShareLossValue,5
		End
		FETCH NEXT FROM scansetupdetail INTO @ShareLoss,@PartnerAccountID,@PartnerDrawingAccountID
	End
	ClOSE scansetupdetail
	DEALLOCATE scansetupdetail

	Insert #PartnerDetail
	Select 'Total',Sum(ShareRatio),Sum(ShareValue),1 from #PartnerDetail -- Last Level with highlight

	Select PartnerName,'ShareRatio(%)' = ShareRatio,ShareValue,HighLight from #PartnerDetail
	Drop Table #PartnerDetail
End





