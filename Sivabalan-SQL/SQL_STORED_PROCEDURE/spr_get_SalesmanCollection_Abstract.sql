CREATE procedure spr_get_SalesmanCollection_Abstract (@SalesMan nvarchar(2550), @FromDate DateTime, @ToDate DateTime, @CollType nvarchar(25))    
AS  
BEGIN    
Declare @OTHERS NVarchar(50)  
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)  
  
 Declare @Delimeter as Char(1)    
   Set @Delimeter=Char(15)    
--  Create table #tmpSalesMan(SalesMan_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)   
 Create table #tmpSalesMan(sALESMANiD INTEGER)   
  
  
  If @SalesMan='%'  
  begin  
   Insert Into #tmpSalesMan Select salesmanId From SalesMan  
   insert into #tmpsalesman Values(0)  
  end  
 Else  
  Insert Into #tmpSalesMan   
    Select SalesmaniD from Salesman where salesman_name in (Select * FROM dbo.sp_SplitIn2Rows(@SalesMan,@Delimeter))        
  
  
 Select     
 isnull(SM.SalesmanID,0), "Salesman" = isnull(SM.salesman_name,@OTHERS),     
 "Collection Value" = sum(Col.Value)    
 From Collections Col 
 Left Outer Join SalesMan SM ON Col.SalesmanID = SM.SalesmanID
 Where
 Col.DocumentDate between @FromDate and @ToDate     
 and cast(Col.PaymentMode as nvarchar) like     
 (case @CollType when 'Cash' then '0'     
 when 'Cheque' then '1'     
 when 'DD' then '2'     
 when 'Credit Card' then '3'     
 when 'Bank Transfer' then '4'  
 when 'Coupon' then '5'     
 else '%' end)     
 and Col.Salesmanid IN ( Select sALESMANiD From #tmpSalesMan) and     
 (isnull(Col.Status,0) & 192) = 0    
 group by SM.SalesmanID, SM.Salesman_name  
   
 Drop Table #tmpSalesMan  
END
      
