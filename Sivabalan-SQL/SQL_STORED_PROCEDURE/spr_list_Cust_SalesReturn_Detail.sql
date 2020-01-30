  
Create Procedure spr_list_Cust_SalesReturn_Detail(      
@CUSTOMER nVarChar(255),@FROMDATE DATETIME,@TODATE DATETIME    
)      
AS      
Declare @INVOICEPREFIX As nVarchar(50)    
Select @INVOICEPREFIX = IsNull(Prefix,'') from VoucherPrefix Where TranID =N'INVOICE'    
Create Table #temp1(    
    ProductCode nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,    
    ProductName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,    
    BatchNumber nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,    
    Quantity Decimal(18,6),    
    Amount Decimal(18,6),    
    InvoiceNo nVarchar(500)	COLLATE SQL_Latin1_General_CP1_CI_AS)    
    
Create Table #temp2(    
    ID Int Identity(1,1),    
    ProductCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,    
    ProductName nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS,    
    BatchNumber nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,    
    Quantity Decimal(18,6),    
    Amount Decimal(18,6),    
    InvoiceNo nVarchar(500) COLLATE SQL_Latin1_General_CP1_CI_AS)    
    
Insert into #temp1(ProductCode,ProductName,BatchNumber,Quantity,Amount,InvoiceNo)    
Select Items.Product_Code,Items.ProductName,InvoiceDetail.Batch_Number,     
Sum(InvoiceDetail.Quantity),Sum(InvoiceDetail.Amount),Case When IsNull(InvoiceAbstract.DocumentID,0) = 0 Then '' Else @INVOICEPREFIX + Cast(InvoiceAbstract.DocumentID As nvarchar(50)) End       
From InvoiceDetail, InvoiceAbstract, Customer, Items       
Where       
 InvoiceAbstract.InvoiceID =  InvoiceDetail.InvoiceID   
And Customer.CustomerID =  InvoiceAbstract.CustomerID   
And Customer.Company_Name = @CUSTOMER   
And InvoiceAbstract.InvoiceType in (4,5)   
And InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE   
And IsNull(InvoiceAbstract.Status,0) & 192 = 0   
And Items.Product_Code = InvoiceDetail.Product_code       
Group By Items.Product_Code,Items.Product_Code,Items.ProductName,InvoiceDetail.Batch_Number, InvoiceAbstract.DocumentID    
Order By InvoiceAbstract.DocumentID, Items.Product_Code, InvoiceDetail.Batch_Number    
  
Insert into #temp2(ProductCode, ProductName, BatchNumber, Quantity, Amount, InvoiceNo)    
Select ProductCode, ProductName, BatchNumber, Sum(Quantity), Sum(Amount), '' From #Temp1    
Group by ProductCode, ProductName, BatchNumber    
    
Declare @PRODUCTCNT As Int    
Declare @I As Int    
Declare @PRODUCTCODE As nVarchar(50)
Declare @TEMP_PCODE As nVarchar(50)    
Declare @BATCHNO As nVarchar(50)  
Set @I = 1    
Select @PRODUCTCNT = Count(ProductCode) From #temp2    
While @PRODUCTCNT >= @I    
Begin    
 Select @PRODUCTCODE = ProductCode From #Temp2 Where ID = @I    
 Declare InvocieNo_Cursor Cursor FOR      
 Select InvoiceNo, BatchNumber From #Temp1 Where ProductCode = @PRODUCTCODE   
 OPEN InvocieNo_Cursor    
 FETCH NEXT FROM InvocieNo_Cursor Into @TEMP_PCODE, @BATCHNO    
 WHILE @@FETCH_STATUS = 0     
 BEGIN    
  Update #Temp2 Set #Temp2.InvoiceNo = Case When IsNull(#Temp2.InvoiceNo,'')='' Then @TEMP_PCODE Else #Temp2.InvoiceNo + ',' + @TEMP_PCODE End    
  Where #Temp2.ProductCode = @PRODUCTCODE And #Temp2.BatchNumber=@BATCHNO And #Temp2.ID=@I      
  FETCH NEXT FROM InvocieNo_Cursor Into @TEMP_PCODE, @BATCHNO     
 END     
 CLOSE InvocieNo_Cursor     
 DEALLOCATE InvocieNo_Cursor    
 Set @I = @I+1    
End    
Select #temp2.ProductCode,"Item Code" = #temp2.ProductCode,"Item Name" = #temp2.ProductName,"Batch" = #temp2.BatchNumber,       
"Quantity" = #temp2.Quantity,"Sales return Value (%c)" = #temp2.Amount,"Invoice Nos." = #temp2.InvoiceNo From #temp2    
Order By #temp2.InvoiceNo, #temp2.ProductCode, #temp2.BatchNumber, #temp2.Quantity       
Drop Table #temp1    
Drop Table #temp2  
  
