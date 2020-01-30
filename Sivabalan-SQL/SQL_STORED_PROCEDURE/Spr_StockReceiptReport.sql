CREATE PROCEDURE Spr_StockReceiptReport(@Todate DateTime)
AS 
Begin 
	Set dateformat dmy
	Declare @WDCode As Nvarchar(255)
	Declare @WDDest As Nvarchar(255)
	Declare @CompaniesToUploadCode As Nvarchar(255)

	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload          
	Select Top 1 @WDCode = RegisteredOwner From Setup            
	          
	If @CompaniesToUploadCode='ITC001'          
	Begin          
	 Set @WDDest= @WDCode          
	End          
	Else          
	Begin          
	 Set @WDDest= @WDCode          
	 Set @WDCode= @CompaniesToUploadCode          
	End

	Create Table #Tmp (
		WDCode Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
		WDDest Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
		FromDate Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
		ToDate Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
		ItemCode Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
		ItemName Nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,
		[Purchase + Stock Transfer In] Decimal(18,6),
		[Van Stock (Asondate)] Decimal(18,6))

	Insert Into #Tmp (WDCode,WDDest,FromDate,ToDate,ItemCode,ItemName)
	select @WDCode,@WDDest,Cast(Convert(Nvarchar(10),@Todate,103) as Nvarchar(10)),Cast(Convert(Nvarchar(10),@Todate,103) as Nvarchar(10)),Product_Code,ProductName from Items 

	Update T Set T.[Purchase + Stock Transfer In] = B.Quantity From #Tmp T,
	(Select Distinct Product_Code,Sum(Isnull(QuantityReceived,0)) Quantity From GRNDetail 
	Where GRNID in (Select Distinct GRNID from GRNAbstract Where Cast(Convert(Nvarchar(10),GRNDate,103) as DateTime) Between @Todate And @Todate and (isnull(GRNStatus,0) & 64) = 0 And (isnull(GRNStatus,0) & 32) = 0  ) 
	Group By Product_Code) B
	Where B.Product_Code= T.ItemCode

	Update T Set T.[Purchase + Stock Transfer In] = (Isnull([Purchase + Stock Transfer In],0) + Isnull(STI.Quantity,0)) From #Tmp T,
	(Select Distinct Product_Code,Sum(Isnull(Quantity,0)) Quantity From StockTransferInDetail 
	Where DocSerial in (Select Distinct DocSerial from StockTransferInAbstract Where Cast(Convert(Nvarchar(10),DocumentDate,103) as DateTime) Between @Todate And @Todate and IsNull(Status, 0) & 192 = 0) 
	Group By Product_Code) STI
	Where STI.Product_Code= T.ItemCode

-- To get only pending quantity in van

	-- Update T Set T.[Van Stock] = Isnull(Van.Quantity,0) From #Tmp T,
	-- (Select Distinct Product_Code,Sum(Isnull(Quantity,0)) Quantity From VanStatementDetail 
	-- Where DocSerial in (Select Distinct DocSerial from VanStatementAbstract Where Cast(Convert(Nvarchar(10),DocumentDate,103) as DateTime) Between @Todate And @Todate and isnull(Status ,0) = 0) 
	-- Group By Product_Code) Van
	-- Where Van.Product_Code= T.ItemCode
	
	Update T Set T.[Van Stock (Asondate)] = Isnull(Van.Quantity,0) From #Tmp T,
	(Select Distinct Product_Code,Sum(Isnull(Pending,0)) Quantity From VanStatementDetail 
	Where DocSerial in (Select Distinct DocSerial from VanStatementAbstract Where isnull(Status ,0) = 0) 
	Group By Product_Code) Van
	Where Van.Product_Code= T.ItemCode

	Select 1,* from #Tmp where [Purchase + Stock Transfer In] >0 or [Van Stock (Asondate)] > 0 Order By ItemCode Asc
	Drop Table #Tmp
End    
