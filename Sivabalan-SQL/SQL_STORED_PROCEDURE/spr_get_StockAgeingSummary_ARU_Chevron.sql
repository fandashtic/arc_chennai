CREATE procedure spr_get_StockAgeingSummary_ARU_Chevron
											(@StockType nvarchar(10),
											 @ItemCode nVarChar(2550))
As
begin
Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @ItemCode = '%'
	Insert InTo #tmpProd Select Product_code From Items
Else
	Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)

Select @StockType = Dbo.LookupDictionaryItem2(@StockType,Default)

declare @Query varchar(8000)
set @Query = 'select Distinct It.Product_Code, "SKU Code" = It.Product_Code, "Item" = It.ProductName,'
set @Query = @Query + '
"0-30" = isnull((
			select sum(Quantity) 
			from Batch_Products BP
			where 
				BP.Product_Code = It.Product_Code 
				and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) 
					between 0 and 31
			),0)'
	if @StockType <> 'ALL STOCK'
	begin
		set @Query = @Query + ' - 
		isnull((
			select sum(BP.Quantity) 
			from Batch_Products BP
			where BP.Product_Code = It.Product_Code 
				and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) 
					between 0 and 31
				and (
						isnull(BP.Damage,0) <> 0 or 					
						DBO.StripDateFromTime(isnull(BP.Expiry,getdate()+1)) 
							<= DBO.StripDateFromTime(Getdate())
					)
		),0)'
	end

set @Query = @Query + ', 
"31-60" = isnull((
				select sum(Quantity) 
				from Batch_Products BP
				where 
					BP.Product_Code = It.Product_Code 
					and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) 
						between 31 and 60
			),0)'
	if @StockType <> 'ALL STOCK'
	begin
		set @Query = @Query + ' - 
		isnull((
			select sum(BP.Quantity) 
			from Batch_Products BP
			where BP.Product_Code = It.Product_Code 
				and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) 
					between 31 and 60
				and (
						isnull(BP.Damage,0) <> 0 or 					
						DBO.StripDateFromTime(isnull(BP.Expiry,getdate()+1)) 
							<= DBO.StripDateFromTime(Getdate())
					)
		),0)'
	end

set @Query = @Query + ', 
"61-90" = isnull((
				select sum(Quantity) 
				from Batch_Products BP
				where 
					BP.Product_Code = It.Product_Code 
					and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) 
						between 61 and 90
			),0)'
	if @StockType <> 'ALL STOCK'
	begin
		set @Query = @Query + ' - 
		isnull((
			select sum(BP.Quantity) 
			from Batch_Products BP
			where BP.Product_Code = It.Product_Code 
				and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) 
					between 61 and 90
				and (
						isnull(BP.Damage,0) <> 0 or 					
						DBO.StripDateFromTime(isnull(BP.Expiry,getdate()+1)) 
							<= DBO.StripDateFromTime(Getdate())
					)
		),0)'
	end

set @Query = @Query + ', 
"91-120" = isnull((
				select sum(Quantity) 
				from Batch_Products BP
				where 
					BP.Product_Code = It.Product_Code 
					and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) between 91 and 120
			),0)'
	if @StockType <> 'ALL STOCK'
	begin
		set @Query = @Query + ' - 
		isnull((
			select sum(BP.Quantity) 
			from Batch_Products BP
			where BP.Product_Code = It.Product_Code 
				and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) 
					between 91 and 120
				and (
						isnull(BP.Damage,0) <> 0 or 					
						DBO.StripDateFromTime(isnull(BP.Expiry,getdate()+1)) 
							<= DBO.StripDateFromTime(Getdate())
					)
		),0)'
	end

set @Query = @Query + ', 
"121-150" = isnull((
				select sum(Quantity) 
				from Batch_Products BP
				where 
					BP.Product_Code = It.Product_Code 
					and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) 
						between 121 and 150
			),0)'
	if @StockType <> 'ALL STOCK'
	begin
		set @Query = @Query + ' - 
		isnull((
			select sum(BP.Quantity) 
			from Batch_Products BP
			where BP.Product_Code = It.Product_Code 
				and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) 
					between 121 and 150
				and (
						isnull(BP.Damage,0) <> 0 or 					
						DBO.StripDateFromTime(isnull(BP.Expiry,getdate()+1)) 
							<= DBO.StripDateFromTime(Getdate())
					)
		),0)'
	end

set @Query = @Query + ', 
"151-180" = isnull((
				select sum(Quantity) 
				from Batch_Products BP
				where 
					BP.Product_Code = It.Product_Code 
					and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) 
						between 151 and 180
			),0)'
	if @StockType <> 'ALL STOCK'
	begin
		set @Query = @Query + ' - 
		isnull((
			select sum(BP.Quantity) 
			from Batch_Products BP
			where BP.Product_Code = It.Product_Code 
				and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) 
					between 151 and 180
				and (
						isnull(BP.Damage,0) <> 0 or 					
						DBO.StripDateFromTime(isnull(BP.Expiry,getdate()+1)) 
							<= DBO.StripDateFromTime(Getdate())
					)
		),0)'
	end

set @Query = @Query + ', 
"181-1Year" = isnull((
				select sum(Quantity) 
				from Batch_Products BP
				where 
					BP.Product_Code = It.Product_Code 
					and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) 
						between 181 and 365
				),0)'
	if @StockType <> 'ALL STOCK'
	begin
		set @Query = @Query + ' - 
		isnull((
			select sum(BP.Quantity) 
			from Batch_Products BP
			where BP.Product_Code = It.Product_Code 
				and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) 
					between 181 and 365
				and (
						isnull(BP.Damage,0) <> 0 or 					
						DBO.StripDateFromTime(isnull(BP.Expiry,getdate()+1)) 
							<= DBO.StripDateFromTime(Getdate())
					)
		),0)'
	end

set @Query = @Query + ', 
"> 1Year" = isnull((
				select sum(Quantity) 
				from Batch_Products BP
				where 
					BP.Product_Code = It.Product_Code 
					and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) > 365
			),0)'
	if @StockType <> 'ALL STOCK'
	begin
		set @Query = @Query + ' - 
		isnull((
			select sum(BP.Quantity) 
			from Batch_Products BP
			where BP.Product_Code = It.Product_Code 
				and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) > 365
				and (
						isnull(BP.Damage,0) <> 0 or 					
						DBO.StripDateFromTime(isnull(BP.Expiry,getdate()+1)) 
							<= DBO.StripDateFromTime(Getdate())
					)
		),0)'
	end

set @Query = @Query + ' from Items It 
                        Where It.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
						Group by IT.Product_Code, It.ProductName'

exec(@Query) 
end





