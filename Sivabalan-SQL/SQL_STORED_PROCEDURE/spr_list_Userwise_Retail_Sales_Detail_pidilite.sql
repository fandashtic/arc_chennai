CREATE procedure [dbo].[spr_list_Userwise_Retail_Sales_Detail_pidilite] (@PaymentMode nvarchar(50),                          
               @FromDate Datetime,                          
               @ToDate Datetime,@unused1 as nvarchar(200),@unuse2 nvarchar(200))                          
As                          
                  
Declare @PaymentInfo As nvarchar(20)                         
Declare @Voucher as nvarchar(20)                  
Declare @UserName as nvarchar(50)            
declare @payment as nvarchar(50)                        
            
SET @Payment = substring(@paymentmode,1,charindex(N':',@paymentmode,0)-1)             
Set @UserName = cast(substring(@paymentmode,charindex(N':',@PaymentMode,0)+1,len(@paymentmode)) as nvarchar)            
        
Select @Voucher = Prefix From VoucherPrefix Where TranID = N'INVOICE'           
set @PaymentInfo = @Payment 
        
if @payment = N'%'        
Begin        
        
 Declare @StrSql nvarchar(2000)        
 Declare @StrSql1 nvarchar(2000)        
 Declare @Mode nvarchar(50)        
 Declare @InvID nvarchar(50)        
 declare @Amt Decimal(18,6)        
 Declare @ColName nvarchar(50)        
 declare @Value nvarchar(50)     
    
Create table #Temp(PaymentMode nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,InvoiceID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, Customer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, DocReference nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, Invoicedate datetime, NetValue Decimal(18,6), Discount Decimal(18,6),GrossValue Decimal(18,6),AmountCollected Decimal(18,6))                  
       
DECLARE PayMode CURSOR for Select value from PaymentMode    
OPEN PayMode              
FETCH FROM PayMode INTO @Value              
WHILE @@Fetch_status = 0        
   BEGIN    
 Insert into #Temp                              
 Select @Value, "InvoiceID" = @Voucher + Cast(DocumentID as nvarchar),                     
  "Customer" = Company_Name, 
  "DocReference" = DocReference,
 "Invoice Date" = InvoiceDate,                     
  "Net Value" = NetValue - ISNULL(Freight,0),                    
  "Discount" = DiscountValue,            
 "GrossValue" = GrossValue,    
  "AmtCollected" = (select sum(NetRecieved) from RetailPaymentDetails where   
 RetailInvoiceId=InvoiceAbstract.InvoiceID and PaymentMode=(select mode from PaymentMode where value=@Value))  
  From InvoiceAbstract, Customer , VoucherPrefix                       
  Where                    
  Username like @UserName And            
  InvoiceAbstract.InvoiceType = 2 And                       
  InvoiceAbstract.CustomerID *= Cast(Customer.CustomerID As nvarchar)And                  
  InvoiceDate Between @FromDate And @ToDate And                   
  IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And                          
  VoucherPrefix.TranID = N'INVOICE' And                    
  (select sum(NetRecieved) from RetailPaymentDetails where   
 RetailInvoiceId=InvoiceAbstract.InvoiceID and PaymentMode=(select mode from PaymentMode where value=@Value)) <> 0  
 group by DocumentID,Company_Name,InvoiceDate ,DiscountValue ,GrossValue,NetValue,Freight,InvoiceAbstract.InvoiceID, DocReference
    
 FETCH NEXT FROM PayMode INTO @Value          
   END      
      
CLOSE PayMode              
DEALLOCATE PayMode                         
    
 Select distinct InvoiceID, DocReference, Customer,InvoiceDate,NetValue,Discount,GrossValue into #Temp1 from #Temp     
    
 Declare getPayMode CURSOR for Select distinct PaymentMode from #Temp                    
 open getPayMode          
 Fetch from getPayMode into @ColName          
 while @@Fetch_status = 0          
  Begin          
  set @StrSql = N'Alter Table #Temp1 Add [' + @ColName + N'] Decimal(18,6)'          
  exec sp_executesql @StrSql              
  Fetch Next from getPayMode into @ColName          
  end          
 close getPayMode          
 deallocate getPayMode          
           
 Declare InsertVal CURSOR for Select PaymentMode,InvoiceID,AmountCollected from #Temp          
 open InsertVal      
 Fetch from InsertVal into @Mode,@InvID,@Amt         
 while @@Fetch_status = 0          
Begin          
  set @StrSql1 = N'Update #Temp1 set [' + @Mode + N'] = ' + cast(@Amt as nvarchar) +  N' Where InvoiceID = ''' + @InvID + ''''           
  exec sp_executesql @StrSql1              
  Fetch Next from InsertVal into @Mode,@InvID,@Amt          
  end          
 close InsertVal          
 deallocate InsertVal          
         
 select InvoiceID,* from #Temp1        
 drop table #Temp1        
 drop table #Temp    
End        
Else        
 Begin        
 Declare @StrSql2 nvarchar(2000)        
 Create Table #Temp2 (InvoiceID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,Customer nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, DocReference nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, [Invoice Date] datetime,[Net Value] Decimal(18,6),Discount Decimal(18,6),GrossValue Decimal(18,6))        
 set @StrSql2 = N'Alter Table #Temp2 add [' + @Payment + N'] Decimal(18,6)'        
 Exec sp_executesql @StrSql2        
 Insert into #Temp2        
 Select "InvoiceID" = @Voucher + Cast(DocumentID as nvarchar),                     
  "Customer" = Company_Name,         
  "DocReference" = DocReference,
  "Invoice Date" = InvoiceDate,                     
  "Net Value" = NetValue - ISNULL(Freight,0),                    
  "Discount" = DiscountValue,            
 "GrossValue" = GrossValue,    
    "Amount" = (select sum(NetRecieved) from RetailPaymentDetails where   
 RetailInvoiceId=InvoiceAbstract.InvoiceID and PaymentMode=(select mode from PaymentMode where value=@PaymentInfo))  
  From InvoiceAbstract, Customer , VoucherPrefix                       
  Where                    
  Username = @UserName And            
  InvoiceAbstract.InvoiceType = 2 And                       
  InvoiceAbstract.CustomerID *= Cast(Customer.CustomerID As nvarchar)And                  
  InvoiceDate Between @FromDate And @ToDate And                    
  IsNull(InvoiceAbstract.Status, 0) & 128 = 0 And                          
  VoucherPrefix.TranID = N'INVOICE' And                    
(select sum(NetRecieved) from RetailPaymentDetails where   
RetailInvoiceId=InvoiceAbstract.InvoiceID and PaymentMode=(select mode from PaymentMode where value=@PaymentInfo)) <> 0  
 Select InvoiceID,* from #Temp2        
        
 Drop table #Temp2      
   End
