CREATE PROCEDURE [dbo].[spr_VanwiseSalesReport] (@FromDATE DATETIME,@ToDATE DATETIME,@DocType nvarchar(100),@PaymentType Nvarchar(255))                
	As 
		Begin
			Set DateFormat DMY
			Declare @SQL as Nvarchar(4000)			Declare @TempVar as Nvarchar(4000)

						CREATE TABLE #Term(
							Id Int,
							[Type] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
						)

						CREATE TABLE #Temp(
							Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
							Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
							GrossAmount decimal(18, 6) NULL,
							Discount decimal(18, 6) NULL,
							SCP decimal(18, 6) NULL,
							SalesTaxValue decimal(18, 6) NOT NULL,
							Total decimal(18, 6) NULL,
							PaymentMode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
							Van nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
						)

						CREATE TABLE #Tempsales(
							Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
							Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
							GrossAmount decimal(18, 6) NULL,
							Discount decimal(18, 6) NULL,
							SalesTaxValue decimal(18, 6) NOT NULL,
							Total decimal(18, 6) NULL,
							PaymentMode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
							Van nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
						)

						CREATE TABLE #TempFinel
						(	Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,

							GrossAmount decimal(18, 6) NULL,
							Discount decimal(18, 6) NULL,
							SalesTaxValue decimal(18, 6) NOT NULL,
							Total decimal(18, 6) NULL,
							PaymentMode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
							Van nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
						)

					If @PaymentType = N'%'
						Begin
								Insert into #Term Select Distinct Mode,Value From Paymentterm
						End					Else
						Begin
								Insert into #Term 
								Select Distinct Mode,Value From Paymentterm Where value Like @PaymentType
						End

						Insert Into #Temp   
						SELECT distinct InvoiceDetail.Product_Code,
						"Category" = Brand.BrandName,  
						(InvoiceDetail.SalePrice * Items.ReportingUnit)*(SUM( InvoiceDetail.Quantity / Items.ReportingUnit)),  

						Sum(IsNull(InvoiceDetail.SCHEMEDISCAMOUNT, 0) + IsNull(InvoiceDetail.SPLCATDISCAMOUNT, 0)),  

						Sum(IsNull(InvoiceDetail.DiscountValue, 0) - (IsNull(InvoiceDetail.SCHEMEDISCAMOUNT, 0) +   IsNull(InvoiceDetail.SPLCATDISCAMOUNT, 0))),  

						Isnull(Sum(InvoiceDetail.STPayable + InvoiceDetail.CSTPayable), 0) ,   

						Round(SUM(InvoiceDetail.Amount),2),

						InvoiceAbstract.PaymentMode,InvoiceAbstract.DocSerialType 

						FROM InvoiceDetail,Items ,Brand   , InvoiceAbstract

						WHERE InvoiceDetail.Product_Code = Items.Product_Code And  
						InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID And
						dbo.stripTimeFromdate(InvoiceAbstract.InvoiceDate) in (@FromDATE) And  -- @ToDATE And
--						DAY(InvoiceAbstract.InvoiceDate) = dAY(@FromDATE) AND Month(InvoiceAbstract.InvoiceDate) = Month(@FromDATE) and Year(InvoiceAbstract.InvoiceDate) = Year(@FromDATE) and
--						DAY(InvoiceAbstract.InvoiceDate) = dAY(@ToDATE) AND Month(InvoiceAbstract.InvoiceDate) = Month(@ToDATE) and Year(InvoiceAbstract.InvoiceDate) = Year(@ToDATE) and
						(InvoiceAbstract.PaymentMode in (select Distinct Id From #Term)) And
						(InvoiceAbstract.Status & 128) = 0 AND  
						InvoiceAbstract.InvoiceType in (1,3) AND  
						Items.BrandID = Brand.BrandID And
--						InvoiceAbstract.DocSerialType like @DocType   And          
						Isnull(InvoiceAbstract.DocSerialType ,'') <> ''  
						GROUP BY Brand.BrandName,InvoiceDetail.Product_Code, Items.ProductName,InvoiceDetail.SalePrice,Items.ReportingUnit,InvoiceDetail.SalePrice  ,InvoiceAbstract.PaymentMode,InvoiceAbstract.DocSerialType 
						order by Brand.BrandName  

						Insert into #Tempsales
						select Distinct CateGory,Product_Code,Sum(GrossAmount),Sum(Discount + SCP), Sum(SalesTaxValue),Sum(Total),PaymentMode,Van from #temp Where VAn like @DocType Group by Category,Product_Code,PaymentMode,Van

						Insert into #TempFinel  
						select CateGory,Sum(GrossAmount),Sum(Discount), Sum(SalesTaxValue),Sum(Total),PaymentMode,Van from #Tempsales Where VAn like @DocType Group by Category,PaymentMode,Van

						Set @SQL = ''
						Set @TempVar = ' Decimal (18,6) Default 0'
						Set @SQL = 'Create Table TempOut (Category Nvarchar(255)'
						
						Declare @Van as Nvarchar(255)
						Declare @clu Cursor 
						Set @clu = Cursor for
						Select Distinct Van from #TempFinel
						Open @clu
						Fetch Next from @clu into @Van
						While @@fetch_status =0
								Begin
									set @SQL = @SQL  + ','
									Set @SQL = @SQL + ('[' + @Van + ']'  + @TempVar)
									Fetch Next from @clu into @Van
								End
						Close @clu
						Deallocate @clu
					set @SQL = @SQL  + ',[GrandTotal] Decimal (18,6))'

					Execute(@SQL)

						Insert into TempOut (CateGory) select Distinct CateGory From #TempFinel


						Declare @NewVan as Nvarchar(255)
						Declare @cluUpdate Cursor 
						Set @cluUpdate = Cursor for
						Select Distinct Van from #TempFinel
						Open @cluUpdate
						Fetch Next from @cluUpdate into @NewVan
						While @@fetch_status =0
							Begin
								set @SQL = 'Update T set T.[' + @NewVan + '] = T1.Total From TempOut T, #TempFinel T1 Where T.Category = T1.Category and T1.Van =''' + @NewVan + ''''
								Execute(@SQL)
								Fetch Next from @cluUpdate into @NewVan
							End
						Close 

@cluUpdate
						Deallocate @cluUpdate


						Declare @NewTotalVan as Nvarchar(255)
						Declare @Var1 as Nvarchar(255)
						Declare @Var2 as Nvarchar(255)

						Set @Var1 = 'Update T set T.GrandTotal = t1.Total From TempOut T, (select Category, ( ' 

						Set @SQL = ''

						Declare @cluTotal Cursor 
						Set @cluTotal = Cursor for
						Select Distinct Van from #TempFinel
						Open @cluTotal
						Fetch Next from @cluTotal into @NewTotalVan
						While @@fetch_status =0
							Begin
								If Isnull(@SQl,'') <> ''
									Begin
										Set @SQL = @SQL + ' + '
									End
								set @SQL = @SQL + '(Cast([' + @NewTotalVan + '] as Decimal (18,6)))'
								Fetch Next from @cluTotal into @NewTotalVan
							End
						Close @cluTotal
						Deallocate @cluTotal
						Set @Var2 = ' ) Total From TempOut) T1 Where T.Category = T1.Category'
						Set @SQL = @Var1 + @SQL + @Var2

						Execute(@SQL)

						select 1, * from TempOut
						Drop table #Term
						Drop table #temp
						Drop table #Tempsales
						Drop table #TempFinel
						Drop table TempOut

END
