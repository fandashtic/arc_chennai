Create PROCEDURE spr_list_TaxPaid_Invoices_ITC (@TAXID int, @FROMDATE datetime, @TODATE datetime, @Taxes nVarchar(4000), @Breakup nVarchar(3))    
as  
Begin  
	Declare @TaxCompDesc nvarchar(255)  
	Declare @Prefix nvarchar(50)  
	Declare @TaxCode numeric  
	Declare @TaxCompCode numeric  
	Declare @Query nvarchar(4000)  
	Declare @Locality nvarchar(10)  
	Declare @TaxValue decimal(18,6)  
	Declare @ProductCode nvarchar(100)
	Declare @QueryaleID int  
	Declare @TaxDesc nVarchar(255)  
	Declare @BreakupFlag int
	Declare @TmpTaxCompCode int
	Declare @TaxPayable Table(ColHead1 nVarchar(50), ColHead2 nVarchar(400), ColHead3 int)
	
	Declare @temp datetime
	Set DATEFormat DMY
	set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)

if(@FROMDATE > @temp )
begin
	select 0,'This report cannot be generated for GST period' as Reason
 	goto GSTOut
end

if(@TODATE > @temp )
begin
	set @TODATE  = @temp 
	--goto GSTOut
end

	if @TaxID <> 0 
Begin
	Create Table #TaxDetails(Product_Code nVarchar(15) Collate SQL_Latin1_General_CP1_CI_AS, ItemCode nVarchar(15)  Collate SQL_Latin1_General_CP1_CI_AS, ProductName nVarchar(255)  Collate SQL_Latin1_General_CP1_CI_AS)

	If Upper(@Breakup) = N'YES'
		Set @BreakupFlag = 1
	Else
		Set @BreakupFlag = 0
	
	Insert Into #TaxDetails 
	select idt.Product_Code, "Item Code" = idt.Product_Code, "Product Name" = i.productname
	FROM InvoiceAbstract ia, InvoiceDetail idt, tax, invoicetaxcomponents itc, items i
	WHERE 
	(ia.Status & 128) = 0 AND  
	ia.InvoiceDate between @FromDate AND @ToDate AND    
	ia.InvoiceID = idt.InvoiceID AND 
	idt.invoiceid = itc.invoiceid and 
	idt.product_code = i.product_code and
	idt.taxid=tax.tax_code 
	and idt.taxid=@TaxID
	GROUP BY idt.product_code, i.productname

	Insert Into #TaxDetails 
	select idt.Product_Code, "Item Code" = idt.Product_Code, "Product Name" = i.productname
	FROM InvoiceAbstract ia, InvoiceDetail idt, tax, items i
	WHERE 
	(ia.Status & 128) = 0 AND  
	ia.InvoiceDate between @FromDate AND @ToDate AND    
	ia.InvoiceID = idt.InvoiceID AND 
	idt.product_code = i.product_code and
	idt.taxid=tax.tax_code 
	and idt.taxid=@TaxID
  And Tax.Tax_Description Not In
(
	select Distinct Tax.Tax_Description
	FROM InvoiceAbstract inva, InvoiceDetail invdt, tax t1 , invoicetaxcomponents itc, items i1
	WHERE 
	(inva.Status & 128) = 0 AND  
	inva.InvoiceDate between @FromDate AND @ToDate AND    
	inva.InvoiceID = invdt.InvoiceID AND 
	invdt.invoiceid = itc.invoiceid and 
	invdt.product_code = i1.product_code and
	invdt.taxid=t1.tax_code 
	and invdt.taxid=@TaxID
)
	GROUP BY idt.product_code, i.productname

-- 	select  idt.Product_Code, "Item Code" = idt.Product_Code, "Product Name" = i.productname
-- 	into #TaxPayableByTaxDetails  
-- 	FROM InvoiceAbstract ia, InvoiceDetail idt, tax, invoicetaxcomponents itc, items i
-- 	WHERE 
-- 	(ia.Status & 128) = 0 AND  
-- 	ia.InvoiceDate between @FromDate AND @ToDate AND    
-- 	ia.InvoiceID = idt.InvoiceID AND 
-- 	idt.invoiceid = itc.invoiceid and 
-- 	idt.product_code = i.product_code and
-- 	idt.taxid=tax.tax_code 
-- 	and idt.taxid=@TaxID
-- 	GROUP BY idt.product_code, i.productname

  Select * InTo #TaxPayableByTaxDetails From #TaxDetails
	
	Insert into @TaxPayable
	select N'First Sale Total', N'', 0
	
	Insert into @TaxPayable
	select N'FSLT ', N'Total', 0
	
	Insert into @TaxPayable
	select Distinct N'FSLT ', tax_description, 0 
	from #TaxDetails td, InvoiceAbstract iva, InvoiceDetail ivd, InvoiceTaxComponents itc, tax 
	where 
	IsNull(iva.Status,0) & 128 = 0 and 
	iva.invoicedate between @FromDate AND @ToDate and 
	iva.InvoiceID = ivd.InvoiceID and 
	ivd.product_code = td.product_code and 
	ivd.saleid = 1 and 
	iva.invoiceid = itc.invoiceid and 
	itc.product_code = td.product_code and 
	ivd.taxcode <> 0 and 
	tax.tax_code = @TaxID

-- Imported Tax Handled
	Insert into @TaxPayable
	select Distinct N'FSLT ', tax_description, 0 
	from #TaxDetails td1, InvoiceAbstract inva, InvoiceDetail invd, tax 
	where 
	IsNull(inva.Status,0) & 128 = 0 and 
	inva.invoicedate between @FromDate AND @ToDate and 
	inva.InvoiceID = invd.InvoiceID and 
	invd.product_code = td1.product_code and 
	invd.saleid = 1 and 
	invd.taxcode <> 0 and 
	tax.tax_code = @TaxID And Tax_Description Not In 
(
	select Distinct tax_description
	from #TaxDetails td, InvoiceAbstract iva, InvoiceDetail ivd, InvoiceTaxComponents itc, tax 
	where 
	IsNull(iva.Status,0) & 128 = 0 and 
	iva.invoicedate between @FromDate AND @ToDate and 
	iva.InvoiceID = ivd.InvoiceID and 
	ivd.product_code = td.product_code and 
	ivd.saleid = 1 and 
	iva.invoiceid = itc.invoiceid and 
	itc.product_code = td.product_code and 
	ivd.taxcode <> 0 and 
	tax.tax_code = @TaxID
)

	If @BreakupFlag = 1
	Begin
		Insert into @TaxPayable
		select distinct N'FSLT ', taxcomponent_desc + '_of_' + tax_description, tcd.taxcomponent_code   
		from invoicetaxcomponents itc
		Inner Join invoicedetail idt On itc.invoiceid=idt.invoiceid and idt.product_code=itc.product_code and idt.taxid=itc.tax_code 
		Inner Join  invoiceabstract ia On itc.invoiceid=ia.invoiceid 
		Inner Join taxcomponentdetail tcd On tcd.taxcomponent_code=itc.tax_component_code 
		Left Outer Join  customer c On ia.customerid=c.customerid
		Inner Join  tax  On itc.tax_code = tax.tax_code
		where       
		(ia.status & 128 )=0 and 
		ia.invoicedate between @FromDate and @ToDate and       
		idt.taxid=@TaxID and       
		idt.taxcode <> 0 and 
		idt.saleid=1 
		order by tcd.taxcomponent_code 
	End

	Insert into @TaxPayable
	select N'FSCT ',N'Total', 0
	
	Insert into @TaxPayable
	select Distinct N'FSCT ', tax_description, 0 
	from #TaxDetails td, InvoiceAbstract iva, InvoiceDetail ivd, InvoiceTaxComponents itc, tax 
	where 
	IsNull(iva.Status,0) & 128 = 0 and 
	iva.invoicedate between @FromDate AND @ToDate and 
	iva.InvoiceID = ivd.InvoiceID and 
	ivd.product_code = td.product_code and 
	ivd.saleid = 1 and 
	iva.invoiceid = itc.invoiceid and 
	itc.product_code = td.product_code and 
	ivd.taxcode2 <> 0 and 
	tax.tax_code = @TaxID

-- Imported Tax Handled
	Insert into @TaxPayable
	select Distinct N'FSCT ', tax_description, 0 
	from #TaxDetails td1, InvoiceAbstract inva, InvoiceDetail invd, tax 
	where 
	IsNull(inva.Status,0) & 128 = 0 and 
	inva.invoicedate between @FromDate AND @ToDate and 
	inva.InvoiceID = invd.InvoiceID and 
	invd.product_code = td1.product_code and 
	invd.saleid = 1 and 
	invd.taxcode2 <> 0 and 
	tax.tax_code = @TaxID And tax_description Not In
(
	select Distinct tax_description
	from #TaxDetails td, InvoiceAbstract iva, InvoiceDetail ivd, InvoiceTaxComponents itc, tax 
	where 
	IsNull(iva.Status,0) & 128 = 0 and 
	iva.invoicedate between @FromDate AND @ToDate and 
	iva.InvoiceID = ivd.InvoiceID and 
	ivd.product_code = td.product_code and 
	ivd.saleid = 1 and 
	iva.invoiceid = itc.invoiceid and 
	itc.product_code = td.product_code and 
	ivd.taxcode2 <> 0 and 
	tax.tax_code = @TaxID
)

	If @BreakupFlag = 1
	Begin
		Insert into @TaxPayable
		select distinct N'FSCT ', taxcomponent_desc + '_of_' + tax_description, tcd.taxcomponent_code  
		from invoicetaxcomponents itc
		Inner Join  invoicedetail idt On itc.invoiceid=idt.invoiceid and idt.taxid=itc.tax_code and idt.product_code=itc.product_code 
		Inner Join  invoiceabstract ia On itc.invoiceid=ia.invoiceid 
		Inner Join taxcomponentdetail tcd On tcd.taxcomponent_code=itc.tax_component_code 
		Left Outer Join  customer c On ia.customerid=c.customerid
		Inner Join  tax  On itc.tax_code = tax.tax_code 
		where       
		(ia.status & 128 )=0 and      
		ia.invoicedate between @FromDate and @ToDate and       
		idt.taxid=@TaxID and 
		idt.taxcode2 <> 0 and 
		idt.saleid=1 
		order by tcd.taxcomponent_code 
	End	

	Insert into @TaxPayable
	select N'Second Sale Total', N'', 0
	
	Insert into @TaxPayable
	select N'SSLT ',N'Total', 0
	
	Insert into @TaxPayable
	select Distinct N'SSLT ', tax_description, 0 
	from #TaxDetails td, InvoiceAbstract iva, InvoiceDetail ivd, InvoiceTaxComponents itc, tax 
	where 
	IsNull(iva.Status,0) & 128 = 0 and 
	iva.invoicedate between @FromDate AND @ToDate and 
	iva.InvoiceID = ivd.InvoiceID and 
	ivd.product_code = td.product_code and 
	ivd.saleid = 2 and 
	iva.invoiceid = itc.invoiceid and 
	itc.product_code = td.product_code and 
	ivd.taxcode <> 0 and 
	tax.tax_code = @TaxID


-- Imported Tax Handled
	Insert into @TaxPayable
	select Distinct N'SSLT ', tax_description, 0 
	from #TaxDetails td1, InvoiceAbstract inva, InvoiceDetail invd, tax 
	where 
	IsNull(inva.Status,0) & 128 = 0 and 
	inva.invoicedate between @FromDate AND @ToDate and 
	inva.InvoiceID = invd.InvoiceID and 
	invd.product_code = td1.product_code and 
	invd.saleid = 2 and 
	invd.taxcode <> 0 and 
	tax.tax_code = @TaxID And tax_description Not In
(
	select Distinct tax_description
	from #TaxDetails td, InvoiceAbstract iva, InvoiceDetail ivd, InvoiceTaxComponents itc, tax 
	where 
	IsNull(iva.Status,0) & 128 = 0 and 
	iva.invoicedate between @FromDate AND @ToDate and 
	iva.InvoiceID = ivd.InvoiceID and 
	ivd.product_code = td.product_code and 
	ivd.saleid = 2 and 
	iva.invoiceid = itc.invoiceid and 
	itc.product_code = td.product_code and 
	ivd.taxcode <> 0 and 
	tax.tax_code = @TaxID
)

	If @BreakupFlag = 1
	Begin
		Insert into @TaxPayable
		select distinct N'SSLT ', taxcomponent_desc + '_of_' + tax_description, tcd.taxcomponent_code  
		from invoicetaxcomponents itc
		Inner Join invoicedetail idt On itc.invoiceid=idt.invoiceid and idt.product_code=itc.product_code and idt.taxid=itc.tax_code 
		Inner Join  invoiceabstract ia On itc.invoiceid=ia.invoiceid
		Inner Join  taxcomponentdetail tcd  On tcd.taxcomponent_code=itc.tax_component_code
		Left Outer Join  customer c On ia.customerid=c.customerid 
		Inner Join  tax  On itc.tax_code = tax.tax_code 
		where       
		(ia.status & 128 )=0 and 
		ia.invoicedate between @FromDate and @ToDate and       
		idt.taxid=@TaxID and       
		idt.taxcode <> 0 and 
		idt.saleid=2 
		order by tcd.taxcomponent_code 
	End
	
	Insert into @TaxPayable
	select N'SSCT ',N'Total', 0
	
	Insert into @TaxPayable
	select Distinct N'SSCT ', tax_description, 0 
	from #TaxDetails td, InvoiceAbstract iva, InvoiceDetail ivd, InvoiceTaxComponents itc, tax 
	where 
	IsNull(iva.Status,0) & 128 = 0 and 
	iva.invoicedate between @FromDate AND @ToDate and 
	iva.InvoiceID = ivd.InvoiceID and 
	ivd.product_code = td.product_code and 
	ivd.saleid = 2 and 
	iva.invoiceid = itc.invoiceid and 
	itc.product_code = td.product_code and 
	ivd.taxcode2 <> 0 and 
	tax.tax_code = @TaxID

-- Imported Tax Handled
	Insert into @TaxPayable
	select Distinct N'SSCT ', tax_description, 0 
	from #TaxDetails td1, InvoiceAbstract inva, InvoiceDetail invd, tax 
	where 
	IsNull(inva.Status,0) & 128 = 0 and 
	inva.invoicedate between @FromDate AND @ToDate and 
	inva.InvoiceID = invd.InvoiceID and 
	invd.product_code = td1.product_code and 
	invd.saleid = 2 and 
	invd.taxcode2 <> 0 and 
	tax.tax_code = @TaxID And tax_description Not In
(
	select Distinct tax_description
	from #TaxDetails td, InvoiceAbstract iva, InvoiceDetail ivd, InvoiceTaxComponents itc, tax 
	where 
	IsNull(iva.Status,0) & 128 = 0 and 
	iva.invoicedate between @FromDate AND @ToDate and 
	iva.InvoiceID = ivd.InvoiceID and 
	ivd.product_code = td.product_code and 
	ivd.saleid = 2 and 
	iva.invoiceid = itc.invoiceid and 
	itc.product_code = td.product_code and 
	ivd.taxcode2 <> 0 and 
	tax.tax_code = @TaxID
)

	If @BreakupFlag = 1
	Begin
		Insert into @TaxPayable
		select distinct N'SSCT ', taxcomponent_desc + '_of_' + tax_description, tcd.taxcomponent_code  
		from invoicetaxcomponents itc
		Inner Join  invoicedetail idt On itc.invoiceid=idt.invoiceid and idt.product_code=itc.product_code and idt.taxid=itc.tax_code 
		Inner Join  invoiceabstract ia On itc.invoiceid=ia.invoiceid 
		Inner Join  taxcomponentdetail tcd On tcd.taxcomponent_code=itc.tax_component_code 
		Left Outer Join  customer c On ia.customerid=c.customerid 
		Inner Join  tax  On itc.tax_code = tax.tax_code 
		where       
		(ia.status & 128 )=0 and      
		ia.invoicedate between @FromDate and @ToDate and       
		idt.taxid=@TaxID and 
		idt.taxcode2 <> 0 and 
		idt.saleid=2 
		order by tcd.taxcomponent_code 
	End

	Declare TaxPayable cursor  
	for  
	Select * From @TaxPayable

	open TaxPayable  
	fetch next from TaxPayable into @Prefix, @TaxCompDesc, @TmpTaxCompCode  
	while @@FETCH_STATUS=0  
	begin  
	 set @Query = N'alter table #TaxPayableByTaxDetails add ['+@Prefix+rtrim(@TaxCompDesc)+ N' (%c)] decimal(18,6)'    	
	 exec sp_executesql @Query    
	 fetch next from TaxPayable into @Prefix, @TaxCompDesc, @TmpTaxCompCode  
	end  
	close TaxPayable  
	deallocate TaxPayable  

	Select Distinct InvoiceID, Product_Code, SaleID, TaxID, TaxCode, TaxCode2 Into #InvDet From InvoiceDetail Where InvoiceID in 
	(Select InvoiceID From InvoiceAbstract Where IsNull(Status,0) & 128 = 0 And 
	InvoiceDate Between @FromDate and @ToDate) and (TaxCode <> 0 or TaxCode2 <> 0)
	
  Create Table #UpdateData (ItemCode nVarChar(15) Collate SQL_Latin1_General_CP1_CI_AS, CompDesc nVArChar(255), LST_Flag int,SaleID int,TaxVal Decimal(18,6),TaxDesc nVarChar(255))

-- 	declare TaxPayable Cursor  
-- 	for   
  Insert Into #UpdateData (ItemCode, CompDesc, LST_Flag,SaleID, TaxVal, TaxDesc)
	select TPD.product_Code, tcd.taxcomponent_desc, 
	(Case When (idt.taxcode <> 0) Then 1 When (idt.taxcode2 <> 0) Then 2 End), 
	idt.saleid, sum(case When invoicetype In (4,5,6) then 0-tax_value else tax_value end), tax.tax_description 
	from #TaxPayableByTaxDetails TPD 
	Inner Join  invoicetaxcomponents itc  On itc.product_code = tpd.product_code
	Inner Join  invoiceabstract ia On ia.invoiceid=itc.invoiceid
	Left Outer Join  customer c On ia.customerid=c.customerid
	Inner Join  #InvDet idt On ia.invoiceid=idt.invoiceid and idt.Product_Code = itc.Product_Code and idt.taxid=itc.tax_code 
	Inner Join  taxcomponentdetail tcd On tcd.taxcomponent_code=itc.tax_component_code 
	Inner Join  tax On itc.tax_code = tax.tax_code
	where    
	(status & 128)=0 And 
	ia.invoicedate between @FromDate and @ToDate and       
	idt.taxid = @TaxID 
	group by TPD.product_Code, tcd.taxcomponent_desc, SaleID, tax.tax_description, idt.taxcode, idt.taxcode2 --Locality, 
	  
  Insert Into #UpdateData (ItemCode, CompDesc, LST_Flag,SaleID, TaxVal, TaxDesc)
	select TPD.product_Code, '', 
	(Case When (idt.taxcode <> 0) Then 1 When (idt.taxcode2 <> 0) Then 2 End), 
	idt.saleid, sum(case When invoicetype In (4,5,6) then 0-(STPayable+CSTPayable) else (STPayable+CSTPayable) end), tax.tax_description 
	from #TaxPayableByTaxDetails TPD 
	Inner Join InvoiceDetail idt On idt.Product_Code = tpd.Product_Code 
	Inner Join invoiceabstract ia On ia.invoiceid=idt.invoiceid
	Left Outer Join  customer c On ia.customerid=c.customerid
	Inner Join tax On idt.taxid = tax.tax_code 
	where    
	(status & 128)=0 And 
	ia.invoicedate between @FromDate and @ToDate and       
  (idt.TaxCode <> 0 Or idt.TaxCode2 <> 0) And
	idt.taxid = @TaxID and 
	tax.tax_description Not In
(
	select Distinct tax.tax_description 
	from #TaxPayableByTaxDetails TPD1
	Inner Join  invoicetaxcomponents itc On itc.product_code = tpd1.product_code 
	Inner Join invoiceabstract ina On ina.invoiceid=itc.invoiceid 
	Left Outer Join  customer c1 On ina.customerid=c1.customerid 
	Inner Join  #InvDet indt On indt.Product_Code = itc.Product_Code and ina.invoiceid=indt.invoiceid and indt.taxid=itc.tax_code 
	Inner Join  taxcomponentdetail tcd On tcd.taxcomponent_code=itc.tax_component_code 
	Inner Join  tax On itc.tax_code = tax.tax_code 
	where    
	(status & 128)=0 And 
	ina.invoicedate between @FromDate and @ToDate and       
	indt.taxid = @TaxID 
)
	group by TPD.product_Code, SaleID, tax.tax_description, idt.taxcode, idt.taxcode2

	declare TaxPayable Cursor  
	for 
	Select ItemCode, CompDesc, LST_Flag, SaleID, TaxVal, TaxDesc from #UpdateData

	open TaxPayable  
	fetch next from TaxPayable into @ProductCode, @TaxCompDesc, @Locality, @QueryaleID, @TaxValue, @TaxDesc  
	while @@FETCH_STATUS=0   
	begin  
		if isnull(@Locality,1) = 1 and @QueryaleID = 1    
		begin 
			If @BreakupFlag = 1
				if @TaxCompDesc <> N''
					set @Query = N'update #TaxPayableByTaxDetails set [FSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N', [FSLT '+rtrim(@TaxCompDesc)+ N'_of_' + rtrim(@TaxDesc) + N' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
				Else
					set @Query = N'update #TaxPayableByTaxDetails set [FSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
			Else
				set @Query = N'update #TaxPayableByTaxDetails set [FSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+ N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
--c				--set @Query = N'update #TaxPayableByTaxDetails set [FSLT '+rtrim(@TaxCompDesc)+N'_of_' + rtrim(@TaxDesc) + N' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
		end    
		else if isnull(@Locality,1) = 2 and @QueryaleID = 1    
		begin    
			If @BreakupFlag = 1
				if @TaxCompDesc <> N''
					set @Query = N'update #TaxPayableByTaxDetails set [FSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+N', [FSCT '+rtrim(@TaxCompDesc)+ N'_of_' + rtrim(@TaxDesc) + N' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
				Else
					set @Query = N'update #TaxPayableByTaxDetails set [FSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
			Else
				set @Query = N'update #TaxPayableByTaxDetails set [FSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([FSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
--c				--set @Query = N'update #TaxPayableByTaxDetails set [FSCT '+rtrim(@TaxCompDesc)+ N'_of_' + rtrim(@TaxDesc) + N' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
		end    
		else if isnull(@Locality,1) = 1 and @QueryaleID = 2    
		begin    
			If @BreakupFlag = 1
				if @TaxCompDesc <> N''
					set @Query = N'update #TaxPayableByTaxDetails set [SSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+N', [SSLT '+rtrim(@TaxCompDesc)+ N'_of_' + rtrim(@TaxDesc) + N' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
				Else 
					set @Query = N'update #TaxPayableByTaxDetails set [SSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
			Else
				set @Query = N'update #TaxPayableByTaxDetails set [SSLT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSLT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
--c				--set @Query = N'update #TaxPayableByTaxDetails set [SSLT '+rtrim(@TaxCompDesc)+ N'_of_' + rtrim(@TaxDesc) + N' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
		end    
		else if isnull(@Locality,1) = 2 and @QueryaleID = 2    
		begin    
			If @BreakupFlag = 1
				if @TaxCompDesc <> N''
					set @Query = N'update #TaxPayableByTaxDetails set [SSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+N', [SSCT '+rtrim(@TaxCompDesc)+ N'_of_' + rtrim(@TaxDesc) + N' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
				Else
					set @Query = N'update #TaxPayableByTaxDetails set [SSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
			Else
				set @Query = N'update #TaxPayableByTaxDetails set [SSCT '+rtrim(@TaxDesc)+N' (%c)]=IsNull([SSCT '+rtrim(@TaxDesc)+N' (%c)],0) + '+convert(nvarchar,@TaxValue)+N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
--c				--set @Query = N'update #TaxPayableByTaxDetails set [SSCT '+rtrim(@TaxCompDesc)+ N'_of_' + rtrim(@TaxDesc) + N' (%c)]='+convert(nvarchar,@TaxValue)+ N' from #TaxPayableByTaxDetails where product_code=N'''+@ProductCode+''''
		end    
		exec sp_executesql @Query    
		fetch next from TaxPayable into @ProductCode, @TaxCompDesc, @Locality, @QueryaleID, @TaxValue, @TaxDesc  
	end  
	  
	close TaxPayable  
	deallocate TaxPayable  
	
	update TPD set TPD.[First Sale Total (%c)]=(
	select sum(case When invoicetype In (4,5,6) then 0-(stpayable+cstpayable) else (stpayable+cstpayable) end) 
	from invoicedetail idt, invoiceabstract ia
	where 
	(ia.status & 128)=0 and 
	ia.invoicedate between @FromDate and @ToDate and
	idt.product_code=TPD.product_code and 
	ia.invoiceid=idt.invoiceid and 
	idt.taxid=@TaxID and
	saleid=1 )
	from #TaxPayableByTaxDetails TPD
	
	update TPD set TPD.[FSLT Total (%c)]=(
	select sum(case When invoicetype In (4,5,6) then 0-stpayable else stpayable end) 
	from invoicedetail idt, invoiceabstract ia
	where 
	(ia.status & 128)=0 and 
	ia.invoicedate between @FromDate and @ToDate and
	idt.product_code=TPD.product_code and 
	ia.invoiceid=idt.invoiceid and 
	idt.taxid=@TaxID and
	saleid=1)
	from #TaxPayableByTaxDetails TPD
	
	update TPD set TPD.[FSCT Total (%c)]=(
	select sum(case When invoicetype In (4,5,6) then 0-cstpayable else cstpayable end) from invoicedetail idt, invoiceabstract ia
	where 
	(ia.status & 128)=0 and 
	ia.invoicedate between @FromDate and @ToDate and
	idt.product_code=TPD.product_code and 
	ia.invoiceid=idt.invoiceid and 
	idt.taxid=@TaxID and
	saleid=1)
	from #TaxPayableByTaxDetails TPD
	  
	update TPD set TPD.[Second Sale Total (%c)]=(
	select sum(case When invoicetype In (4,5,6) then 0-(stpayable+cstpayable) else stpayable+cstpayable end) from invoicedetail idt, invoiceabstract ia
	where 
	(ia.status & 128)=0 and 
	ia.invoicedate between @FromDate and @ToDate and
	idt.product_code=TPD.product_code and 
	ia.invoiceid=idt.invoiceid and 
	idt.taxid=@TaxID and
	saleid=2)
	from #TaxPayableByTaxDetails TPD
	
	update TPD set TPD.[SSLT Total (%c)]=(
	select sum(case When invoicetype In (4,5,6) then 0-stpayable else stpayable end) 
	from invoicedetail idt, invoiceabstract ia
	where 
	(ia.status & 128)=0 and 
	ia.invoicedate between @FromDate and @ToDate and
	idt.product_code=TPD.product_code and 
	ia.invoiceid=idt.invoiceid and 
	idt.taxid=@TaxID and
	saleid=2)
	from #TaxPayableByTaxDetails TPD
	
	update TPD set TPD.[SSCT Total (%c)]=(
	select sum(case When invoicetype In (4,5,6) then 0-cstpayable else cstpayable end) from invoicedetail idt, invoiceabstract ia
	where 
	(ia.status & 128)=0 and 
	ia.invoicedate between @FromDate and @ToDate and
	idt.product_code=TPD.product_code and 
	ia.invoiceid=idt.invoiceid and 
	idt.taxid=@TaxID and
	saleid=2)
	from #TaxPayableByTaxDetails TPD
	
	update #TaxPayableByTaxDetails set [First Sale Total (%c)]=null where [First Sale Total (%c)]=0
	update #TaxPayableByTaxDetails set [FSLT Total (%c)]=null where [FSLT Total (%c)]=0
	update #TaxPayableByTaxDetails set [FSCT Total (%c)]=null where [FSCT Total (%c)]=0
	update #TaxPayableByTaxDetails set [Second Sale Total (%c)]=null where [Second Sale Total (%c)]=0
	update #TaxPayableByTaxDetails set [SSLT Total (%c)]=null where [SSLT Total (%c)]=0
	update #TaxPayableByTaxDetails set [SSCT Total (%c)]=null where [SSCT Total (%c)]=0
	
	select * from #TaxPayableByTaxDetails  

  Drop table #UpdateData
	drop table #TaxPayableByTaxDetails 
	drop table #TaxDetails
	drop table #InvDet 
End
Else -- TaxID = 0
Begin
		Select Distinct ivd.Product_Code,"Item Code" = ivd.Product_Code, "Product Name" = Items.ProductName 
		From InvoiceAbstract iva, InvoiceDetail ivd, Items  
		Where IsNull(iva.Status,0) & 128 = 0 And 
		iva.InvoiceDate between @FromDate AND @ToDate AND    
		iva.InvoiceID = ivd.InvoiceID AND 
		ivd.TaxCode = 0 AND ivd.TaxCode2 = 0 AND 
		ivd.UOMQty <> 0 AND
		ivd.Product_Code = Items.Product_Code 
		Group By ivd.Invoiceid,Serial,ivd.Product_Code,ProductName

		
End

GSTOut:

End 
