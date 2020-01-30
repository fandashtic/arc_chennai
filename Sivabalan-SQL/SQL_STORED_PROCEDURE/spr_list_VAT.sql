CREATE procedure spr_list_VAT
(

	@FromDate datetime, 
	@ToDate DateTime,
	@Tax nvarchar(10),
	@Locality nvarchar(15),
	@ItemCode nvarchar(2550),
	@ItemName nvarchar(2550)
)	
as

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)
create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
create table #tmpProdName(product_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @ItemCode='%'
   insert into #tmpProd select product_code from items
else
   insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode,@Delimeter)
if @ItemName='%'
   insert into #tmpProdName select ProductName from items
else
   insert into #tmpProdName select * from dbo.sp_SplitIn2Rows(@ItemName,@Delimeter)

begin

	create table #VATReport
	(
		[ICode] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[Item Code] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[Item Name] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[Tax %] nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
		[Total Purchase (%c)]  Decimal(18,6),
		[Tax on Purchase (%c)]  Decimal(18,6),
		[Total Purchase Return (%c)]  Decimal(18,6),
		[Tax on Purchase Return (%c)]  Decimal(18,6),
		[Net Purchase (%c)]  Decimal(18,6),
		[Net Purchase Tax (%c)]  Decimal(18,6),
		[Total Sales (%c)]  Decimal(18,6),
		[Tax on Sales (%c)]  Decimal(18,6),
		[Sales Return Saleable (%c)]  Decimal(18,6),
		[Tax on Sales Return Saleable (%c)]  Decimal(18,6),
		[Sales Return Damages (%c)]  Decimal(18,6),
		[Tax on Sales Return Damages (%c)]  Decimal(18,6),
		[Net Sales Return (%c)]  Decimal(18,6),
		[Net Tax on Sales Return (%c)]  Decimal(18,6),
		[Net Sales (%c)]  Decimal(18,6),
		[Net Tax on Sales (%c)]  Decimal(18,6),
		[Net VAT Payable (%c)] Decimal(18,6)
	)


	if Isnumeric(@Tax) = 1
	begin
		set @Tax = convert(nvarchar,convert(decimal(18,6),@Tax))
	end
	else
	begin
		set @Tax = '%'
	end
	
	--take distinct (products and tax percentages) from Bills, Adj Returns and Invoices
	insert into #VATReport (ICode, [Item Code], [Item Name], [Tax %])
		select Distinct	It.Product_Code, It.Product_Code, It.ProductName, BD.TaxSuffered
		from Items It, BillAbstract BA, BillDetail BD, Vendors V
		where 
			It.ProductName In (select product_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProdName)
			and BD.Product_Code in(select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
			and BA.BillID = BD.BillID
			and BD.Product_Code = It.Product_Code
			and BA.BillDate between @FromDate and @ToDate
			and BA.Status = 0
			and convert(nvarchar,BD.TaxSuffered) like @Tax
			and V.VendorID = BA.VendorID
			and V.Locality like (
									case @Locality 
									when 'Local' then '1'
									when 'Outstation' then '2'
									else '%' end
								)
		group by It.Product_Code, It.ProductName, BD.TaxSuffered
		having SUM(BD.Amount + BD.TaxAmount)>0
	union
		select Distinct	It.Product_Code, It.Product_Code, It.ProductName, ARD.Tax
		from Items It, AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V
		where It.ProductName In (select product_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProdName)
			and It.Product_Code in(select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
			and ARA.AdjustmentID = ARD.AdjustmentID
			and (isnull(ARA.Status,0) & 128) = 0
			and ARD.Product_Code = It.Product_Code
			and ARA.AdjustmentDate between @FromDate and @ToDate
			and convert(nvarchar,ARD.Tax) like @Tax
			and ARA.VendorID = V.VendorID
			and cast(V.Locality as nvarchar) like (case @Locality 
													when 'Local' then '1' 
													when 'Outstation' then '2' 
													else '%' end) + '%'
		group by It.Product_Code, It.ProductName, ARD.Tax
		having sum(ARD.Total_Value)>0
	union
		select Distinct	It.Product_Code, It.Product_Code, It.ProductName, IDt.TaxCode
		from Items It, InvoiceAbstract IA, InvoiceDetail IDt, Customer C
		where 
			It.ProductName In (select product_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProdName)
			and IDt.Product_Code in(select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
			and IA.InvoiceID = IDt.InvoiceID
			and IDt.Product_Code = It.Product_Code
			and IA.InvoiceDate between @FromDate and @ToDate
			and (
					(--Trade Invoice----------------
						(IA.Status & 192) = 0
						and IA.InvoiceType in (1, 3)
					)-------------------------------
					or 
					(--Sales Return-----------------
						(
							(IA.Status & 32) = 0 
							or (IA.Status & 32) <> 0 
						)
						and IA.InvoiceType = 4
					)-------------------------------
				)
				and (case @Locality
					when 'Local' then (select top 1 convert(nvarchar,IDt.TaxCode) from InvoiceDetail IDT1
										where IDt1.InvoiceID = IDt.InvoiceID
										and IDt1.Product_Code = IDt.Product_Code
										and convert(nvarchar,TaxCode) like @Tax)
					when 'Outstation' then (select top 1 convert(nvarchar,IDt.TaxCode2) from InvoiceDetail IDT1
										where IDt1.InvoiceID = IDt.InvoiceID
										and IDt1.Product_Code = IDt.Product_Code
										and convert(nvarchar,TaxCode2) like @Tax)
					else (select top 1 @Tax from InvoiceDetail IDT1
										where IDt1.InvoiceID = IDt.InvoiceID
										and IDt1.Product_Code = IDt.Product_Code
										and (
												convert(nvarchar,TaxCode) like @Tax
												or convert(nvarchar,TaxCode2) like @Tax
											)
							)
					end) like @Tax 
			and C.CustomerID = IA.CustomerID
			and C.Locality like (
									case @Locality 
									when 'Local' then '1'
									when 'Outstation' then '2'
									else '%' end
								)
		group by It.Product_Code, It.ProductName, IDt.TaxCode
		having sum(IDt.Amount)>0
	order by It.ProductName, BD.TaxSuffered

	--Total Purchase amount
	update #VATReport set [Total Purchase (%c)] = 	(
		select SUM(BD.Amount + BD.TaxAmount)
		from BillDetail BD, BillAbstract BA, Vendors V
		where BD.Product_Code = ICode
			and BD.BillID = BA.BillID
			and BA.Status = 0	
			and BA.BillDate between @FromDate and @ToDate
			and BD.TaxSuffered = convert(nvarchar,convert(decimal(18,6),[Tax %]))
			and V.VendorID = BA.VendorID
			and V.Locality like (
									case @Locality 
									when 'Local' then '1'
									when 'Outstation' then '2'
									else '%' end
								)
	)

	--Tax amount on Purchase
	update #VATReport set [Tax on Purchase (%c)] = 	(
		select SUM(BD.TaxAmount)
		from BillDetail BD, BillAbstract BA, Vendors V
		where BD.Product_Code = ICode
			and BD.BillID = BA.BillID
			and BA.Status = 0	
			and BA.BillDate between @FromDate and @ToDate
			and BD.TaxSuffered = [Tax %]
			and V.VendorID = BA.VendorID
			and V.Locality like (
									case @Locality 
									when 'Local' then '1'
									when 'Outstation' then '2'
									else '%' end
								)
	)
	
	--Total Purchase Return amount
	update #VATReport set [Total Purchase Return (%c)] = (
		select sum(ARD.Total_Value)
		from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V
		where ARA.AdjustmentID = ARD.AdjustmentID
			and (isnull(ARA.Status,0) & 128) = 0
			and ARD.Product_Code = ICode
			and ARA.AdjustmentDate between @FromDate and @ToDate
			and ARD.Tax = [Tax %]
			and V.VendorID = ARA.VendorID
			and V.Locality like (
									case @Locality 
									when 'Local' then '1'
									when 'Outstation' then '2'
									else '%' end
								)

	)

	--Tax amount on Purchase Return
	update #VATReport set [Tax on Purchase Return (%c)] = (
		select sum(ARD.Total_Value - (ARD.Quantity * ARD.Rate)) 
		from AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors V
		where ARA.AdjustmentID = ARD.AdjustmentID
			and (isnull(ARA.Status,0) & 128) = 0
			and ARD.Product_Code = ICode
			and ARA.AdjustmentDate between @FromDate and @ToDate
			and ARD.Tax = [Tax %]
			and ARA.VendorID = V.VendorID
			and cast(V.Locality as nvarchar) like (case @Locality 
													when 'Local' then '1' 
													when 'Outstation' then '2' 
													else '%' end) + '%'
	)

	update #VATReport set [Net Purchase (%c)] = isnull([Total Purchase (%c)],0) - isnull([Total Purchase Return (%c)],0)
	update #VATReport set [Net Purchase Tax (%c)] = isnull([Tax on Purchase (%c)],0) - isnull([Tax on Purchase Return (%c)],0)

	--Total sales amount
	update #VATReport set [Total Sales (%c)] = (
		select sum(IDt.Amount) 
		from InvoiceAbstract IA, InvoiceDetail IDt, Customer C
		where Idt.InvoiceID = IA.InvoiceID
			and (IA.Status & 192) = 0
			and IDt.Product_Code = ICode
			and IA.InvoiceType in (1, 3)
			and IDt.SalePrice <> 0
			and IA.InvoiceDate between @FromDate and @ToDate
			and [Tax %] = (case @Locality
				when 'Local' then (select top 1 IDt.TaxCode from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and convert(nvarchar,TaxCode) = [Tax %])
				when 'Outstation' then (select top 1 IDt.TaxCode from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and convert(nvarchar,TaxCode2) = [Tax %])
				when '%' then (select top 1 [Tax %] from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and 
									(
										convert(nvarchar,TaxCode) = [Tax %]
										or	convert(nvarchar,TaxCode2) = [Tax %]
									)
						)
				end)
			and IA.CustomerID = C.CustomerID
			and cast(C.Locality as nvarchar) like (case @Locality 
													when 'Local' then '1' 
													when 'Outstation' then '2' 
													else '%' end) + '%'
	)

	--Tax on sales
	update #VATReport set [Tax on Sales (%c)] = (
		select sum(case @Locality 
					when 'Local' then isnull(IDt.STPayable,0)
					when 'Outstation' then isnull(IDT.CSTPayable,0)
					else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end) 
		from InvoiceAbstract IA, InvoiceDetail IDt, Customer C
		where Idt.InvoiceID = IA.InvoiceID
			and (IA.Status & 192) = 0
			and IDt.Product_Code = ICode
			and IA.InvoiceType in (1, 3)
			and IDt.SalePrice <> 0
			and IA.InvoiceDate between @FromDate and @ToDate
			and [Tax %] = (case @Locality
				when 'Local' then (select top 1 IDt.TaxCode from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and convert(nvarchar,TaxCode) = [Tax %])
				when 'Outstation' then (select top 1 IDt.TaxCode from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and convert(nvarchar,TaxCode2) = [Tax %])
				when '%' then (select top 1 [Tax %] from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and 
									(
										convert(nvarchar,TaxCode) = [Tax %]
										or	convert(nvarchar,TaxCode2) = [Tax %]
									)
						)
				end)
			and IA.CustomerID = C.CustomerID
			and cast(C.Locality as nvarchar) like (case @Locality 
													when 'Local' then '1' 
													when 'Outstation' then '2' 
													else '%' end) + '%'
	)

	--Total Sales return saleable amount
	update #VATReport set [Sales Return Saleable (%c)] = (
		select sum(IDt.Amount) 
		from InvoiceAbstract IA, InvoiceDetail IDt, Customer C
		where Idt.InvoiceID = IA.InvoiceID
			and (IA.Status & 32) = 0 
			and IDt.Product_Code = ICode
			and IA.InvoiceType = 4 
			and IDt.SalePrice <> 0
			and IA.InvoiceDate between @FromDate and @ToDate
			and [Tax %] = (case @Locality
				when 'Local' then (select top 1 IDt.TaxCode from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and convert(nvarchar,TaxCode) = [Tax %])
				when 'Outstation' then (select top 1 IDt.TaxCode from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and convert(nvarchar,TaxCode2) = [Tax %])
				when '%' then (select top 1 [Tax %] from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and 
									(
										convert(nvarchar,TaxCode) = [Tax %]
										or	convert(nvarchar,TaxCode2) = [Tax %]
									)
						)
				end)
			and IA.CustomerID = C.CustomerID
			and cast(C.Locality as nvarchar) like (case @Locality 
													when 'Local' then '1' 
													when 'Outstation' then '2' 
													else '%' end) + '%'
	)

	--tax amount on sales return saleable
	update #VATReport set [Tax on Sales Return Saleable (%c)] = (
		select sum(case @Locality 
					when 'Local' then isnull(IDt.STPayable,0)
					when 'Outstation' then isnull(IDT.CSTPayable,0)
					else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end) 
		from InvoiceAbstract IA, InvoiceDetail IDt, Customer C
		where Idt.InvoiceID = IA.InvoiceID
			and (IA.Status & 32) = 0 
			and IDt.Product_Code = ICode
			and IA.InvoiceType = 4 
			and IDt.SalePrice <> 0
			and IA.InvoiceDate between @FromDate and @ToDate
			and [Tax %] = (case @Locality
				when 'Local' then (select top 1 IDt.TaxCode from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and convert(nvarchar,TaxCode) = [Tax %])
				when 'Outstation' then (select top 1 IDt.TaxCode from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and convert(nvarchar,TaxCode2) = [Tax %])
				when '%' then (select top 1 [Tax %] from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and 
									(
										convert(nvarchar,TaxCode) = [Tax %]
										or	convert(nvarchar,TaxCode2) = [Tax %]
									)
						)
				end)
			and IA.CustomerID = C.CustomerID
			and cast(C.Locality as nvarchar) like (case @Locality 
													when 'Local' then '1' 
													when 'Outstation' then '2' 
													else '%' end) + '%'
	)

	--total Sales Return Damages
	update #VATReport set [Sales Return Damages (%c)] = (
		select sum(IDt.Amount) 
		from InvoiceAbstract IA, InvoiceDetail IDt, Customer C
		where Idt.InvoiceID = IA.InvoiceID
			and (IA.Status & 32) <> 0 
			and IDt.Product_Code = ICode
			and IA.InvoiceType = 4 
			and IDt.SalePrice <> 0
			and IA.InvoiceDate between @FromDate and @ToDate
			and [Tax %] = (case @Locality
				when 'Local' then (select top 1 IDt.TaxCode from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and convert(nvarchar,TaxCode) = [Tax %])
				when 'Outstation' then (select top 1 IDt.TaxCode from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and convert(nvarchar,TaxCode2) = [Tax %])
				when '%' then (select top 1 [Tax %] from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and 
									(
										convert(nvarchar,TaxCode) = [Tax %]
										or	convert(nvarchar,TaxCode2) = [Tax %]
									)
						)
				end)
			and IA.CustomerID = C.CustomerID
			and cast(C.Locality as nvarchar) like (case @Locality 
													when 'Local' then '1' 
													when 'Outstation' then '2' 
													else '%' end) + '%'
	)

	--Tax amount on sales return damages
	update #VATReport set [Tax on Sales Return Damages (%c)] = (
		select sum(case @Locality 
					when 'Local' then isnull(IDt.STPayable,0)
					when 'Outstation' then isnull(IDT.CSTPayable,0)
					else isnull(IDt.STPayable,0) + isnull(IDT.CSTPayable,0) end) 
		from InvoiceAbstract IA, InvoiceDetail IDt, Customer C
		where Idt.InvoiceID = IA.InvoiceID
			and (IA.Status & 32) <> 0 
			and IDt.Product_Code = ICode
			and IA.InvoiceType = 4 
			and IDt.SalePrice <> 0
			and IA.InvoiceDate between @FromDate and @ToDate
			and [Tax %] = (case @Locality
				when 'Local' then (select top 1 IDt.TaxCode from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and convert(nvarchar,TaxCode) = [Tax %])
				when 'Outstation' then (select top 1 IDt.TaxCode from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and convert(nvarchar,TaxCode2) = [Tax %])
				when '%' then (select top 1 [Tax %] from InvoiceDetail IDT1
									where IDt1.InvoiceID = IDt.InvoiceID
									and IDt1.Product_Code = IDt.Product_Code
									and 
									(
										convert(nvarchar,TaxCode) = [Tax %]
										or	convert(nvarchar,TaxCode2) = [Tax %]
									)
						)
				end)
			and IA.CustomerID = C.CustomerID
			and cast(C.Locality as nvarchar) like (case @Locality 
													when 'Local' then '1' 
													when 'Outstation' then '2' 
													else '%' end) + '%'
	)

	update #VATReport set [Net Sales Return (%c)] = isnull([Sales Return Saleable (%c)],0) + isnull([Sales Return Damages (%c)],0)
	update #VATReport set [Net Tax on Sales Return (%c)] = isnull([Tax on Sales Return Saleable (%c)],0) + isnull([Tax on Sales Return Damages (%c)],0)
	update #VATReport set [Net Sales (%c)] = isnull([Total Sales (%c)],0) - isnull([Net Sales Return (%c)],0)
	update #VATReport set [Net Tax on Sales (%c)] = isnull([Tax on Sales (%c)],0) - isnull([Net Tax on Sales Return (%c)],0)
	update #VATReport set [Net VAT Payable (%c)] = isnull([Net Tax on Sales (%c)],0) - isnull([Net Purchase Tax (%c)],0)

	Update #VATReport set [Total Purchase (%c)] = (case [Total Purchase (%c)] when 0 then null else [Total Purchase (%c)] end)
	Update #VATReport set [Tax on Purchase (%c)] = (case [Tax on Purchase (%c)] when 0 then null else [Tax on Purchase (%c)] end)
	Update #VATReport set [Total Purchase Return (%c)] = (case [Total Purchase Return (%c)] when 0 then null else [Total Purchase Return (%c)] end)
	Update #VATReport set [Tax on Purchase Return (%c)] = (case [Tax on Purchase Return (%c)] when 0 then null else [Tax on Purchase Return (%c)] end)
	Update #VATReport set [Net Purchase (%c)] = (case [Net Purchase (%c)] when 0 then null else [Net Purchase (%c)] end)
	Update #VATReport set [Net Purchase Tax (%c)] = (case [Net Purchase Tax (%c)] when 0 then null else [Net Purchase Tax (%c)] end)
	Update #VATReport set [Total Sales (%c)] = (case [Total Sales (%c)] when 0 then null else [Total Sales (%c)] end)
	Update #VATReport set [Tax on Sales (%c)] = (case [Tax on Sales (%c)] when 0 then null else [Tax on Sales (%c)] end)
	Update #VATReport set [Sales Return Saleable (%c)] = (case [Sales Return Saleable (%c)] when 0 then null else [Sales Return Saleable (%c)] end)
	Update #VATReport set [Tax on Sales Return Saleable (%c)] = (case [Tax on Sales Return Saleable (%c)] when 0 then null else [Tax on Sales Return Saleable (%c)] end)
	Update #VATReport set [Sales Return Damages (%c)] = (case [Sales Return Damages (%c)] when 0 then null else [Sales Return Damages (%c)] end)
	Update #VATReport set [Tax on Sales Return Damages (%c)] = (case [Tax on Sales Return Damages (%c)] when 0 then null else [Tax on Sales Return Damages (%c)] end)
	Update #VATReport set [Net Sales Return (%c)] = (case [Net Sales Return (%c)] when 0 then null else [Net Sales Return (%c)] end)
	Update #VATReport set [Net Tax on Sales Return (%c)] = (case [Net Tax on Sales Return (%c)] when 0 then null else [Net Tax on Sales Return (%c)] end)
	Update #VATReport set [Net Sales (%c)] = (case [Net Sales (%c)] when 0 then null else [Net Sales (%c)] end)
	Update #VATReport set [Net Tax on Sales (%c)] = (case [Net Tax on Sales (%c)] when 0 then null else [Net Tax on Sales (%c)] end)
	Update #VATReport set [Net VAT Payable (%c)] = (case [Net VAT Payable (%c)] when 0 then null else [Net VAT Payable (%c)] end)

select * from #VATReport
drop table #VATReport


end
drop table #tmpProd
drop table #tmpProdName



