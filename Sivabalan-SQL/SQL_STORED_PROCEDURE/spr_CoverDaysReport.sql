
CREATE PROCEDURE [spr_CoverDaysReport](@PERIOD NVARCHAR(50),@Min Float,@Max Float,@Show NVarchar(50))                
            
AS         
      
BEGIN             
        
SET DATEFORMAT DMY        
        
DECLARE @FROMDATE DATETIME                
            
DECLARE @TODATE DATETIME                
      
DECLARE @NODAYS INT      
    
DECLARE @StrSql NVARCHAR(1000)    
            
SET @FROMDATE = CAST(DATEPART(dd, GETDATE()) AS varchar) + '/' + CAST(DATEPART(mm, GETDATE()) as varchar) + '/' + cast(DATEPART(yyyy, GETDATE()) AS varchar)                
              
SET @FROMDATE = DATEADD(m, (0- cast(substring(@PERIOD,1,2) as int)), @FROMDATE)                
            
SET @TODATE = CAST(DATEPART(dd, GETDATE()) AS varchar) + '/' + CAST(DATEPART(mm, GETDATE()) as varchar) + '/' + cast(DATEPART(yyyy, GETDATE()) AS varchar)                
            
SET @TODATE = DATEADD(d, 1, @TODATE)                
      
SET @NODAYS = cast(substring(@PERIOD,1,2) as int) * 30      
    
If @Show = 'Volume'             
            
Begin            
            
select Product_code,"Item Name" = ProductName,              
            
"UOM" = (Select Description from UOM where UOM = C.UOM),             
              
"SOH" = IsNull((select Sum(Quantity) from Batch_Products where Product_code = C.Product_code),0),              
              
"Month Sales" = IsNull((Select Sum(Case When Invoicetype In (4,5,6) Then (0 - quantity) Else Quantity End) From invoicedetail,invoiceabstract              
                       Where invoicedetail.invoiceid = invoiceabstract.invoiceid And              
                       invoiceabstract.invoicedate Between @FromDate and @ToDate And (IsNull(Status,0) & 192 = 0) And             
                       product_code= C.Product_Code),0),              
            
"Average Daily Sale" = Cast((IsNull((Select Sum(Case When Invoicetype In (4,5,6) Then (0 - quantity) Else Quantity End) From invoicedetail,invoiceabstract              
                       Where invoicedetail.invoiceid = invoiceabstract.invoiceid And              
                       invoiceabstract.invoicedate Between @FromDate And @ToDate And (IsNull(Status,0) & 192 = 0)             
                       And product_code= C.Product_Code),0) / @NODAYS) As Decimal(18,2)),            
            
"Pipeline Stocks (Days)" = Case(Cast((IsNull((Select Sum(Case When Invoicetype In (4,5,6) Then (0 - quantity) Else Quantity End) From invoicedetail,invoiceabstract              
                           Where invoicedetail.invoiceid = invoiceabstract.invoiceid And              
                           invoiceabstract.invoicedate Between @FromDate And @ToDate And (IsNull(Status,0) & 192 = 0)             
                           And product_code= C.Product_Code),0) / @NODAYS) As Decimal(18,2))) When 0 Then 0  
         Else            
                           IsNull((select Sum(Quantity) from Batch_Products where Product_code = C.Product_code),0) /  
                           (Cast((IsNull((Select Sum(Case When Invoicetype In (4,5,6) Then (0 - quantity) Else Quantity End) From invoicedetail,invoiceabstract              
                           Where invoicedetail.invoiceid = invoiceabstract.invoiceid And              
                           invoiceabstract.invoicedate Between @FromDate And @ToDate And (IsNull(Status,0) & 192 = 0)             
                           And product_code= C.Product_Code),0) / @NODAYS) As Decimal(18,2))) End           
Into #temp From Items C  
    
Set @Strsql = 'Select Product_Code,[Item Name],[UOM],[SOH],[Month Sales] ' + '[Last ' + @Period + ' Sales Volume]' + ',[Average Daily Sale],[Pipeline Stocks (Days)] From #temp Where [Pipeline Stocks (Days)] Between ' + Cast(@Min as Varchar) + ' And ' + Cast(@Max as Varchar)  
  
Exec SP_Executesql @strsql          
            
Drop Table #temp            
            
End            
            
Else If @Show = 'Value'          
            
Begin            
            
Select Product_code,"Item Name" = ProductName,              
              
"SOH (Rs.)" = IsNull((Select Sum(Quantity * PurchasePrice) From Batch_Products Where Product_code = C.Product_code),0),              
              
"Month Sales" = IsNull((Select Sum(Case When Invoicetype In (4,5,6) Then (0 - Amount) Else Amount End) From invoicedetail,invoiceabstract              
                Where invoicedetail.invoiceid = invoiceabstract.invoiceid And              
                invoiceabstract.invoicedate Between @FromDate And @ToDate And (IsNull(Status,0) & 192 = 0)             
                And product_code = C.Product_Code),0),              
            
"Average Daily Sale (Rs.)" = Cast((IsNull((Select Sum(Case When Invoicetype In (4,5,6) Then (0 - Amount) Else Amount End) From invoicedetail,invoiceabstract              
                             Where invoicedetail.invoiceid = invoiceabstract.invoiceid And              
                             invoiceabstract.invoicedate Between @FromDate And @ToDate And (IsNull(Status,0) & 192 = 0)             
                             And product_code = C.Product_Code),0) / @NODAYS) As Decimal(18,2)),  
            
"Pipeline Stocks (Days)" =   Case(Cast((IsNull((Select Sum(Case When Invoicetype In (4,5,6) Then (0 - Amount) Else Amount End) From invoicedetail,invoiceabstract              
                             Where invoicedetail.invoiceid = invoiceabstract.invoiceid And              
                             invoiceabstract.invoicedate Between @FromDate And @ToDate And (IsNull(Status,0) & 192 = 0)             
                             And product_code = C.Product_Code),0) / @NODAYS) As Decimal (18,2))) When 0 Then 0  
                             Else  
                             IsNull((Select Sum(Quantity * PurchasePrice) From Batch_Products Where Product_code = C.Product_code),0) /             
                             (Cast((IsNull((Select Sum(Case When Invoicetype In (4,5,6) Then (0 - Amount) Else Amount End) From invoicedetail,invoiceabstract              
                             Where invoicedetail.invoiceid = invoiceabstract.invoiceid And              
                             invoiceabstract.invoicedate Between @FromDate And @ToDate And (IsNull(Status,0) & 192 = 0)             
                             And product_code = C.Product_Code),0) / @NODAYS) As Decimal(18,2))) End  
            
Into #temp1 From Items C              
            
Set @Strsql = 'Select Product_Code,[Item Name],[SOH (Rs.)],[Month Sales] ' + '[Last ' + @Period + ' Sales Value (Rs.)]' + ',[Average Daily Sale (Rs.)],[Pipeline Stocks (Days)] From #temp1 Where [Pipeline Stocks (Days)] Between ' + Cast(@Min as Varchar) + ' And ' + Cast(@Max as Varchar)  
  
Exec SP_Executesql @strsql          
            
Drop Table #temp1            
            
End            
      
END      
   

