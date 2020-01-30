Create PROCEDURE spr_Taxwisereport_ITC (@FROMDATE datetime, @TODATE datetime, @Taxes nVarchar(4000), @Breakup nVarchar(3))  
    
as    
Begin    

	declare @TaxCompDesc nvarchar(255)    
	declare @Prefix nvarchar(50)    
	declare @TaxCode numeric    
	declare @TaxCompCode numeric    
	declare @Query nvarchar(4000)    
	declare @Locality nvarchar(10)    
	declare @Tax decimal(18,6)  
	declare @TaxDesc nvarchar(255)  
	declare @PrevTaxDesc nvarchar(255)  
	declare @BreakupFlag int
	declare @TmpTaxCompCode int
	declare @LSTFlag int
	declare @Delimeter char(1)
	declare @temp datetime
	Set @Delimeter=Char(15)    
	Set DATEFormat DMY
	set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)

If(@FROMDATE > @temp )
Begin
 Select 0,'This report cannot be generated for GST period' as Reason
 GoTo GSTOut
End


If(@TODATE > @temp )
Begin
Set @TODATE  = @temp 
--goto GSTOut
End


	
	If Upper(@Breakup) = N'YES'
		Set @BreakupFlag = 1
	Else
		Set @BreakupFlag = 0
	
	Create Table #Taxes (TaxDesc nVarchar(255) Collate SQL_Latin1_General_CP1_CI_AS)
	
	If @Taxes='%'
		Insert into #Taxes Select Distinct Tax_Description From Tax
	Else
		Insert into #Taxes Select Distinct Tax_Description From Tax where Tax_Description in (Select * From Dbo.sp_SplitIn2Rows(@Taxes,@Delimeter))
	
-- 	select Tax_Code, "Tax Description" = (Case When Tax.Percentage = 0 And Tax.CST_Percentage = 0 Then 'Exempt' Else Tax.Tax_Description End),      
-- 	"Local Sales Tax%" = percentage, "LT Value (%c.)" = ISNULL(sum(case when invoicetype In (4,5,6) then 0-STPayable else STPayable end), 0)    
-- 	into #TaxPayableByTaxAbstract    
-- 	FROM InvoiceAbstract ia, InvoiceDetail idt, tax    
-- 	WHERE      
-- 	(ia.Status & 128) = 0 AND     
-- 	ia.InvoiceDate between @FromDate AND @ToDate AND      
-- 	ia.InvoiceID = idt.InvoiceID AND      
-- 	idt.taxid=tax.tax_code and 
-- 	tax.tax_description in (Select * From #Taxes)   
-- 	GROUP BY Tax_Code, Tax_Description, Percentage, CST_Percentage      

	select Tax_Code, "Tax Description" = Tax.Tax_Description,      
	"Local Sales Tax%" = percentage, "LT Value (%c.)" = ISNULL(sum(case when invoicetype In (4,5,6) then 0-STPayable else STPayable end), 0)    
	into #TaxPayableByTaxAbstract    
	FROM InvoiceAbstract ia, InvoiceDetail idt, tax    
	WHERE      
	(ia.Status & 128) = 0 AND     
	ia.InvoiceDate between @FromDate AND @ToDate AND      
	ia.InvoiceID = idt.InvoiceID AND 
	(idt.taxcode <> 0 or idt.Taxcode2 <> 0) and      
	idt.taxid=tax.tax_code and 
	tax.tax_description in (Select * From #Taxes)   
	GROUP BY Tax_Code, Tax_Description, percentage

	
	
	Select * Into #TaxAbstract From #TaxPayableByTaxAbstract
	
	Declare TaxPayableLT cursor    
	for    
	select distinct N'LT ', taxcomponent_desc, tax_description, tcd.taxcomponent_code, 1 
	from #TaxAbstract ta, 
	invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, tax 
	where         
	(ia.status & 128 )=0 and        
	ia.invoicedate between @FromDate and @ToDate and         
	itc.invoiceid=idt.invoiceid and         
	itc.invoiceid=ia.invoiceid and        
	idt.product_code=itc.product_code and         
	ta.tax_code = idt.taxid and 
	idt.taxid=itc.tax_code and         
	idt.taxid=tax.tax_code and   
	tcd.taxcomponent_code=itc.tax_component_code and 
	idt.taxcode <> 0 
Union
	select distinct N'LT ', '', tax_description, 0, 1 
	from #TaxAbstract ta1, 
  invoicedetail invdt, invoiceabstract inva, tax 
	where         
	(inva.status & 128 )=0 and        
	inva.invoicedate between @FromDate and @ToDate and         
	inva.invoiceid=invdt.invoiceid and
	ta1.tax_code = invdt.taxid and 
	invdt.taxid=tax.tax_code and   
	invdt.taxcode <> 0 And tax_description Not In
(	select distinct tax_description
	from #TaxAbstract ta, 
	invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, tax 
	where         
	(ia.status & 128 )=0 and        
	ia.invoicedate between @FromDate and @ToDate and         
	itc.invoiceid=idt.invoiceid and         
	itc.invoiceid=ia.invoiceid and        
	idt.product_code=itc.product_code and         
	ta.tax_code = idt.taxid and 
	idt.taxid=itc.tax_code and         
	idt.taxid=tax.tax_code and   
	tcd.taxcomponent_code=itc.tax_component_code and 
	idt.taxcode <> 0 )
order by tax_description, tcd.taxcomponent_code   
	
--	begin tran    
	Set @PrevTaxDesc = N''  
	open TaxPayableLT    
	fetch from TaxPayableLT into @Prefix, @TaxCompDesc, @TaxDesc, @TmpTaxCompCode, @LSTFlag    
	while @@FETCH_STATUS=0    
	begin   
		If @LSTFlag = 1
		Begin
			If (@TaxDesc <> @PrevTaxDesc) and (@Prefix <> N'Central Sales Tax') --and (@BreakupFlag = 1) 
			Begin  
			 set @Query = N'alter table #TaxPayableByTaxAbstract add [LT '+ rtrim(@TaxDesc) + N' (%c.)] decimal(18,6)'      
			 exec sp_executesql @Query      
			End  
      if (@BreakupFlag = 1) And @TaxCompDesc <> N''
       Begin
		    set @Query = N'alter table #TaxPayableByTaxAbstract add [LT '+rtrim(@TaxCompDesc)+ N'_of_'+ rtrim(@TaxDesc) +' (%c.)] decimal(18,6)'      
			  exec sp_executesql @Query      
       End
		End
		Set @PrevTaxDesc = @TaxDesc  
		fetch next from TaxPayableLT into @Prefix, @TaxCompDesc, @TaxDesc, @TmpTaxCompCode, @LSTFlag    
	end    
	close TaxPayableLT    
	Deallocate TaxPayableLT    
	
	alter table #TaxPayableByTaxAbstract add  [Central Sales Tax%] decimal(18,6)    
	alter table #TaxPayableByTaxAbstract add  [CT Value (%c.)] decimal(18,6)    
	
	Declare TaxPayableCT cursor    
	for    
	select distinct N'CT ', taxcomponent_desc, tax_description, tcd.taxcomponent_code, 0 
	from #TaxAbstract ta, 
	invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, tax 
	where         
	(ia.status & 128 )=0 and        
	ia.invoicedate between @FromDate and @ToDate and         
	itc.invoiceid=idt.invoiceid and         
	itc.invoiceid=ia.invoiceid and        
	idt.product_code=itc.product_code and         
	ta.tax_code = idt.taxid and 
	idt.taxid=itc.tax_code and         
	idt.taxid=tax.tax_code and   
	tcd.taxcomponent_code=itc.tax_component_code and 
	idt.taxcode2 <> 0 
  Union
	select distinct N'CT ', '', tax_description, 0, 0 
	from #TaxAbstract ta1, 
  invoicedetail invdt, invoiceabstract inva, tax 
	where         
	(inva.status & 128 )=0 and        
	inva.invoicedate between @FromDate and @ToDate and         
	inva.invoiceid=invdt.invoiceid and         
	ta1.tax_code = invdt.taxid and 
	invdt.taxid=tax.tax_code and   
	invdt.taxcode2 <> 0 And tax_description Not In
(
	select distinct tax_description
	from #TaxAbstract ta, 
	invoicetaxcomponents itc, invoicedetail idt, invoiceabstract ia, taxcomponentdetail tcd, tax 
	where         
	(ia.status & 128 )=0 and        
	ia.invoicedate between @FromDate and @ToDate and         
	itc.invoiceid=idt.invoiceid and         
	itc.invoiceid=ia.invoiceid and        
	idt.product_code=itc.product_code and         
	ta.tax_code = idt.taxid and 
	idt.taxid=itc.tax_code and         
	idt.taxid=tax.tax_code and   
	tcd.taxcomponent_code=itc.tax_component_code and 
	idt.taxcode2 <> 0 
)
	order by tax_description,tcd.taxcomponent_code   
	  
	Set @PrevTaxDesc = N''  
	open TaxPayableCT    
	fetch next from TaxPayableCT into @Prefix, @TaxCompDesc, @TaxDesc, @TmpTaxCompCode, @LSTFlag    
	while @@FETCH_STATUS=0    
	begin   
		If @LSTFlag = 0
		Begin 
			If (@TaxDesc <> @PrevTaxDesc) and (@Prefix <> N'Central Sales Tax') --and (@BreakupFlag = 1)  
			 Begin  
			  set @Query = N'alter table #TaxPayableByTaxAbstract add [CT '+ rtrim(@TaxDesc) + N' (%c.)] decimal(18,6)'      
			  exec sp_executesql @Query      
			 End  
      if (@BreakupFlag = 1) And @TaxCompDesc <> N''
			 Begin
			  set @Query = N'alter table #TaxPayableByTaxAbstract add [CT '+rtrim(@TaxCompDesc)+ N'_of_'+ rtrim(@TaxDesc) +' (%c.)] decimal(18,6)'      
			  exec sp_executesql @Query     
       End
		End
		Set @PrevTaxDesc = @TaxDesc  
		fetch next from TaxPayableCT into @Prefix, @TaxCompDesc, @TaxDesc, @TmpTaxCompCode, @LSTFlag    
	end    
	close TaxPayableCT    
	deallocate TaxPayableCT    
--	commit tran    
	
	Select Distinct InvoiceID, Product_Code, SaleID, TaxID, TaxCode, TaxCode2 Into #InvDet From InvoiceDetail 
	Where InvoiceID in (Select InvoiceID From InvoiceAbstract Where IsNull(Status,0) & 128 = 0 And 
	InvoiceDate Between @FromDate and @ToDate) and (TaxCode <> 0 or TaxCode2 <> 0)

  Create Table #UpdateData (TaxID int ,CompDesc nVArChar(255)	,LST_Flag int,TaxVal Decimal(18,6),TaxDesc nVarChar(255))

-- 	Declare TaxPayable Cursor    
-- 	for     
  Insert Into #UpdateData (TaxID, CompDesc, LST_Flag, TaxVal, TaxDesc)
	Select itc.tax_code, tcd.Taxcomponent_desc, 
	(Case When (idt.taxcode <> 0) Then 1 When (idt.taxcode2 <> 0) Then 2 End), 
	sum(case when invoicetype In (4,5,6) then 0-tax_value else tax_value end), Tax_Description from     
	#TaxPayableByTaxAbstract TPA
	Inner Join invoicetaxcomponents itc On tpa.tax_code=itc.tax_code 
	Inner Join  invoiceabstract ia On ia.invoiceid = itc.invoiceid 
	Inner Join  #InvDet idt On ia.invoiceid = idt.invoiceid And idt.taxid = tpa.tax_code And idt.product_code = itc.product_code and idt.taxid = itc.tax_code 
	Inner Join  taxcomponentdetail tcd On itc.tax_component_code = tcd.taxcomponent_code 
	Left Outer Join  customer c On ia.customerid=c.customerid  
	Inner Join  tax On idt.taxid=tax.tax_code 
	Where    
	(ia.status & 128)=0 and    
	ia.invoicedate between @FromDate and @ToDate and    
  (idt.taxcode <> 0 or idt.taxcode2 <> 0) 
	Group By itc.tax_code,tcd.Taxcomponent_Code,tcd.Taxcomponent_desc, locality, Tax_Description, idt.taxcode, idt.taxcode2     

  Insert Into #UpdateData (TaxID, CompDesc, LST_Flag, TaxVal, TaxDesc)
	Select T1.tax_code, '', 
	(Case When (invdt.taxcode <> 0) Then 1 When (invdt.taxcode2 <> 0) Then 2 End), 
	sum(case when invoicetype In (4,5,6) then 0-(STPayable+CSTPayable) else (STPayable+CSTPayable) end), Tax_Description from     
	#TaxPayableByTaxAbstract TPA1
	Inner Join InvoiceDetail invdt On invdt.taxid = tpa1.tax_code 
	Inner Join invoiceabstract inva On inva.invoiceid = invdt.invoiceid 
	Left Outer Join  customer c1 On inva.customerid=c1.customerid  
	Inner Join  tax T1 On invdt.taxid = t1.tax_code and tpa1.tax_code = t1.tax_code 
	Where    
	(inva.status & 128)=0 and    
	inva.invoicedate between @FromDate and @ToDate and    
  (invdt.taxcode <> 0 or invdt.taxcode2 <> 0) and
 Tax_Description Not In
 (
	Select Distinct Tax_Description from     
	#TaxPayableByTaxAbstract TPA
	Inner Join #InvDet idt On idt.taxid = tpa.tax_code 
	Inner Join  invoiceabstract ia On ia.invoiceid = idt.invoiceid 
	Inner Join  invoicetaxcomponents itc On idt.taxid = itc.tax_code  and ia.invoiceid = itc.invoiceid and  idt.product_code = itc.product_code 
	Inner Join  taxcomponentdetail tcd On itc.tax_component_code = tcd.taxcomponent_code 
	Left Outer Join customer c On ia.customerid=c.customerid  
	Inner Join  tax    On idt.taxid=tax.tax_code 
	Where    
	(ia.status & 128)=0 and    
	ia.invoicedate between @FromDate and @ToDate and    
  (idt.taxcode <> 0 or idt.taxcode2 <> 0) and  
	tpa.tax_code=itc.tax_code 
	)
	Group By t1.tax_code, locality, Tax_Description, invdt.taxcode, invdt.taxcode2

	Declare TaxPayable Cursor    
	for     
  select TaxID, CompDesc, LST_Flag, TaxVal, TaxDesc From #UpdateData

	Set @PrevTaxDesc = N''
	open TaxPayable    
	fetch next from TaxPayable into @TaxCode, @TaxCompDesc, @Locality, @Tax, @TaxDesc    
	while @@FETCH_STATUS=0     
	begin    
		if isnull(@Locality,1) = N'1'    
		begin    
			 If @BreakupFlag = 1
          if @TaxCompDesc <> N''
				   set @Query = N'update TPA set [LT '+ rtrim(@TaxDesc) + N' (%c.)] = IsNull([LT '+ rtrim(@TaxDesc) + N' (%c.)],0) + '+ convert(nvarchar,@Tax) +', [LT '+rtrim(@TaxCompDesc)+N'_of_'+ rtrim(@TaxDesc) +' (%c.)] = '+convert(nvarchar,@Tax)+N' from #TaxPayableByTaxAbstract TPA where TPA.Tax_Code='+convert(nvarchar,@TaxCode) 
          Else
				   set @Query = N'update TPA set [LT '+ rtrim(@TaxDesc) + N' (%c.)] = IsNull([LT '+ rtrim(@TaxDesc) + N' (%c.)],0) + '+ convert(nvarchar,@Tax) +N' from #TaxPayableByTaxAbstract TPA where TPA.Tax_Code='+convert(nvarchar,@TaxCode) 
			 Else
				  set @Query = N'update TPA set [LT '+ rtrim(@TaxDesc) + N' (%c.)] = IsNull([LT '+ rtrim(@TaxDesc) + N' (%c.)],0) + '+ convert(nvarchar,@Tax)  +N' from #TaxPayableByTaxAbstract TPA where TPA.Tax_Code='+convert(nvarchar,@TaxCode) 
-- 				  set @Query = N'update TPA set [LT '+rtrim(@TaxCompDesc)+N'_of_'+ rtrim(@TaxDesc) +' (%c.)] = '+convert(nvarchar,@Tax)+ N' from     
-- 				  #TaxPayableByTaxAbstract TPA where TPA.Tax_Code='+convert(nvarchar,@TaxCode) 
		end    
		else if isnull(@Locality,1) = N'2'   
		begin    
			 If @BreakupFlag = 1
				 If  @TaxCompDesc <> N''
					set @Query = N'update TPA set [CT '+ rtrim(@TaxDesc) + N' (%c.)] = IsNull([CT '+ rtrim(@TaxDesc) + N' (%c.)],0) + '+ convert(nvarchar,@Tax) +', [CT '+rtrim(@TaxCompDesc)+N'_of_'+ rtrim(@TaxDesc) +' (%c.)] = '+convert(nvarchar,@Tax)+N' from #TaxPayableByTaxAbstract TPA where TPA.Tax_Code='+convert(nvarchar,@TaxCode)    
         Else
				  set @Query = N'update TPA set [CT '+ rtrim(@TaxDesc) + N' (%c.)] = IsNull([CT '+ rtrim(@TaxDesc) + N' (%c.)],0) + '+ convert(nvarchar,@Tax) +N' from #TaxPayableByTaxAbstract TPA where TPA.Tax_Code='+convert(nvarchar,@TaxCode)    
			 Else
				  set @Query = N'update TPA set [CT '+ rtrim(@TaxDesc) + N' (%c.)] = IsNull([CT '+ rtrim(@TaxDesc) + N' (%c.)],0) + '+ convert(nvarchar,@Tax) +N' from #TaxPayableByTaxAbstract TPA where TPA.Tax_Code='+convert(nvarchar,@TaxCode)    
-- 				  set @Query = N'update TPA set [CT '+rtrim(@TaxCompDesc)+N'_of_'+ rtrim(@TaxDesc) +' (%c.)] = '+convert(nvarchar,@Tax)+ N' from     
-- 				  #TaxPayableByTaxAbstract TPA where TPA.Tax_Code='+convert(nvarchar,@TaxCode)    
		end    
		exec sp_executesql @Query    
		fetch next from TaxPayable into @TaxCode, @TaxCompDesc, @Locality, @Tax, @TaxDesc    
	end    
	    
	set @Query = N'update TPA set [Central Sales Tax%] = cst_percentage from #TaxPayableByTaxAbstract TPA, Tax where tpa.tax_code=tax.tax_code'
	exec sp_executesql @Query    
	    
	set @Query = N'update TPA set [CT Value (%c.)] =     
	 (select sum(case when invoicetype In (4,5,6) then 0-cstpayable else cstpayable end) from invoicedetail idt, invoiceabstract ia     
	 where isnull(status,0) & 128 = 0 and 
	ia.invoicedate between '''+convert(nvarchar,@FromDate)+''' and '''+convert(nvarchar,@ToDate)+''' and    
	ia.invoiceid=idt.invoiceid and idt.taxid=tpa.tax_code)    
	from #TaxPayableByTaxAbstract TPA, invoicedetail idt, invoiceabstract ia    
	where     
	tpa.tax_code=idt.taxid and     
	idt.invoiceid=ia.invoiceid'    
	
	exec sp_executesql @Query    
	


	If @Taxes = '%'
	Begin
		If Exists(Select ia.InVoiceID FROM InvoiceAbstract ia, InvoiceDetail idt, tax    
		WHERE (ia.Status & 128) = 0 AND ia.InvoiceDate between @FromDate AND @ToDate AND      
		ia.InvoiceID = idt.InvoiceID AND (idt.taxcode = 0 and idt.Taxcode2 = 0) AND idt.UOMQty <> 0 And idt.taxid=tax.tax_code and 
		tax.tax_description in (Select * From #Taxes))
		

		Insert Into #TaxPayableByTaxAbstract (Tax_Code, [Tax Description], [Local Sales Tax%], [LT Value (%c.)])    
		select 0, 'Exempt', 0, 0      
	End	
	Else
	Begin
		If Exists(Select * From #Taxes, Tax Where #Taxes.TaxDesc = Tax.Tax_Description And percentage = 0 and cst_percentage = 0)
			Insert Into #TaxPayableByTaxAbstract (Tax_Code, [Tax Description], [Local Sales Tax%], [LT Value (%c.)])    
			select 0, 'Exempt', 0, 0      
	End


	select * from #TaxPayableByTaxAbstract order by tax_code   
	close TaxPayable    
	deallocate TaxPayable    
	    
	drop table #TaxPayableByTaxAbstract    
	drop table #Taxes
	drop table #TaxAbstract
	drop table #InvDet
    Drop Table #UpdateData
  
  GSTOut: 

end   

