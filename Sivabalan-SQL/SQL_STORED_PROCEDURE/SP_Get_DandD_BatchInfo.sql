
Create Procedure SP_Get_DandD_BatchInfo @ID int, @Product_Code nvarchar(30) 
AS Begin  
 
	Set DateFormat dmy  
	Declare @Last_Close_Date Datetime 
	Declare @FromMonth nvarchar(25)
	Declare @ToMonth nvarchar(25)
	Declare @FromDate Datetime
	Declare @ToDate Datetime
	Declare @OptSelection int
	Declare @StockAdjID nvarchar(1000)

	Declare @OpeningDate as datetime
	Select Top 1 @OpeningDate=OpeningDate from Setup
	 
	Declare @Delimiter Char(1)
	Set @Delimiter = ','

	Select @Last_Close_Date = Convert(Nvarchar(10),DayCloseDate,103), @FromMonth = FromMonth,
			@ToMonth = ToMonth, @OptSelection = OptSelection From DandDAbstract Where ID = @ID  

	Select @FromDate = Convert(Nvarchar(10),dbo.mERP_fn_getFromDate(@FromMonth),103), @ToDate = Convert(Nvarchar(10),dbo.mERP_fn_getToDate(@ToMonth),103)
	
	
	IF @OptSelection = 2
	Begin		
		/* For month selection */
		If not exists(select 'x'from DandDDetail where Product_code=@Product_code And ID = @ID And isnull(RFAQuantity,0)>0)  
		BEGIN  	

			Create Table #tmpOutput(Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS, Batch_Code int, Quantity decimal(18,6), DocDate Datetime, QuantityReceived decimal(18,6))
			Create Table #tmpDelete(Product_Code nvarchar(15) Collate SQL_Latin1_General_CP1_CI_AS, Batch_Code int)
	
			Insert into #tmpOutput(Product_Code,Batch_Code,Quantity, DocDate,QuantityReceived)
			Select 
				Product_Code, Batch_Code, Sum(isnull(quantity,0)) As Damage_Quantity, DocDate, Sum(isnull(QuantityReceived,0)) As QuantityReceived
			From 
				Batch_Products
			Where
				Convert(nvarchar(10),DocDate,103) Between @FromDate and @ToDate	
				And isnull(Damage,0)<>0
				And Product_Code = @Product_code
				And isnull(Free,0) = 0
			Group By
				Product_Code, Batch_Code, DocDate
			Having  Sum(isnull(Quantity,0))>0

			/* Start: To get Batch for opening date Damage Sales Retun, Sales converison, Physical Reconcilation and delete opening damage stock */
			Insert Into #tmpDelete
			Select BP.Product_Code, BP.Batch_Code From Batch_Products BP,InvoiceAbstract IA,InvoiceDetail ID 
			Where IA.InvoiceID=BP.DocID And IA.InvoiceID = ID.Invoiceid And
			ID.Batch_Code=BP.Batch_Code And IsNUll(BP.Damage,0)<>0 and
			BP.DocType=1 and Invoicetype=4 and
			isnull(status,0)&32 <> 0 And isnull(status,0)&64 = 0
			and Convert(nvarchar(10),IA.InvoiceDate,103) = @OpeningDate
			And isnull(BP.Free,0) = 0	

			Insert Into #tmpDelete
			Select BP.Product_Code, BP.Batch_Code From Batch_Products BP,StockAdjustmentAbstract SA,StockAdjustment SD Where
			SA.AdjustmentID=BP.DocID And SA.AdjustmentID = SD.SerialNo And
			SD.Batch_Code=BP.Batch_Code And IsNUll(BP.Damage,0)<>0
			and BP.DocType=2 and SA.AdjustmentType = 0
			and Convert(nvarchar(10),SA.AdjustmentDate,103) = @OpeningDate
			And isnull(BP.Free,0) = 0	

--			Insert Into #tmpDelete
--			Select BP.Product_Code, BP.Batch_Code From Batch_Products BP,StockAdjustmentAbstract SA,StockAdjustment SD Where
--			SA.AdjustmentID= SD.SerialNo And
--			SD.Batch_Code=BP.Batch_Code And IsNUll(BP.Damage,0)<>0 
--			and SA.AdjustmentType = 4 and Convert(nvarchar(10),SA.AdjustmentDate,103) = @OpeningDate

			Delete From #tmpOutput Where Convert(nvarchar(10),DocDate,103) = @OpeningDate and Batch_Code Not In(Select Distinct Batch_Code From #tmpDelete)
			/* End: To get Batch for opening date Damage Sales Retun, Sales converison, Physical Reconcilation and delete opening damage stock */

			
			Select BP.Batch_Number, Tot_Qty = Sum(IsNull(T.Quantity, 0)), Rate = BP.PTS, Tax = BP.TaxSuffered ,
				TOQ = Max(Isnull(BP.TOQ,0)), TaxID = isnull(BP.GRNTaxID,0), 
				TaxType = Case When isnull(BP.TaxType,0) = 5 Then isnull(BP.GSTTaxType,0) Else isnull(BP.TaxType,0) End
			From #tmpOutput T, Batch_Products BP
			Where T.Product_Code = BP.Product_Code
				and T.Batch_Code = BP.Batch_Code
				And BP.Product_Code = @Product_code
			Group By BP.Batch_Number, BP.PTS, BP.TaxSuffered, BP.GRNTaxID, BP.TaxType, BP.GSTTaxType
			Having Sum(IsNull(T.Quantity,0))>0  
			Order By MIN(BP.Batch_Code)

			Drop Table #tmpOutput
			Drop Table #tmpDelete	
		END  
		ELSE  
		BEGIN  
			If (select isnull(Claimstatus,0) from DandDAbstract where ID = @ID) =1
			BEGIN
				Select DD.Batch_Number,sum(DD.TotalQuantity),Rate = BP.PTS, Tax = BP.TaxSuffered ,TOQ = Max(Isnull(BP.TOQ,0))
					, TaxID = isnull(BP.GRNTaxID,0), 
					TaxType = Case When isnull(BP.TaxType,0) = 5 Then isnull(BP.GSTTaxType,0) Else isnull(BP.TaxType,0) End
				From Batch_Products BP,DandDDetail DD where DD.ID=@ID and DD.Product_code=@Product_code  
					And DD.Batch_code=BP.Batch_code 
					And Convert(Nvarchar(10),BP.DocDate,103) <= @Last_Close_Date
					And BP.Quantity > 0
					And IsNull(BP.Damage,0) <> 0
					And isnull(BP.Free,0) = 0	
				Group By DD.Batch_Number, BP.PTS, BP.TaxSuffered, BP.GRNTaxID, BP.TaxType, BP.GSTTaxType
				Having  Sum(isnull(BP.quantity,0))>0
				Order By MIN(BP.Batch_Code)  
			END
			ELSE
			BEGIN
				Select DD.Batch_Number,sum(DD.TotalQuantity),Rate = DD.PTS, Tax = DD.TaxSuffered ,TOQ = Max(Isnull(BP.TOQ,0)) 
					, TaxID = isnull(BP.GRNTaxID,0), 
					TaxType = Case When isnull(BP.TaxType,0) = 5 Then isnull(BP.GSTTaxType,0) Else isnull(BP.TaxType,0) End
				From DandDDetail DD,Batch_Products BP where DD.ID=@ID and DD.Product_code=@Product_code  And DD.Batch_code=BP.Batch_code 
				Group By DD.Batch_Number, DD.PTS, DD.TaxSuffered , BP.GRNTaxID, BP.TaxType, BP.GSTTaxType
				Order By MIN(DD.Batch_Code)  
			END
		END 
		
	End
	Else
	Begin
		If not exists(select 'x'from DandDDetail where Product_code=@Product_code And ID = @ID And isnull(RFAQuantity,0)>0)  
		BEGIN  		
			Select Batch_Number, Tot_Qty = Sum(IsNull(Quantity, 0)), Rate = PTS, Tax = TaxSuffered  ,TOQ = Max(Isnull(TOQ,0))
				, TaxID = isnull(Batch_Products.GRNTaxID,0), 
				TaxType = Case When isnull(Batch_Products.TaxType,0) = 5 Then isnull(Batch_Products.GSTTaxType,0) Else isnull(Batch_Products.TaxType,0) End
			From Batch_Products  Where Convert(Nvarchar(10),DocDate,103) <= @Last_Close_Date  
				And Product_Code = @Product_code  
				And Quantity > 0  
				And IsNull(Damage,0) <> 0
				And isnull(Free,0) = 0	  	      
			Group By Batch_Number, PTS, TaxSuffered, Batch_Products.GRNTaxID, Batch_Products.TaxType, Batch_Products.GSTTaxType
			Having Sum(IsNull(Quantity,0))>0  Order By MIN(Batch_Code)  
		END  
		ELSE  
		BEGIN  
			If (select isnull(Claimstatus,0) from DandDAbstract where ID = @ID) =1
			BEGIN
				Select DD.Batch_Number,sum(DD.TotalQuantity),Rate = BP.PTS, Tax = BP.TaxSuffered ,TOQ = Max(Isnull(BP.TOQ,0))  
					, TaxID = isnull(BP.GRNTaxID,0), 
					TaxType = Case When isnull(BP.TaxType,0) = 5 Then isnull(BP.GSTTaxType,0) Else isnull(BP.TaxType,0) End
				From Batch_Products BP,DandDDetail DD where DD.ID=@ID and DD.Product_code=@Product_code  
					And DD.Batch_code=BP.Batch_code 
					And Convert(Nvarchar(10),BP.DocDate,103) <= @Last_Close_Date
					And BP.Quantity > 0
					And IsNull(BP.Damage,0) <> 0
					And isnull(BP.Free,0) = 0	
				Group By DD.Batch_Number, BP.PTS, BP.TaxSuffered, BP.GRNTaxID, BP.TaxType, BP.GSTTaxType
				Having  Sum(isnull(BP.quantity,0))>0
				Order By MIN(BP.Batch_Code)  
			END
			ELSE
			BEGIN
				Select DD.Batch_Number,sum(DD.TotalQuantity),Rate = DD.PTS, Tax = DD.TaxSuffered ,TOQ = Max(Isnull(BP.TOQ,0))  
					, TaxID = isnull(BP.GRNTaxID,0), 
					TaxType = Case When isnull(BP.TaxType,0) = 5 Then isnull(BP.GSTTaxType,0) Else isnull(BP.TaxType,0) End
				From DandDDetail DD,Batch_Products BP where DD.ID=@ID and DD.Product_code=@Product_code  And DD.Batch_code=BP.Batch_code
				Group By DD.Batch_Number, DD.PTS, DD.TaxSuffered, BP.GRNTaxID, BP.TaxType, BP.GSTTaxType
				Order By MIN(DD.Batch_Code)  
			END
		END  
	End 
End
