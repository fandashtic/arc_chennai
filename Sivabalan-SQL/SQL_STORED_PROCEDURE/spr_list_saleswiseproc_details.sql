create procedure spr_list_saleswiseproc_details(@Sname nvarchar(100),@From datetime,@To datetime)                
AS                
declare @rtype nvarchar(100)          
declare @saname nvarchar(100)       
set @saname=left(@sname,charindex(';',@sname,1)-1)                
set @rtype=substring(@sname,charindex(';',@sname,1)+1,len(@sname))          
declare @saltype as int      
declare @status as int      
Declare @SALEABLE As NVarchar(50)
Declare @DAMAGED As NVarchar(50)

Set @SALEABLE = dbo.LookupDictionaryItem(N'Saleable', Default)
Set @DAMAGED = dbo.LookupDictionaryItem(N'Damaged', Default)

   
If @rtype = 'Damages'      
Begin      
 Set @saltype = 32      
 Set @status = 32      
End      
Else If @rtype = 'Saleable'      
Begin      
 Set @status = 0      
 set @saltype = 32      
End      
Else      
Begin      
 Set @status = 0      
 Set @saltype = 0      
End         
      
if(@rtype='%' and @saname='Others')                
BEGIN 
--create table #tmpSal(Productcode varchar(50),Productname varchar
select t2.product_code,t2.product_code as ProductCode,t3.productname as ProductName, 
sum(quantity) as Quantity, 
Sum(amount)  as TotalValue,
"Type"=case status                
when 32 then @DAMAGED          
when 0 then @SALEABLE         
end                 
from Invoiceabstract t1,invoicedetail t2,items t3 
where t1.invoiceid=t2.invoiceid                 
 and t2.product_code=t3.product_code                
 and salesmanid=0      
 and invoicetype=4      
 and (t1.invoicedate between @From and @To)                
 and (status&32=32 or status & 32=0)    
 and (status & 128=0)    
 group by t2.product_code,t3.productname, t1.status

END                
          
if(@rtype='Damages' and @saname='Others')                
BEGIN          
 select t2.product_code, t2.product_code as ProductCode,t3.productname as ProductName,
 sum(quantity) as Quantity,
 sum(amount) as TotalValue,
 "Type"=case status                
 when 32 then @DAMAGED             
 when 0 then @SALEABLE                
 end                 
 from Invoiceabstract t1,invoicedetail t2,items t3 where t1.invoiceid=t2.invoiceid                 
 and t2.product_code=t3.product_code      
 and invoicetype=4                
 and salesmanid=0      
 and (t1.invoicedate between @From and @To)                
 and (status&32=32)    
 and (status & 128=0)    
 group by t2.product_code,t3.productname,t1.status 
END              
              
IF(@rtype='Saleable' and @saname='Others')                
BEGIN          
select t2.product_code, t2.product_code as Productcode,t3.productname as ProductName,
sum(quantity) as Quantity,
sum(amount) as Totalvalue,
"Type"=case status                
when 32 then @DAMAGED          
when 0 then @SALEABLE             
end                 
from Invoiceabstract t1,invoicedetail t2,items t3 where t1.invoiceid=t2.invoiceid                 
 and t2.product_code=t3.product_code                
 and salesmanid=0      
 and invoicetype=4      
 and (t1.invoicedate between @From and @To)                
 and (status & 32=0)    
 and (status & 128=0)    
 group by t2.product_code,t3.productname,t1.status
End       
      
      
if(@rtype='%')                
BEGIN                
select t2.product_code as Productcode,t2.product_code as ProductCode,t3.productname as ProductName,
sum(quantity) as Quantity,
sum(amount) as TotalValue,
"Type"=case status                
when 32 then @DAMAGED               
when 0 then @SALEABLE             
end                 
from Invoiceabstract t1,invoicedetail t2,items t3 where t1.invoiceid=t2.invoiceid                 
 and t2.product_code=t3.product_code                
 and salesmanid=(Select salesmanid from salesman where salesman_name =@Saname)                
 and (t1.invoicedate between @From and @To)                
 and invoicetype=4      
 and (status & 32=32 or status & 32=0)    
 and (status & 128=0)    
 group by t2.product_code,t3.productname,t1.status
END                
          
if(@rtype='Damages')                
BEGIN          
 select t2.product_code, t2.product_code as ProductCode,t3.productname as ProductName,
 sum(quantity) as Quantity,
 sum(amount) as TotalValue,
 "Type"=case status                
 when 32 then @DAMAGED              
 when 0 then @SALEABLE       
 end                 
 from Invoiceabstract t1,invoicedetail t2,items t3 where t1.invoiceid=t2.invoiceid                 
 and t2.product_code=t3.product_code                
 and salesmanid=(Select salesmanid from salesman where salesman_name =@Saname)                
 and invoicetype=4      
 and (t1.invoicedate between @From and @To)                
 and (status & 32=32)    
 and (status & 128=0)    
 group by t2.product_code,t3.productname,t1.status
END              
              
IF(@rtype='Saleable')                
BEGIN          
select t2.product_code, t2.product_code as Productcode,t3.productname as ProductName,
 sum(quantity) as Quantity,
 sum(amount) as Totalvalue,
 "Type"=case status                
when 32 then @DAMAGED                
when 0 then @SALEABLE         
end                 
from Invoiceabstract t1,invoicedetail t2,items t3 where t1.invoiceid=t2.invoiceid                 
 and t2.product_code=t3.product_code                
 and salesmanid=(Select salesmanid from salesman where salesman_name=@Saname)                
 and (t1.invoicedate between @From and @To)                
 and invoicetype=4      
 and status & 32=0    
 and status & 128=0    
 group by t2.product_code,t3.productname,t1.status
End
