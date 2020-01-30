CREATE procedure spr_customer_salesdetail(@CustId nvarchar(30), @UOM nvarchar(50), 
@StockVal nvarchar(10),@OpDate datetime,@Cldate datetime)        
as        
declare @ItemCode as nvarchar(50)        
declare @ItemName as nvarchar(50)        
declare @Opnqty Decimal(18,6)        
declare @OpeningValue Decimal(18,6)        
declare @ClosingValue Decimal(18,6)        
declare @ClQty Decimal(18,6)        
declare @PurQty Decimal(18,6)        
declare @PurchasedQty Decimal(18,6)        
declare @PurchaseReturn Decimal(18,6)        
declare @PurchaseReturnValue Decimal(18,6)        
declare @SaleQty Decimal(18,6)        
declare @PurchaseValue Decimal(18,6)        
declare @TrnQty Decimal(18,6)        
declare @InvoiceId int        
declare @DocRef nvarchar(30)        
declare @OpeningDate DateTime    
declare @cur_pur Cursor        
Declare @FirstLevel nvarchar(50)
Declare @LastLevel nvarchar(50)
Declare @ParentCat nvarchar(50)
Declare @CatName nvarchar(50)

SET @FirstLevel = dbo.GetHierarchyColumn(N'FIRST')
SET @LastLevel= dbo.GetHierarchyColumn(N'LAST')

CREATE TABLE #tmpItem(ProductLevel1 nvarchar(50), ProductLevel2 nvarchar(50), OpeningQty Decimal(18,6), 
OpeningValue Decimal(18,6), Purchase Decimal(18,6), PurchaseValue Decimal(18,6), 
PurchaseReturn Decimal(18,6), PurchaseReturnValue Decimal(18,6), ClosingQty Decimal(18,6),ClosingValue Decimal(18,6), 
Sale Decimal(18,6), TrQty Decimal(18,6))        

IF @UOM = N'Sales UOM'
BEGIN
DECLARE cur_item CURSOR FOR
SELECT DISTINCT(product_code) FROM ItemClosingStock WHERE CustId=@CustId and ClosingDate between @OpDate and @ClDate        
SET @OpeningDate=dateadd(d,-1,@OpDate)    
OPEN cur_item        
FETCH NEXT FROM cur_item INTO @ItemCode        
WHILE(@@FETCH_STATUS=0)        
BEGIN 
	 SELECT @CatName = ItemCategories.Category_Name, @ParentCat = dbo.fn_FirstLevelCategory(Items.CategoryID) FROM Items, ItemCategories 
	 WHERE ItemCategories.CategoryID = Items.CategoryID And Items.Product_Code = @ItemCode
	 SELECT @OpnQty=IsNull(sum(quantity),0), @OpeningValue= IsNull(sum(quantity * Case @StockVal
	    WHEN N'PTSS' THEN Items.PTS
	    WHEN N'PTS' THEN Items.PTR
 	    WHEN N'ECP' THEN Items.ECP
	    WHEN N'PTR' THEN Items.Company_price
	    ELSE Items.Purchase_price END),0) FROM ItemClosingStock, Items WHERE Items.Product_Code = ItemClosingStock.product_code 
  	    And ItemClosingStock.Product_code=@Itemcode and ClosingDate=@OpeningDate AND CustID=@custID        
	 SELECT @ClQty=IsNull(sum(quantity),0), @ClosingValue = IsNull(sum(IsNull(quantity,0) * Case @StockVal
	    WHEN N'PTSS' THEN Items.PTS
	    WHEN N'PTS' THEN Items.PTR
 	    WHEN N'ECP' THEN Items.ECP
	    WHEN N'PTR' THEN Items.Company_price
	    ELSE Items.Purchase_price END),0) FROM ItemClosingStock, Items WHERE Items.Product_Code = ItemClosingStock.product_code 
	 And ItemClosingStock.Product_code=@Itemcode and ClosingDate=dbo.stripdatefromtime(@ClDate) and custId=@custId
	 SET @Cur_Pur=CURSOR FOR SELECT IsNull(InvoiceId,N''),DocReference FROM sentInvoices WHERE CustId = @CustId AND InvoiceDate BETWEEN @opDate AND @cldate           
	 OPEN @Cur_Pur        
	 FETCH NEXT FROM @cur_pur INTO @InvoiceId,@DocRef         
	 SET @purchasedqty=0        
	 SET @PurchaseReturnValue = 0
	 SET @PurchaseValue = 0
	 WHILE(@@Fetch_status=0)        
	 BEGIN 
	    SELECT @PurQty=IsNull(sum(quantity),0), @PurchaseValue = @PurchaseValue + IsNull(sum(IsNull(quantity,0) * Case @StockVal
	    WHEN N'PTSS' THEN Items.PTS
	    WHEN N'PTS' THEN Items.PTR
 	    WHEN N'ECP' THEN Items.ECP
	    WHEN N'PTR' THEN Items.Company_price
	    ELSE Items.Purchase_price END),0)  FROM Invoiceabstract, Invoicedetail, Items 
	    WHERE Items.Product_Code = InvoiceDetail.Product_Code And documentId=IsNull(@InvoiceID,N'') and DocReference=Ltrim(@DocRef) 
	    AND Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId and customerId=@custId 
	    AND InvoiceDetail.product_code=@Itemcode and invoicetype <> 4     

	    SELECT @PurchaseReturn=IsNull(sum(quantity),0), @PurchaseReturnValue = @PurchaseReturnValue + IsNull(sum(IsNull(quantity,0) * Case @StockVal
	    WHEN N'PTSS' THEN Items.PTS
	    WHEN N'PTS' THEN Items.PTR
 	    WHEN N'ECP' THEN Items.ECP
	    WHEN N'PTR' THEN Items.Company_price
	    ELSE Items.Purchase_price END),0)  FROM Invoiceabstract, Invoicedetail, Items 
	    WHERE Items.Product_Code = InvoiceDetail.Product_Code And documentId=IsNull(@InvoiceID,N'') and DocReference=Ltrim(@DocRef) 
	    AND Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId and customerId=@custId And (InvoiceAbstract.Status & 128) = 0 And
	    (InvoiceAbstract.Status & 32) = 0 And InvoiceDetail.product_code=@Itemcode and Invoicetype = 4
       
	    SET @PurchasedQty=@PurchasedQty + isNull(@PurQty,0)        
	    FETCH NEXT FROM @cur_pur INTO @InvoiceId,@DocRef        
	 End              
	 CLOSE @cur_pur        
	 DEALLOCATE @cur_pur        
	 SET @SaleQty=Isnull(@OpnQty,0)+@PurchasedQty-IsNull(@ClQty,0)        
	 SELECT @Trnqty=IsNull(sum(quantity),0) FROM invoiceabstract,invoicedetail WHERE CustomerId=@CustId and dbo.stripdatefromtime(Invoicedate) between @opDate and @cldate  and Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId and invoicetype<>4                  
	 and Product_code=@ItemCode and (status & 128=0) and (status & 64)=0                  
         SET @TrnQty=Isnull(@Trnqty,0)-@Purchasedqty                  
	 INSERT INTO #tmpItem values(@ParentCat, @CatName, @OpnQty, @OpeningValue, 
	 @PurchasedQty,@PurchaseValue, @PurchaseReturn, @PurchaseReturnValue,@ClQty, @ClosingValue, @SaleQty,@TrnQty)        
	 FETCH NEXT FROM cur_item INTO @ItemCode        
	End        
	CLOSE cur_item        
	DEALLOCATE cur_item        
END
ELSE IF @UOM = N'Conversion Factor'
BEGIN
	DECLARE cur_item CURSOR FOR
	SELECT DISTINCT(product_code) FROM ItemClosingStock WHERE CustId=@CustId and ClosingDate between @OpDate and @ClDate        
	SET @OpeningDate=dateadd(d,-1,@OpDate)    
	OPEN cur_item        
	FETCH NEXT FROM cur_item INTO @ItemCode        
	WHILE(@@FETCH_STATUS=0)        
	BEGIN 
		 SELECT @CatName = ItemCategories.Category_Name, @ParentCat = dbo.fn_FirstLevelCategory(Items.CategoryID) FROM Items, ItemCategories 
		 WHERE ItemCategories.CategoryID = Items.CategoryID And Items.Product_Code = @ItemCode
		 SELECT @OpnQty=sum(IsNull(quantity,0) * IsNull(Items.ConversionFactor,0)), @OpeningValue= IsNull(sum(IsNull(quantity,0) * Case @StockVal
		    WHEN N'PTSS' THEN Items.PTS
		    WHEN N'PTS' THEN Items.PTR
	 	    WHEN N'ECP' THEN Items.ECP
		    WHEN N'PTR' THEN Items.Company_price
		    ELSE Items.Purchase_price END),0) FROM ItemClosingStock, Items WHERE Items.Product_Code = ItemClosingStock.product_code 
	  	    And ItemClosingStock.Product_code=@Itemcode and ClosingDate=@OpeningDate AND CustID=@custID        
		 SELECT @ClQty=sum(IsNull(quantity,0) * IsNull(Items.ConversionFactor,0)), @ClosingValue = IsNull(sum(IsNull(quantity,0) * Case @StockVal
		    WHEN N'PTSS' THEN Items.PTS
		    WHEN N'PTS' THEN Items.PTR
	 	    WHEN N'ECP' THEN Items.ECP
		    WHEN N'PTR' THEN Items.Company_price
		    ELSE Items.Purchase_price END),0) FROM ItemClosingStock, Items WHERE Items.Product_Code = ItemClosingStock.product_code 
		 And ItemClosingStock.Product_code=@Itemcode and ClosingDate=dbo.stripdatefromtime(@ClDate) and custId=@custId
		 SET @Cur_Pur=CURSOR FOR SELECT IsNull(InvoiceId,N''),DocReference FROM sentInvoices WHERE CustId = @CustId AND InvoiceDate BETWEEN @opDate AND @cldate           
		 OPEN @Cur_Pur        
		 FETCH NEXT FROM @cur_pur INTO @InvoiceId,@DocRef         
		 SET @purchasedqty=0        
		 SET @PurchaseReturnValue = 0
		 SET @PurchaseValue = 0
		 WHILE(@@Fetch_status=0)        
		 BEGIN 
		    SELECT @PurQty=sum(IsNull(quantity,0) * IsNull(Items.ConversionFactor,0)), @PurchaseValue = @PurchaseValue + IsNull(sum(IsNull(quantity,0) * Case @StockVal
		    WHEN N'PTSS' THEN Items.PTS
		    WHEN N'PTS' THEN Items.PTR
	 	    WHEN N'ECP' THEN Items.ECP
		    WHEN N'PTR' THEN Items.Company_price
		    ELSE Items.Purchase_price END),0)  FROM Invoiceabstract, Invoicedetail, Items 
		    WHERE Items.Product_Code = InvoiceDetail.Product_Code And documentId=IsNull(@InvoiceID,N'') and DocReference=Ltrim(@DocRef) 
		    AND Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId and customerId=@custId 
		    AND InvoiceDetail.product_code=@Itemcode and invoicetype <> 4                   
	
		    SELECT @PurchaseReturn=sum(IsNull(quantity,0) * IsNull(Items.ConversionFactor,0)), @PurchaseReturnValue = @PurchaseReturnValue + IsNull(sum(IsNull(quantity,0) * Case @StockVal
		    WHEN N'PTSS' THEN Items.PTS
		    WHEN N'PTS' THEN Items.PTR
	 	    WHEN N'ECP' THEN Items.ECP
		    WHEN N'PTR' THEN Items.Company_price
		    ELSE Items.Purchase_price END),0)  FROM Invoiceabstract, Invoicedetail, Items 
		    WHERE Items.Product_Code = InvoiceDetail.Product_Code And documentId=IsNull(@InvoiceID,N'') and DocReference=Ltrim(@DocRef) 
		    AND Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId and customerId=@custId And (InvoiceAbstract.Status & 128) = 0 And
		    (InvoiceAbstract.Status & 32) = 0 And InvoiceDetail.product_code=@Itemcode and Invoicetype = 4
	       
		    SET @PurchasedQty=@PurchasedQty + isNull(@PurQty,0)        
		    FETCH NEXT FROM @cur_pur INTO @InvoiceId,@DocRef        
		 End              
		 CLOSE @cur_pur        
		 DEALLOCATE @cur_pur        
		 SET @SaleQty=Isnull(@OpnQty,0)+@PurchasedQty-IsNull(@ClQty,0)        
		 SELECT @Trnqty=sum(IsNull(quantity,0) * IsNull(Items.ConversionFactor,0)) FROM invoiceabstract,invoicedetail, Items WHERE CustomerId=@CustId and dbo.stripdatefromtime(Invoicedate) between @opDate and @cldate  and Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId and invoicetype<>4                  
		 And Items.Product_Code = InvoiceDetail.Product_Code and InvoiceDetail.Product_code=@ItemCode and (status & 128=0) and (status & 64)=0                  
	         SET @TrnQty=Isnull(@Trnqty,0)-@Purchasedqty                  
		 INSERT INTO #tmpItem values(@ParentCat, @CatName, @OpnQty, @OpeningValue, 
		 @PurchasedQty,@PurchaseValue, @PurchaseReturn, @PurchaseReturnValue,@ClQty, @ClosingValue, @SaleQty,@TrnQty)        
		 FETCH NEXT FROM cur_item INTO @ItemCode        
		End        
		CLOSE cur_item        
		DEALLOCATE cur_item        
END
ELSE
BEGIN
	DECLARE cur_item CURSOR FOR
	SELECT DISTINCT(product_code) FROM ItemClosingStock WHERE CustId=@CustId and ClosingDate between @OpDate and @ClDate        
	SET @OpeningDate=dateadd(d,-1,@OpDate)    
	OPEN cur_item        
	FETCH NEXT FROM cur_item INTO @ItemCode        
	WHILE(@@FETCH_STATUS=0)        
	BEGIN 
		 SELECT @CatName = ItemCategories.Category_Name, @ParentCat = dbo.fn_FirstLevelCategory(Items.CategoryID) FROM Items, ItemCategories 
		 WHERE ItemCategories.CategoryID = Items.CategoryID And Items.Product_Code = @ItemCode
		 SELECT @OpnQty=sum(IsNull(quantity,0) / Case IsNull(Items.ReportingUnit,0) WHEN 0 THEN 1 ELSE IsNull(Items.ReportingUnit,0) END), @OpeningValue= IsNull(sum(IsNull(quantity,0) * Case @StockVal
		    WHEN N'PTSS' THEN Items.PTS
		    WHEN N'PTS' THEN Items.PTR
	 	    WHEN N'ECP' THEN Items.ECP
		    WHEN N'PTR' THEN Items.Company_price
		    ELSE Items.Purchase_price END),0) FROM ItemClosingStock, Items WHERE Items.Product_Code = ItemClosingStock.product_code 
	  	    And ItemClosingStock.Product_code=@Itemcode and ClosingDate=@OpeningDate AND CustID=@custID        
		 SELECT @ClQty=sum(IsNull(quantity,0) / Case IsNull(Items.ReportingUnit,0) WHEN 0 THEN 1 ELSE IsNull(Items.ReportingUnit,0) END), @ClosingValue = IsNull(sum(IsNull(quantity,0) * Case @StockVal
		    WHEN N'PTSS' THEN Items.PTS
		    WHEN N'PTS' THEN Items.PTR
	 	    WHEN N'ECP' THEN Items.ECP
		    WHEN N'PTR' THEN Items.Company_price
		    ELSE Items.Purchase_price END),0) FROM ItemClosingStock, Items WHERE Items.Product_Code = ItemClosingStock.product_code 
		 And ItemClosingStock.Product_code=@Itemcode and ClosingDate=dbo.stripdatefromtime(@ClDate) and custId=@custId
		 SET @Cur_Pur=CURSOR FOR SELECT IsNull(InvoiceId,N''),DocReference FROM sentInvoices WHERE CustId = @CustId AND InvoiceDate BETWEEN @opDate AND @cldate           
		 OPEN @Cur_Pur        
		 FETCH NEXT FROM @cur_pur INTO @InvoiceId,@DocRef         
		 SET @purchasedqty=0        
		 SET @PurchaseReturnValue = 0
		 SET @PurchaseValue = 0
		 WHILE(@@Fetch_status=0)        
		 BEGIN 
		    SELECT @PurQty=sum(IsNull(quantity,0) / Case IsNull(Items.ReportingUnit,0) WHEN 0 THEN 1 ELSE IsNull(Items.ReportingUnit,0) END), @PurchaseValue = @PurchaseValue + IsNull(sum(IsNull(quantity,0) * Case @StockVal
		    WHEN N'PTSS' THEN Items.PTS
		    WHEN N'PTS' THEN Items.PTR
	 	    WHEN N'ECP' THEN Items.ECP
		    WHEN N'PTR' THEN Items.Company_price
		    ELSE Items.Purchase_price END),0)  FROM Invoiceabstract, Invoicedetail, Items 
		    WHERE Items.Product_Code = InvoiceDetail.Product_Code And documentId=IsNull(@InvoiceID,N'') and DocReference=Ltrim(@DocRef) 
		    AND Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId and customerId=@custId 
		    AND InvoiceDetail.product_code=@Itemcode and invoicetype <> 4                   
	
		    SELECT @PurchaseReturn=sum(IsNull(quantity,0) / Case IsNull(Items.ReportingUnit,0) WHEN 0 THEN 1 ELSE IsNull(Items.ReportingUnit,0) END), @PurchaseReturnValue = @PurchaseReturnValue + IsNull(sum(IsNull(quantity,0) * Case @StockVal
		    WHEN N'PTSS' THEN Items.PTS
		    WHEN N'PTS' THEN Items.PTR
	 	    WHEN N'ECP' THEN Items.ECP
		    WHEN N'PTR' THEN Items.Company_price
		    ELSE Items.Purchase_price END),0)  FROM Invoiceabstract, Invoicedetail, Items 
		    WHERE Items.Product_Code = InvoiceDetail.Product_Code And documentId=IsNull(@InvoiceID,N'') and DocReference=Ltrim(@DocRef) 
		    AND Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId and customerId=@custId And (InvoiceAbstract.Status & 128) = 0 And
		    (InvoiceAbstract.Status & 32) = 0 And InvoiceDetail.product_code=@Itemcode and Invoicetype = 4
	       
		    SET @PurchasedQty=@PurchasedQty + isNull(@PurQty,0)        
		    FETCH NEXT FROM @cur_pur INTO @InvoiceId,@DocRef        
		 End              
		 CLOSE @cur_pur        
		 DEALLOCATE @cur_pur        
		 SET @SaleQty=Isnull(@OpnQty,0)+@PurchasedQty-IsNull(@ClQty,0)        
		 SELECT @Trnqty=sum(IsNull(quantity,0) / Case IsNull(Items.ReportingUnit,0) WHEN 0 THEN 1 ELSE IsNull(Items.ReportingUnit,0) END) FROM invoiceabstract,invoicedetail, Items WHERE CustomerId=@CustId and dbo.stripdatefromtime(Invoicedate) between @opDate and @cldate  and Invoiceabstract.InvoiceId=InvoiceDetail.InvoiceId and invoicetype<>4                  
		 And Items.Product_Code = InvoiceDetail.Product_Code and InvoiceDetail.Product_code=@ItemCode and (status & 128=0) and (status & 64)=0                  
	         SET @TrnQty=Isnull(@Trnqty,0)-@Purchasedqty                  
		 INSERT INTO #tmpItem values(@ParentCat, @CatName, @OpnQty, @OpeningValue, 
		 @PurchasedQty,@PurchaseValue, @PurchaseReturn, @PurchaseReturnValue,@ClQty, @ClosingValue, @SaleQty,@TrnQty)        
		 FETCH NEXT FROM cur_item INTO @ItemCode        
		End        
		CLOSE cur_item        
		DEALLOCATE cur_item        
END

EXEC(N'Select [ProductLevel2], [ProductLevel1] As "' + @FirstLevel + N'", [ProductLevel2] As "' + @LastLevel + N'", 
"Opening Quantity"=Sum(Isnull(OpeningQty,0)), "Opening Value" = Sum(OpeningValue), 
"Purchase" = Sum(IsNull(Purchase,0)), "Purchase Value" = Sum(IsNull(PurchaseValue,0)), 
"Purchase Return" = Sum(IsNull(PurchaseReturn,0)), "Purchase Return Value" = Sum(IsNull(PurchaseReturnValue,0)), 
"Closing Quantity" = Sum(Isnull(ClosingQty,0)), "Closing Value" = Sum(ClosingValue), 
"Sale" = Sum(IsNull(Sale,0)), "TransitStock" = Sum(IsNull(TrQty,0)) FROM #tmpItem
GROUP BY [ProductLevel2], [ProductLevel1]')
 
DROP TABLE #tmpItem        
    

