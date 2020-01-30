CREATE procedure [dbo].[spr_ser_salestaxpayable_detail](@InvID nvarchar(30))  
as  

declare @INVTYPE int
declare @SERVICEINVTYPE int
set @INVTYPE = 1
set @SERVICEINVTYPE =2
declare @sComponentName varchar(500)  
declare @Prefix varchar(10)  
declare @s nvarchar(1200)  
declare @TaxComp varchar(50)  
declare @TaxValue decimal(18,6)  
declare @Locality varchar(10)  
declare @SaleID int  
declare @ProductCode varchar(50)  
declare @TYPE int
Declare @InvoiceID Int
Declare @IType Int
Declare @I Int
Declare @ParamSep nvarchar(10)
Declare @ParamSepcounter Int
Declare @tempString nVarchar(20)

Set @ParamSep = Char(2)                
Set @tempString =@InvID

/*InvoiceID*/          

Set @ParamSepcounter = CHARINDEX(@ParamSep,@tempString,1)                
set @InvoiceID = substring(@tempString, 1, @ParamSepcounter-1)             
          
/*Type*/          
            
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@InvID))             
set @IType = cast(@tempString as int)

--select @InvoiceID

If @IType =1
Begin 
	Create Table #SalesTaxPay([InvoiceID] int,[Item code] nvarchar(15) collate SQL_Latin1_General_Cp1_CI_AS,[Item Name] nvarchar(255) collate SQL_Latin1_General_Cp1_CI_AS,
	[FS Total (%c)] decimal(18,6),[FSLT Total (%c)] Decimal(18,6))

	--begin  
	
	Insert into #SalesTaxPay
	select  "invoiceid"=ia.invoiceid, "Item Code"=idt.product_code, "Item Name"=items.productname,
	"FS Total (%c)" = Sum(case WHEN idt.saleid = 1 AND IA.InvoiceType = 4 then 0 - (amount) WHEN idt.saleid = 1 AND IA.InvoiceType <> 4 then amount else null end),   
	"FSLT Total (%c)"= sum(case when idt.saleid = 1 and IA.InvoiceType = 4 then 0 - (stpayable)when idt.saleid = 1 AND IA.InvoiceType <> 4 then stpayable else null end)
	from invoiceabstract IA, VoucherPrefix , invoicedetail idt, items
	where ia.invoiceid=idt.invoiceid  and tranid='INVOICE'
	and items.product_code=idt.product_code and (ia.status & 128) = 0 and idt.invoiceid=@InvoiceID
	group by ia.invoiceid, documentid, ia.docreference, prefix, idt.product_code, items.productname

	Select * into #SalesTaxPayableTemp from #SalesTaxPay 
	
	declare SalesTaxComponents cursor  
	for  
	select distinct 'FSLT ', taxcomponent_desc  
	from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, customer c, taxcomponentdetail tcd  
	where itc.invoiceid=idt.invoiceid and itc.invoiceid=ia.invoiceid and  
	ia.customerid*=c.customerid and  
	idt.product_code=itc.product_code and   
	idt.taxid=itc.tax_code and   
	tcd.taxcomponent_code=itc.tax_component_code and  
	idt.invoiceid=@Invoiceid and 
	(ia.status & 128) = 0 and 
	isnull(c.locality,1)=1 and saleid=1  

	union all  
	select 'FSCT ','Total'  
	union all  

	select distinct 'FSCT ', taxcomponent_desc  
	from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, customer c, taxcomponentdetail tcd  
	where itc.invoiceid=idt.invoiceid and itc.invoiceid=ia.invoiceid and  
	idt.invoiceid=@Invoiceid and ia.customerid*=c.customerid and  
	idt.product_code=itc.product_code and idt.taxid=itc.tax_code and   
	tcd.taxcomponent_code=itc.tax_component_code and isnull(c.locality,1)=2 and   
	(ia.status & 128) = 0 and saleid=1  
	union all  

	select 'SS ','Total' 
	union all

	select 'SSLT ','Total'  
	union all

	select distinct 'SSLT ', taxcomponent_desc  
	from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, customer c, taxcomponentdetail tcd  
	where itc.invoiceid=idt.invoiceid and itc.invoiceid=ia.invoiceid and
	idt.invoiceid=@Invoiceid and ia.customerid*=c.customerid and  
	idt.product_code=itc.product_code and idt.taxid=itc.tax_code and   
	tcd.taxcomponent_code=itc.tax_component_code and isnull(c.locality,1)=1 and   
	(ia.status & 128) = 0 and saleid=2  
	union all  
	select 'SSCT ','Total'  
	union all  
	select distinct 'SSCT ', taxcomponent_desc
	from invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, customer c, taxcomponentdetail tcd  
	where itc.invoiceid=idt.invoiceid and itc.invoiceid=ia.invoiceid and  
	idt.invoiceid=@Invoiceid and ia.customerid*=c.customerid and  
	idt.product_code=itc.product_code and idt.taxid=itc.tax_code and   
	tcd.taxcomponent_code=itc.tax_component_code and isnull(c.locality,1)=2 and   
	(ia.status & 128) = 0 and saleid=2

--	Select * from #SalesTaxPayableTemp
 
	open SalesTaxComponents  
	fetch next from SalesTaxComponents into @Prefix,@sComponentName  
	while @@FETCH_STATUS=0  
	Begin  
		set @s = 'alter table #SalesTaxPayableTemp add ['+@Prefix+rtrim(@sComponentName)+ ' (%c)] decimal(18,6)'
		exec sp_executesql @s  
   
	fetch next from SalesTaxComponents into @Prefix,@sComponentName
	end  
	
	--alter table #SalesTaxPayableTemp add [FSCT Total] Decimal(18,6)  
	close SalesTaxComponents  
	deallocate SalesTaxComponents  

	create table #temp1(invoiceid int,taxcomponent_desc nvarchar(255)collate SQL_Latin1_General_Cp1_CI_AS ,tax_value decimal(18,6), locality int,saleid int,[prodcut_code] nvarchar(15) collate SQL_Latin1_General_Cp1_CI_AS)
	insert into #temp1
	
	select STP.invoiceid, tcd.taxcomponent_desc, sum(case invoicetype when 4 then 0-tax_value else tax_value end), isnull(locality,1),idt.saleid, idt.product_code  
	from #SalesTaxPayableTemp STP , invoicetaxcomponents itc, customer c, invoiceabstract ia, invoicedetail idt, taxcomponentdetail tcd  
	where stp.invoiceid=itc.invoiceid and itc.invoiceid = ia.invoiceid and   
	ia.invoiceid = idt.invoiceid and idt.invoiceid=@InvoiceID and
	idt.taxid = itc.tax_code and ia.customerid*=c.customerid and  
	tcd.taxcomponent_code=itc.tax_component_code and  
	idt.product_code=itc.product_code and idt.product_code = stp.[Item Code] and (ia.status & 128) = 0
	group by STP.invoiceid, tcd.taxcomponent_desc, Locality, SaleID, idt.product_code 

	set @s =''
	declare SalesTaxComponentsUpdate cursor  
	for   
	select * from #Temp1 order by #temp1.invoiceid
  
	open SalesTaxComponentsUpdate  
	fetch next from SalesTaxComponentsUpdate into @InvoiceID, @TaxComp, @TaxValue, @Locality, @SaleID, @ProductCode    
	while @@FETCH_STATUS=0    
	begin    
		If isnull(@Locality,1) = 1 and @SaleID = 1
		Begin
--			select 'before1 inv', @InvoiceID
			set @s = 'update #SalesTaxPayableTemp set [FSLT '+rtrim(@TaxComp)+' (%c)]='+convert(varchar,@TaxValue)+' from #SalesTaxPayableTemp where invoiceid='+ cast(@invoiceid as varchar)
		end
 		Else if isnull(@Locality,1) = 2 and @SaleID = 1
		begin    
--			select 'before2 inv', @InvoiceID
			set @s = 'update #SalesTaxPayableTemp set [FSCT '+rtrim(@TaxComp)+' (%c)]='+convert(varchar,@TaxValue)+' from #SalesTaxPayableTemp where invoiceid='+ cast(@invoiceid as varchar)
		End
		Else if isnull(@Locality,1) = 1 and @SaleID = 2    
		begin    
--			select 'before3 inv', @InvoiceID
			set @s = 'update #SalesTaxPayableTemp set [SSLT '+rtrim(@TaxComp)+' (%c)]='+convert(varchar,@TaxValue)+' from #SalesTaxPayableTemp where invoiceid='+ cast(@invoiceid as varchar)
	 	end    
		else if isnull(@Locality,1) = 2 and @SaleID = 2    
 		begin    
--			select 'before4 inv', @InvoiceID
	  		set @s = 'update #SalesTaxPayableTemp set [SSCT '+rtrim(@TaxComp)+' (%c)]='+convert(varchar,@TaxValue)+' from #SalesTaxPayableTemp where invoiceid='+ cast(@invoiceid as varchar)
 		End    
--		select 'after inv', @InvoiceID
 		exec sp_executesql @s    
  
	fetch next from SalesTaxComponentsUpdate into @InvoiceID, @TaxComp, @TaxValue, @Locality, @SaleID, @ProductCode
  
	End  

close SalesTaxComponentsUpdate  
deallocate SalesTaxComponentsUpdate  

update #SalesTaxPayableTemp set #SalesTaxPayableTemp.[FSCT Total (%c)]= case cstpayable when 0 then null else (case invoicetype when 4 then 0-cstpayable else cstpayable end) end
from #SalesTaxPayableTemp, invoicedetail, invoiceabstract
where #SalesTaxPayableTemp.invoiceid=invoicedetail.invoiceid and saleid=1 and invoicedetail.product_code=#SalesTaxPayableTemp.[Item Code]
and #SalesTaxPayableTemp.invoiceid=invoiceabstract.invoiceid
  
update STP set STP.[SSLT Total (%c)]= case stpayable when 0 then null else (case invoicetype when 4 then 0-stpayable else stpayable end) end
from #SalesTaxPayableTemp STP, invoicedetail idt, invoiceabstract ia
where stp.invoiceid=idt.invoiceid and saleid=2  and idt.product_code=stp.[Item Code]
and stp.invoiceid=ia.invoiceid
  
update STP set STP.[SSCT Total (%c)]=case cstpayable when 0 then null else 
(case invoicetype when 4 then 0-cstpayable else cstpayable end) end
from #SalesTaxPayableTemp STP, invoicedetail idt, invoiceabstract ia
where stp.invoiceid=idt.invoiceid  and saleid=2 and idt.product_code=stp.[Item Code]
and stp.invoiceid=ia.invoiceid

update STP set [SS Total (%c)]=case (amount) when 0 then null else (case invoicetype when 4 then 0-amount else amount end) end
from #SalesTaxPayableTemp STP, invoicedetail idt, invoiceabstract ia
where stp.invoiceid=idt.invoiceid  and saleid=2 and idt.product_code=stp.[Item Code]
and stp.invoiceid=ia.invoiceid

update #SalesTaxPayableTemp set [FS Total (%c)]=null where [FS Total (%c)]=0
update #SalesTaxPayableTemp set [FSLT Total (%c)]=null where [FSLT Total (%c)]=0
update #SalesTaxPayableTemp set [FSCT Total (%c)]=null where [FSCT Total (%c)]=0
update #SalesTaxPayableTemp set [SS Total (%c)]=null where [SS Total (%c)]=0
update #SalesTaxPayableTemp set [SSLT Total (%c)]=null where [SSLT Total (%c)]=0
update #SalesTaxPayableTemp set [SSCT Total (%c)]=null where [SSCT Total (%c)]=0
  
select * from #SalesTaxPayableTemp  
drop table #SalesTaxPayableTemp  

End
Else
Begin
	Create Table #SalesTaxPayService([InvoiceID] int,[Item code] nvarchar(15) collate SQL_Latin1_General_Cp1_CI_AS ,[Item Name] nvarchar(255) collate SQL_Latin1_General_Cp1_CI_AS,
	[FS Total (%c)] decimal(18,6),[FSLT Total (%c)] Decimal(18,6))

	Insert into #SalesTaxPayService
	select  "invoiceid"=IA.Serviceinvoiceid ,"Item Code" = idt.sparecode,"Item Name" = items.productname,
	"FS Total (%c)" = Sum(case WHEN isnull(idt.saleid,0) = 1 AND IA.ServiceInvoiceType = 1 then isnull(idt.netvalue,0) else 0 end),     
	"FSLT Total (%c)"= sum(case when isnull(idt.saleid,0) = 1 AND IA.ServiceInvoiceType = 1 then isnull(lstpayable,0) else 0 end)
	from serviceinvoiceabstract IA, VoucherPrefix , serviceinvoicedetail idt,items    
	where isnull(status,0) & 192 = 0    
	and idt.serviceinvoiceid=@InvoiceID
	and isnull(idt.sparecode,'') <> ''
	and items.product_code=idt.sparecode
	and ia.serviceinvoiceid=idt.serviceinvoiceid  and tranid='SERVICEINVOICE'    
	group by ia.serviceinvoiceid, documentid, ia.docreference, prefix,idt.sparecode, items.productname    

	Select * into #SalesTaxPayableTempService from #SalesTaxPayService
	
	declare SalesTaxComponentService cursor  
	for  
	select distinct 'FSLT ', taxcomponent_desc from   
	serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia, 
	taxcomponentdetail tcd, customer c    
	where itc.serialno=idt.serialno and           
	idt.serviceinvoiceid=ia.serviceinvoiceid and          
	idt.serviceinvoiceid = @Invoiceid and
	itc.taxtype =2
	and isnull(ia.status,0) & 192 =0 and          
	tcd.taxcomponent_code=itc.taxcomponent_code and    
	ia.customerid*=c.customerid and     
	isnull(c.locality,1)=1 and    
	idt.saleid=1 
	
	union all  
	select 'FSCT ','Total'  
	union all  

	select distinct 'FSCT ', taxcomponent_desc from
	serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia, 
	taxcomponentdetail tcd, customer c    
	where itc.serialno=idt.serialno and idt.serviceinvoiceid=ia.serviceinvoiceid and          
	itc.taxtype =2 and idt.serviceinvoiceid = @Invoiceid
	and isnull(ia.status,0) & 192 =0 and tcd.taxcomponent_code=itc.taxcomponent_code and    
	ia.customerid*=c.customerid and isnull(c.locality,1)=2 and idt.saleid=1 
	
	union all  
	select 'SS ','Total' 
	union all
	
	select 'SSLT ','Total'  
	union all

	select distinct 'SSLT ', taxcomponent_desc from    
	serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia, 
	taxcomponentdetail tcd, customer c    
	where itc.serialno=idt.serialno and idt.serviceinvoiceid=ia.serviceinvoiceid and          
	idt.serviceinvoiceid=@Invoiceid and itc.taxtype =2 and isnull(ia.status,0) & 192 =0
	and tcd.taxcomponent_code=itc.taxcomponent_code and ia.customerid*=c.customerid and
	isnull(c.locality,1)=1 and idt.saleid=2 
	
	union all  
	select 'SSCT ','Total'  
	union all  

	select distinct 'SSCT ', taxcomponent_desc from    
	serviceinvoicetaxcomponents itc, serviceinvoicedetail idt, serviceinvoiceabstract ia,
	taxcomponentdetail tcd, customer c    
	where itc.serialno=idt.serialno and           
	idt.serviceinvoiceid=ia.serviceinvoiceid and          
	itc.taxtype =2 and idt.serviceinvoiceid=@Invoiceid and 
	isnull(ia.status,0) & 192 =0 and tcd.taxcomponent_code=itc.taxcomponent_code and    
	ia.customerid*=c.customerid and isnull(c.locality,1)=2 and idt.saleid=2 
	
	set @s = ''
	open SalesTaxComponentService  
	fetch next from SalesTaxComponentService into @Prefix,@sComponentName  
	while @@FETCH_STATUS=0  
	begin  
	 	set @s = 'alter table #SalesTaxPayableTempService add ['+@Prefix+rtrim(@sComponentName)+ ' (%c)] decimal(18,6)'  
	 	exec sp_executesql @s  
	   
	fetch next from SalesTaxComponentService into @Prefix,@sComponentName
	end  
	--alter table #SalesTaxPayableTempService add [FSCT Total] Decimal(18,6)  
	close SalesTaxComponentService  
	deallocate SalesTaxComponentService  
	
	create table #TempService(invoiceid int,taxcomponent_desc nvarchar(255) collate SQL_Latin1_General_Cp1_CI_AS,tax_value decimal(18,6), locality int,saleid int,[prodcut_code] nvarchar(15) collate SQL_Latin1_General_Cp1_CI_AS)

	insert into #TempService
	select STP.invoiceid, tcd.taxcomponent_desc, sum(isnull(tax_value,0)),isnull(locality,1),idt.saleid, idt.sparecode
	from #SalesTaxPayableTempService STP,serviceinvoicetaxcomponents itc, customer c, serviceinvoiceabstract ia, serviceinvoicedetail idt, taxcomponentdetail tcd  
	where ia.customerid*=c.customerid and itc.serialno=idt.serialno and 
	idt.serviceinvoiceid=@InvoiceID and idt.sparecode=stp.[Item Code] and 
	itc.taxtype =2 and tcd.taxcomponent_code=itc.taxcomponent_code and    
	isnull(ia.status,0) & 192 =0         
	group by STP.invoiceid, tcd.taxcomponent_desc, Locality, SaleID, idt.sparecode
	  
	Declare SalesTaxComponentsUpdateService cursor  
	for   
	select * from #TempService order by #TempService.invoiceid
	
	set @s = ''
	open SalesTaxComponentsUpdateService
	fetch next from SalesTaxComponentsUpdateService into @InvoiceID, @TaxComp, @TaxValue, @Locality, @SaleID, @ProductCode
	while @@FETCH_STATUS=0    
	begin    
		If isnull(@Locality,1) = 1 and @SaleID = 1    
 		begin    
			set @s = 'update #SalesTaxPayableTempService set [FSLT '+rtrim(@TaxComp)+' (%c)]='+convert(varchar,@TaxValue)+' from #SalesTaxPayableTempService where invoiceid='+ cast(@invoiceid as varchar)
	 	end    
	 	else if isnull(@Locality,1) = 2 and @SaleID = 1    
	 	begin    
			set @s = 'update #SalesTaxPayableTempService set [FSCT '+rtrim(@TaxComp)+' (%c)]='+convert(varchar,@TaxValue)+' from #SalesTaxPayableTempService where invoiceid='+ cast(@invoiceid as varchar)
	 	end    
	 	else if isnull(@Locality,1) = 1 and @SaleID = 2    
	 	begin    
			set @s = 'update #SalesTaxPayableTempService set [SSLT '+rtrim(@TaxComp)+' (%c)]='+convert(varchar,@TaxValue)+' from #SalesTaxPayableTempService where invoiceid='+ cast(@invoiceid as varchar)
	 	end    
	 	else if isnull(@Locality,1) = 2 and @SaleID = 2    
	 	begin    
			set @s = 'update #SalesTaxPayableTempService set [SSCT '+rtrim(@TaxComp)+' (%c)]='+convert(varchar,@TaxValue)+' from #SalesTaxPayableTempService where invoiceid='+ cast(@invoiceid as varchar)
	 	end    
	 	exec sp_executesql @s    
	   
	fetch next from SalesTaxComponentsUpdateService into @InvoiceID, @TaxComp, @TaxValue, @Locality, @SaleID, @ProductCode
	  
	end  
	close SalesTaxComponentsUpdateService  
	deallocate SalesTaxComponentsUpdateService  

	update #SalesTaxPayableTempService set #SalesTaxPayableTempService.[FSCT Total (%c)] = isnull((select sum(isnull(cstpayable,0)) 
	from #SalesTaxPayableTempService,serviceinvoiceabstract,serviceinvoicedetail
	where #SalesTaxPayableTempService.invoiceid = serviceinvoicedetail.serviceinvoiceid and saleid = 1 and
	serviceinvoicedetail.sparecode=#SalesTaxPayableTempService.[Item Code] and #SalesTaxPayableTempService.invoiceid = serviceinvoiceabstract.serviceinvoiceid),0)

	update #SalesTaxPayableTempService set #SalesTaxPayableTempService.[FSCT Total (%c)] = isnull((select sum(isnull(cstpayable,0)) 
	from #SalesTaxPayableTempService,serviceinvoiceabstract,serviceinvoicedetail
	where #SalesTaxPayableTempService.invoiceid = serviceinvoicedetail.serviceinvoiceid and saleid = 1 and
	serviceinvoicedetail.sparecode=#SalesTaxPayableTempService.[Item Code] and #SalesTaxPayableTempService.invoiceid = serviceinvoiceabstract.serviceinvoiceid),0)

 	update #SalesTaxPayableTempService set #SalesTaxPayableTempService.[SSLT Total (%c)] = isnull((select sum(isnull(lstpayable,0)) 
 	from #SalesTaxPayableTempService ,serviceinvoiceabstract,serviceinvoicedetail
 	where #SalesTaxPayableTempService.invoiceid = serviceinvoicedetail.serviceinvoiceid and saleid = 2
 	and serviceinvoicedetail.sparecode=#SalesTaxPayableTempService.[Item Code] and #SalesTaxPayableTempService.invoiceid = serviceinvoiceabstract.serviceinvoiceid),0)
 	
	update #SalesTaxPayableTempService set #SalesTaxPayableTempService.[SSCT Total (%c)]= isnull((select sum(isnull(cstpayable,0)) 
 	from #SalesTaxPayableTempService ,serviceinvoiceabstract,serviceinvoicedetail
 	where #SalesTaxPayableTempService.invoiceid = serviceinvoicedetail.serviceinvoiceid and saleid = 2 
 	and serviceinvoicedetail.sparecode=#SalesTaxPayableTempService.[Item Code] and #SalesTaxPayableTempService.invoiceid = serviceinvoiceabstract.serviceinvoiceid),0) 
 	
	update #SalesTaxPayableTempService set [SS Total (%c)]=  isnull((select sum(isnull(serviceinvoicedetail.netvalue,0))
	from #SalesTaxPayableTempService,serviceinvoiceabstract,serviceinvoicedetail
	where #SalesTaxPayableTempService.invoiceid = serviceinvoicedetail.serviceinvoiceid 
	and saleid = 2 and isnull(sparecode,'') <> '' 
	and serviceinvoicedetail.sparecode= #SalesTaxPayableTempService.[Item Code] and #SalesTaxPayableTempService.invoiceid = serviceinvoiceabstract.serviceinvoiceid),0)

	update #SalesTaxPayableTempService set [FS Total (%c)]=null where [FS Total (%c)]=0
	update #SalesTaxPayableTempService set [FSLT Total (%c)]=null where [FSLT Total (%c)]=0
	update #SalesTaxPayableTempService set [FSCT Total (%c)]=null where [FSCT Total (%c)]=0
	update #SalesTaxPayableTempService set [SS Total (%c)]=null where [SS Total (%c)]=0
	update #SalesTaxPayableTempService set [SSLT Total (%c)]=null where [SSLT Total (%c)]=0
	update #SalesTaxPayableTempService set [SSCT Total (%c)]=null where [SSCT Total (%c)]=0
	  
	select * from #SalesTaxPayableTempService  
	drop table #SalesTaxPayableTempService  
End
