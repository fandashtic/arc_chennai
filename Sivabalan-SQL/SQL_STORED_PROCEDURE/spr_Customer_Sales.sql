CREATE procedure spr_Customer_Sales(@CustId nvarchar(2550), @UOM nvarchar(50), 
@StockVal nvarchar(10), @OpnDate datetime,@ClDate datetime)                  
as                  
Declare @Purchase Decimal(18,6)                  
Declare @CloseDate datetime              
Declare @PurchasedQty Decimal(18,6)                  
Declare @ClosingQty Decimal(18,6)                  
Declare @OpQty Decimal(18,6)                  
Declare @SaleQty Decimal(18,6)                  
Declare @PurchaseReturn Decimal(18,6)                  
Declare @PurchaseReturnValue Decimal(18,6)
Declare @InvoiceId int                  
Declare @DocRef nvarchar(30)                  
Declare @CustCode nvarchar(30)                  
Declare @CustName nvarchar(30)                  
Declare @TransistQty Decimal(18,6)                  
Declare @OpeningDate datetime                
Declare @ClosingDate datetime              
Declare @cur_pur Cursor                    

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  

create table #tmpCust1(Company_Name nvarchar(255))

if @CustId =N'%'
   insert into #tmpCust1 select company_name from customer
else
   insert into #tmpCust1 select * from dbo.sp_SplitIn2Rows(@CustId, @Delimeter)


CREATE TABLE #tmpCust(CustId nvarchar(30),CustName nvarchar(50),OpDate datetime,ClDate datetime,OpStk Decimal(18,6),
ClStock Decimal(18,6),Purchase Decimal(18,6), PurchaseReturn Decimal(18,6), PurchaseReturnValue Decimal(18,6),
Sale decimal(18,6),TrStk Decimal(18,6))                  

IF @UOM = N'Sales UOM'
BEGIN
	Declare Cur_Cust Cursor FOR SELECT DISTINCT(CustId) FROM ItemClosingStock WHERE CustId 
In (select Company_Name from #tmpCust1) and ClosingDate BETWEEN @OpnDate AND @ClDate
	SET @OpeningDate= DateAdd(d,-1,@OpnDate)  

	OPEN Cur_Cust                  
	FETCH NEXT FROM cur_cust INTO @CustCode          
	WHILE(@@FETCH_STATUS=0)                  
	BEGIN
	 SELECT @OpQty= Sum(Quantity) FROM ItemClosingstock WHERE CustId =@CustCode AND ClosingDate= @OpeningDate  
	 SELECT @ClosingQty=sum(Quantity) FROM ItemClosingstock WHERE CustId = @CustCode AND ClosingDate=dbo.StripDateFromTime(@Cldate)          
	 SET @Cur_pur= CURSOR FOR SELECT IsNull(InvoiceId,N''),DocReference FROM sentInvoices WHERE CustId = @Custcode AND InvoiceDate BETWEEN @opnDate AND @cldate        
		 OPEN @Cur_pur                  
		 FETCH NEXT FROM @Cur_Pur INTO @InvoiceId,@DocRef                  
		 SET @PurchasedQty=0   
		 SET @PurchaseReturn = 0               
		 SET @PurchaseReturnValue = 0
		 WHILE(@@FETCH_STATUS=0)                  
		 BEGIN                 
			  SELECT @Purchase=Sum(quantity) FROM InvoiceAbstract,InvoiceDetail 
			  WHERE DocumentId=IsNull(@InvoiceID,N'') AND DocReference=@DocRef AND 
			  Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId AND CustomerId = @CustCode AND Invoicetype <> 4                 

			  SELECT @PurchaseReturn = @PurchaseReturn + IsNull(Sum(quantity),0), @PurchaseReturnValue = @PurchaseReturnValue + IsNull(Sum(Quantity * Case @StockVal
			  WHEN N'PTSS' THEN Items.PTS
			  WHEN N'PTS' THEN Items.PTR
			  WHEN N'ECP' THEN Items.ECP
			  WHEN N'PTR' THEN Items.Company_Price
			  ELSE Items.Purchase_price END),0)
			  FROM InvoiceAbstract,InvoiceDetail, Items WHERE Items.Product_Code = InvoiceDetail.Product_Code And DocumentId=IsNull(@InvoiceID,N'') 
			  AND DocReference=@DocRef AND (InvoiceAbstract.Status & 128)=0  AND (InvoiceAbstract.Status & 32)= 0 And Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId 
			  AND CustomerId = @CustCode AND Invoicetype = 4                 

			  SET @PurchasedQty=@PurchasedQty + Isnull(@Purchase,0)                 
			  FETCH NEXT FROM @Cur_Pur INTO @InvoiceId,@DocRef                    
		 END 
		 CLOSE @cur_pur                   
		 DEALLOCATE @cur_pur                  
	 SELECT @CustName=Company_Name FROM Customer WHERE CustomerId=@CustCode                  
	 SET @SaleQty= @PurchasedQty + IsNull(@OpQty,0) - IsNull(@ClosingQty,0)                  
	 SELECT @Transistqty= Sum(quantity) FROM invoiceabstract,invoicedetail WHERE CustomerId=@CustCode and dbo.StripDateFromTime(InvoiceDate) between @OpnDate and @Cldate and Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId and Invoicetype <> 4                 
	 AND (Status & 128)=0 AND (Status & 64)=0                  
	 SET @TransistQty= IsNull(@Transistqty,0)-@Purchasedqty                  
	 INSERT INTO #tmpCust VALUES(@CustCode,@CustName,@OpnDate,@ClDate,@OpQty,@ClosingQty,@PurchasedQty,@PurchaseReturn, @PurchaseReturnValue, @SaleQty,@TransistQty)                  
	 FETCH NEXT FROM cur_cust INTO @CustCode          
	END                
	CLOSE cur_cust                  
	DEALLOCATE cur_cust                   
END
ELSE IF @UOM = N'Conversion Factor'
BEGIN
	Declare Cur_Cust Cursor FOR SELECT DISTINCT(CustId) FROM ItemClosingStock WHERE CustId In (select Company_Name from #tmpCust1) and ClosingDate BETWEEN @OpnDate AND @ClDate
	SET @OpeningDate= DateAdd(d,-1,@OpnDate)  
	OPEN Cur_Cust                  
	FETCH NEXT FROM cur_cust INTO @CustCode          
	WHILE(@@FETCH_STATUS=0)                  
	BEGIN
	 SELECT @OpQty= Sum(Quantity * IsNull(Items.ConversionFactor,0)) FROM ItemClosingstock, Items 
	 WHERE Items.Product_Code = ItemClosingStock.Product_Code And CustId =@CustCode AND ClosingDate= @OpeningDate
	 SELECT @ClosingQty=sum(Quantity * IsNull(Items.ConversionFactor,0)) FROM ItemClosingstock, Items
	 WHERE Items.Product_Code = ItemClosingStock.Product_Code And CustId = @CustCode AND ClosingDate=dbo.StripDateFromTime(@Cldate)          
	 SET @Cur_pur= CURSOR FOR SELECT IsNull(InvoiceId,N''),DocReference FROM sentInvoices WHERE CustId = @Custcode AND InvoiceDate BETWEEN @opnDate AND @cldate        
		 OPEN @Cur_pur                  
		 FETCH NEXT FROM @Cur_Pur INTO @InvoiceId,@DocRef                  
		 SET @PurchasedQty=0   
		 SET @PurchaseReturn = 0               
		 SET @PurchaseReturnValue = 0
		 WHILE(@@FETCH_STATUS=0)                  
		 BEGIN                 
			  SELECT @Purchase=Sum(quantity * Items.ConversionFactor) FROM InvoiceAbstract,InvoiceDetail, Items
			  WHERE Items.Product_Code = InvoiceDetail.Product_Code And DocumentId=IsNull(@InvoiceID,N'') AND DocReference=@DocRef AND 
			  Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId AND CustomerId = @CustCode AND Invoicetype <> 4                 

			  SELECT @PurchaseReturn = @PurchaseReturn + IsNull(Sum(quantity * Items.ConversionFactor),0), @PurchaseReturnValue = @PurchaseReturnValue + IsNull(Sum(Quantity * Case @StockVal
			  WHEN N'PTSS' THEN Items.PTS
			  WHEN N'PTS' THEN Items.PTR
			  WHEN N'ECP' THEN Items.ECP
			  WHEN N'PTR' THEN Items.Company_Price
			  ELSE Items.Purchase_price END),0)
			  FROM InvoiceAbstract,InvoiceDetail, Items WHERE Items.Product_Code = InvoiceDetail.Product_Code And DocumentId=IsNull(@InvoiceID,N'') 
			  AND DocReference=@DocRef AND (InvoiceAbstract.Status & 128)=0  AND (InvoiceAbstract.Status & 32)= 0 And Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId 
			  AND CustomerId = @CustCode AND Invoicetype = 4                 

			  SET @PurchasedQty=@PurchasedQty + Isnull(@Purchase,0)                 
			  FETCH NEXT FROM @Cur_Pur INTO @InvoiceId,@DocRef                    
		 END 
		 CLOSE @cur_pur                   
		 DEALLOCATE @cur_pur                  
	 SELECT @CustName=Company_Name FROM Customer WHERE CustomerId=@CustCode                  
	 SET @SaleQty= @PurchasedQty + IsNull(@OpQty,0) - IsNull(@ClosingQty,0)                  
	 SELECT @Transistqty= Sum(quantity * IsNull(Items.ConversionFactor,0)) FROM invoiceabstract,invoicedetail, Items 
	 WHERE Items.Product_Code = InvoiceDetail.Product_Code And CustomerId=@CustCode 
	 And dbo.StripDateFromTime(InvoiceDate) between @OpnDate and @Cldate 
	 and Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId and Invoicetype <> 4                 
	 AND (Status & 128)=0 AND (Status & 64)=0                  

	 SET @TransistQty= IsNull(@Transistqty,0)-@Purchasedqty                  
	 INSERT INTO #tmpCust VALUES(@CustCode,@CustName,@OpnDate,@ClDate,@OpQty,@ClosingQty,@PurchasedQty,@PurchaseReturn, @PurchaseReturnValue, @SaleQty,@TransistQty)                  
	 FETCH NEXT FROM cur_cust INTO @CustCode          
	END                
	CLOSE cur_cust                  
	DEALLOCATE cur_cust                   
END
ELSE
BEGIN
	Declare Cur_Cust Cursor FOR SELECT DISTINCT(CustId) FROM ItemClosingStock WHERE CustId In (select Company_Name from #tmpCust1) and ClosingDate BETWEEN @OpnDate AND @ClDate
	SET @OpeningDate= DateAdd(d,-1,@OpnDate)  
	OPEN Cur_Cust                  
	FETCH NEXT FROM cur_cust INTO @CustCode          
	WHILE(@@FETCH_STATUS=0)                  
	BEGIN
	 SELECT @OpQty= Sum(Quantity / CASE IsNull(Items.ReportingUnit,0) WHEN 0 THEN 1 ELSE IsNull(Items.ReportingUnit,0) END) FROM ItemClosingstock, Items 
	 WHERE Items.Product_Code = ItemClosingStock.Product_Code And CustId =@CustCode AND ClosingDate= @OpeningDate  
	 SELECT @ClosingQty=sum(Quantity / CASE IsNull(Items.ReportingUnit,0) WHEN 0 THEN 1 ELSE IsNull(Items.ReportingUnit,0) END) FROM ItemClosingstock, Items
	 WHERE Items.Product_Code = ItemClosingStock.Product_Code And CustId = @CustCode AND ClosingDate=dbo.StripDateFromTime(@Cldate)          
	 SET @Cur_pur= CURSOR FOR SELECT IsNull(InvoiceId,N''),DocReference FROM sentInvoices WHERE CustId = @Custcode AND InvoiceDate BETWEEN @opnDate AND @cldate        
		 OPEN @Cur_pur                  
		 FETCH NEXT FROM @Cur_Pur INTO @InvoiceId,@DocRef                  
		 SET @PurchasedQty=0   
		 SET @PurchaseReturn = 0               
		 SET @PurchaseReturnValue = 0
		 WHILE(@@FETCH_STATUS=0)                  
		 BEGIN                 
			  SELECT @Purchase=Sum(quantity / CASE IsNull(Items.ReportingUnit,0) WHEN 0 THEN 1 ELSE IsNull(Items.ReportingUnit,0) END) FROM InvoiceAbstract,InvoiceDetail, Items
			  WHERE Items.Product_Code = InvoiceDetail.Product_Code And DocumentId=IsNull(@InvoiceID,N'') AND DocReference=@DocRef AND 
			  Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId AND CustomerId = @CustCode AND Invoicetype <> 4                 

			  SELECT @PurchaseReturn = @PurchaseReturn + IsNull(Sum(quantity / CASE IsNull(Items.ReportingUnit,0) WHEN 0 THEN 1 ELSE IsNull(Items.ReportingUnit,0) END),0), @PurchaseReturnValue = @PurchaseReturnValue + IsNull(Sum(Quantity * Case @StockVal
			  WHEN N'PTSS' THEN Items.PTS
			  WHEN N'PTS' THEN Items.PTR
			  WHEN N'ECP' THEN Items.ECP
			  WHEN N'PTR' THEN Items.Company_Price
			  ELSE Items.Purchase_price END),0)
			  FROM InvoiceAbstract,InvoiceDetail, Items WHERE Items.Product_Code = InvoiceDetail.Product_Code And DocumentId=IsNull(@InvoiceID,N'') 
			  AND DocReference=@DocRef AND (InvoiceAbstract.Status & 128)=0  AND (InvoiceAbstract.Status & 32)= 0 And Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId 
			  AND CustomerId = @CustCode AND Invoicetype = 4                 

			  SET @PurchasedQty=@PurchasedQty + Isnull(@Purchase,0)                 
			  FETCH NEXT FROM @Cur_Pur INTO @InvoiceId,@DocRef                    
		 END 
		 CLOSE @cur_pur                   
		 DEALLOCATE @cur_pur                  
	 SELECT @CustName=Company_Name FROM Customer WHERE CustomerId=@CustCode                  
	 SET @SaleQty= @PurchasedQty + IsNull(@OpQty,0) - IsNull(@ClosingQty,0)                  
	 SELECT @Transistqty= Sum(quantity / CASE IsNull(Items.ReportingUnit,0) WHEN 0 THEN 1 ELSE IsNull(Items.ReportingUnit,0) END) FROM invoiceabstract,invoicedetail, Items 
	 WHERE Items.Product_Code = InvoiceDetail.Product_Code And CustomerId=@CustCode 
	 And dbo.StripDateFromTime(InvoiceDate) between @OpnDate and @Cldate 
	 and Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId and Invoicetype <> 4                 
	 AND (Status & 128)=0 AND (Status & 64)=0                  

	 SET @TransistQty= IsNull(@Transistqty,0)-@Purchasedqty                  
	 INSERT INTO #tmpCust VALUES(@CustCode,@CustName,@OpnDate,@ClDate,@OpQty,@ClosingQty,@PurchasedQty,@PurchaseReturn, @PurchaseReturnValue, @SaleQty,@TransistQty)                  
	 FETCH NEXT FROM cur_cust INTO @CustCode          
	END                
	CLOSE cur_cust                  
	DEALLOCATE cur_cust                   
END

SELECT custId,CustId AS CustomerID, CustName AS CustomerName,"Opening Date"= Max(opDate),"Closing Date"= Max(clDate), IsNull(Sum(OpStk),0) AS OpeningStock,IsNull(Sum(ClStock),0) AS ClosingStock,Isnull(Sum(Purchase),0) AS Purchase, "Purchase Return" = Sum(PurchaseReturn), 
"Purchase Return Value" = Sum(PurchaseReturnValue), Isnull(Sum(Sale),0) as Sale,Isnull(Sum(TrStk),0) AS TransitStock FROM #tmpCust        
GROUP BY CustId,CustName ORDER BY custId                  

DROP TABLE #tmpCust                    
drop table #tmpCust1        


