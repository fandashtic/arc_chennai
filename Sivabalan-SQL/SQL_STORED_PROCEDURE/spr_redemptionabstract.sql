CREATE procedure spr_redemptionabstract  @CustomerID nvarchar(2550),@FromDate Datetime, @ToDate DateTime
as
begin
declare @DocPrefix nvarchar(20)
Declare @Delimeter as Char(1)    
Set @Delimeter = Char(15)  

create table #tmpCust(customerid nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
if @CustomerID=N'%'        
   insert into #tmpCust select customerid from customer          
else          
   insert into #tmpCust select customerID from Customer where company_name in 
							(select * from dbo.sp_SplitIn2Rows(@CustomerID,@Delimeter))   
 
select @DocPrefix = Prefix from voucherprefix where tranid = 'CUSTOMER POINT REDEMPTION'  
select DocSerial,"DocumentID" = @DocPrefix + cast(documentid as nvarchar),  
"DocumentReference" = DocumentReference,"DocumentDate" = DocumentDate,  
"CustomerID" = redemptionabstract.CustomerID,"Customer Name" = company_Name,  
"RedeemedPoints" = redemptionabstract.RedeemedPoints, "RedeemedAmount" = RedeemedAmount  
from redemptionabstract,customer  
where redemptionabstract.customerID in (select customerid from #tmpCust)      
and DocumentDate between @FromDate and @ToDate  
and customer.customerid = redemptionabstract.customerid  
end
