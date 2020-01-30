CREATE procedure dbo.spr_list_FormA9    
(     
@FromDate DateTime,     
@ToDate DateTime,     
@Items nvarchar(256)    
)    
AS   
Declare @FIRSTSALE As NVarchar(50)
Declare @SECONDSALE As NVarchar(50)
Declare @ALL As NVarchar(50)

Set @FIRSTSALE = dbo.LookupDictionaryItem(N'First Sale',Default)
Set @SECONDSALE = dbo.LookupDictionaryItem(N'Second Sale',Default) 
Set @ALL = dbo.LookupDictionaryItem(N'All',Default) 

declare @bprefix nvarchar(20)  
declare @baprefix nvarchar(20)  
select @bprefix= Prefix from voucherprefix where tranid= N'BILL'
select @baprefix= Prefix from voucherprefix where tranid= N'BILL AMENDMENT'
if(@Items= @FIRSTSALE )    
Begin    
select t2.product_code, t2.product_code as ItemCode,t3.productname as ItemName,t1.vendorid As VendorId,t4.vendor_name as VendorName,t4.Address as Address,Isnull(t4.CST,N'') as CSTRegno,IsNull(t4.TNGST,N'') as STRegno,"BillNo"=case Isnull(t1.billreference,0)
  
when 0 then @bprefix + cast(t1.documentid as nvarchar)   
else @baprefix + cast(t1.documentid as nvarchar)   
End  
,t1.invoicereference as Invoiceno,t1.billdate as   
Date,sum(t2.quantity) as Quantity,sum(t2.amount)+sum(t2.taxamount) as Value     
from BillAbstract t1,BillDetail t2,Items t3,Vendors t4     
where t1.billid=t2.billid    
and t2.product_code=t3.product_code    
and t1.vendorid=t4.vendorid    
and t3.saleid=1    
and (t1.status & 128=0)    
and t1.billdate between @FromDate and @ToDate    
group by t2.product_code,t3.productname,t1.vendorid,t4.vendor_name,t4.Address,t1.documentid,t2.quantity,t1.billdate,t4.CST,t4.TNGST,t1.billreference,t1.invoicereference  
order by t1.documentid    
End    
if(@Items= @SECONDSALE )    
Begin    
select t2.product_code,t2.product_code as ItemCode,t3.productname as ItemName,t1.vendorid as VendorId,t4.vendor_name as VendorName,t4.Address as Address,Isnull(t4.CST,N'') as CSTRegno,IsNull(t4.TNGST,N'') as STRegno,"BillNo"= case(isnull(t1.billreference,0))  
when 0 then @bprefix + cast(t1.documentid as nvarchar)   
else @baprefix + cast(t1.documentid as nvarchar)   
end  
,t1.invoicereference as Invoiceno,t1.billdate as Date,sum(t2.quantity) as Quantity,sum(t2.amount)+ sum(t2.taxamount)as Value     
from BillAbstract t1,BillDetail t2,Items t3,Vendors t4     
where t1.billid=t2.billid    
and t2.product_code=t3.product_code    
and t1.vendorid=t4.vendorid    
and t3.saleid=2    
and (t1.status & 128=0)    
and t1.billdate between @FromDate and @ToDate    
group by t2.product_code,t3.productname,t1.vendorid,t4.vendor_name,t4.Address,t1.documentid,t2.quantity,t1.billdate,t4.CST,t4.TNGST,t1.billreference,t1.invoicereference    
order by t1.documentid    
End    
if(@Items= @ALL)    
Begin    
select t2.product_code,t2.product_code as ItemCode,productname as ItemName,t1.vendorid as VendorId,t4.vendor_name as VendorName,t4.Address as Address,Isnull(t4.CST,N'') as CSTRegno,IsNull(t4.TNGST,N'') as STRegno,"BillNo"= case (Isnull(t1.billreference,0)) 
when 0 then @bprefix + cast(t1.documentid as nvarchar)   
else @baprefix + cast(t1.documentid as nvarchar)   
End  
,t1.invoicereference as Invoiceno,t1.billdate as Date,  
sum(t2.quantity) as Quantity,sum(t2.amount)+sum(t2.taxamount) as Value     
from BillAbstract t1,BillDetail t2,Items t3,Vendors t4     
where t1.billid=t2.billid    
and t2.product_code=t3.product_code    
and t1.vendorid=t4.vendorid    
and (t1.status & 128=0)    
and t1.billdate between @FromDate and @ToDate    
group by t2.product_code,t3.productname,t1.vendorid,t4.vendor_name,t4.Address,t1.documentid,t2.quantity,t1.billdate,t4.CST,t4.TNGST,t1.billreference,t1.invoicereference    
order by t1.documentid    
End    
    
  
  


