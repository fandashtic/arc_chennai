CREATE PROCEDURE sp_get_InvInvalidItems(@INVOICEID INT)    
AS  
Declare @ProdcutName As Nvarchar(15)
Create Table #tmpInActiveProducts (Product_code nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
---Load InActive Items
Insert into #tmpInActiveProducts
select  I.Product_Code From Items I, InvoiceDetailReceived IDR  
WHERE I.Product_Code = IDR.Product_code   
And IDR.InvoiceID = @INVOICEID  
And Isnull(IDR.Product_Code,N'') in (select product_code from Items where active = 0)  
  
-- To Update Status for Existing Items  
UPDATE I SET I.Active=1 From Items I, InvoiceDetailReceived IDR  
WHERE I.Product_Code = IDR.Product_code   
And IDR.InvoiceID = @INVOICEID  
And Isnull(IDR.Product_Code,N'') in (select product_code from Items where active = 0) 

--DSTypeWiseSKU DataPost
If(Select Count(*) from #tmpInActiveProducts)>0
Begin
exec sp_DSTypeWiseSKU_DataPost
End

---Load Inactive Item in SchemeProducts Table
Declare CurInActiveProducts Cursor For Select Product_code From  #tmpInActiveProducts		    
   Open CurInActiveProducts    
	   Fetch Next From CurInActiveProducts Into @ProdcutName    
       While (@@Fetch_Status = 0)
	   Begin 	
		    exec Sp_Update_SchSKUDetail @ProdcutName
			Fetch Next From CurInActiveProducts Into @ProdcutName    
       End   
   Close CurInActiveProducts    
   Deallocate CurInActiveProducts 

Drop table #tmpInActiveProducts
 
-- To Show the received Items Not exists in Items   
SELECT Distinct InvoiceDetailReceived.ForumCode
FROM InvoiceDetailReceived      
WHERE InvoiceID = @INVOICEID  
And (IsNull(InvoiceDetailReceived.Product_Code,N'') NOT IN (SELECT PRODUCT_CODE FROM Items))
