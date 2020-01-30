Create procedure spr_get_StockAgeingSummary  
           (@StockType nvarchar(10),  
            @StockStatus nVarchar(50),
		    @ItemCode  nVarChar(2550)	
		    )  
As
begin  
Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    

create table #tmpProd(product_code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @ItemCode = '%'  
	Insert InTo #tmpProd Select Product_code From Items  
Else  
	Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ItemCode, @Delimeter)  
  
declare @Query nvarchar(4000)
declare @QueryOne nvarchar(4000)
declare @QueryTwo nvarchar(4000)

set @QueryOne = ''
set @QueryTwo = ''

If @StockType = N'%'
	Set @StockType = N'ALL STOCK'



If @StockStatus = '%'  
Begin
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
  
----------------------------
----------------------------

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
  
------------------------------------
	set @QueryOne = @QueryOne + ',   
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
		set @QueryOne = @QueryOne + ' -   
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



	set @QueryOne = @QueryOne + ',   
	"> 1Year" = isnull((  
    select sum(Quantity)   
    from Batch_Products BP  
    where   
    BP.Product_Code = It.Product_Code   
    and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) > 365  
	),0)'  
 
	if @StockType <> 'ALL STOCK'  
	begin  
		set @QueryOne = @QueryOne + ' -   
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
  
	set @QueryOne = @QueryOne + ' from Items It   
                    Where It.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)  
					Group by IT.Product_Code, It.ProductName'
end  
Else
Begin
	set @QueryOne = 'select Distinct It.Product_Code, "SKU Code" = It.Product_Code, "Item" = It.ProductName,'  
	set @QueryOne = @QueryOne + '  
	"0-30" = isnull((  
	select sum(Quantity)   
	from Batch_Products BP  
	where   
    BP.Product_Code = It.Product_Code   
    and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate())   
    between 0 and 31  Group by BP.Product_Code HAVING Sum(BP.Quantity) > 0
	),0)'  

	
	if @StockType <> 'ALL STOCK'  
	begin  
		set @QueryOne = @QueryOne + ' -   
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
		) Group by BP.Product_Code HAVING Sum(BP.Quantity) > 0   
		),0)'  
	end  
  
	set @QueryOne = @QueryOne + ',   
	"31-60" = isnull((  
    select sum(Quantity)   
    from Batch_Products BP  
    where   
    BP.Product_Code = It.Product_Code   
    and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate())   
    between 31 and 60  Group by BP.Product_Code HAVING Sum(BP.Quantity) > 0
	),0)'  
	
	if @StockType <> 'ALL STOCK'  
	begin  
		set @QueryOne = @QueryOne + ' -   
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
		)Group by BP.Product_Code HAVING Sum(BP.Quantity) > 0 
		),0)'  
	end  
  
	set @QueryOne = @QueryOne + ',   
	"61-90" = isnull((  
	select sum(Quantity)   
	from Batch_Products BP  
    where   
    BP.Product_Code = It.Product_Code   
    and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate())   
    between 61 and 90  Group by BP.Product_Code HAVING Sum(BP.Quantity) > 0 
	),0)'  

	if @StockType <> 'ALL STOCK'  
	begin  
		set @QueryOne = @QueryOne + ' -   
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
		)  Group by BP.Product_Code HAVING Sum(BP.Quantity) > 0 
		),0)'  
	end  
  
	set @QueryOne = @QueryOne + ',   
	"91-120" = isnull((  
    select sum(Quantity)   
    from Batch_Products BP  
    where   
    BP.Product_Code = It.Product_Code   
    and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) between 91 and 120 Group by BP.Product_Code HAVING Sum(BP.Quantity) > 0   
	),0)'  

	if @StockType <> 'ALL STOCK'  
	begin  
		set @QueryOne = @QueryOne + ' -   
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
		)  Group by BP.Product_Code HAVING Sum(BP.Quantity) > 0 
		),0)'  
	end  
  
	set @QueryOne = @QueryOne + ',   
	"121-150" = isnull((  
    select sum(Quantity)   
    from Batch_Products BP  
    where   
    BP.Product_Code = It.Product_Code   
    and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate())   
    between 121 and 150  Group by BP.Product_Code HAVING Sum(BP.Quantity) > 0 
    ),0)'  

	if @StockType <> 'ALL STOCK'  
	begin  
		set @QueryOne = @QueryOne + ' -   
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
		) Group by BP.Product_Code HAVING Sum(BP.Quantity) > 0  
		),0)'  
	end  
  
	set @QueryTwo = @QueryTwo + ',   
	"151-180" = isnull((  
    select sum(Quantity)   
    from Batch_Products BP  
    where   
    BP.Product_Code = It.Product_Code   
    and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate())   
    between 151 and 180  Group by BP.Product_Code HAVING Sum(BP.Quantity) > 0 
    ),0)'  


	if @StockType <> 'ALL STOCK'  
	begin  
		set @QueryTwo = @QueryTwo + ' -   
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
		)  Group by BP.Product_Code HAVING Sum(BP.Quantity) > 0 
		),0)'  
	end  
  
	set @QueryTwo = @QueryTwo + ',   
	"181-1Year" = isnull((  
    select sum(Quantity)   
    from Batch_Products BP  
    where   
    BP.Product_Code = It.Product_Code   
    and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate())   
    between 181 and 365  Group by BP.Product_Code HAVING Sum(BP.Quantity) > 0 
    ),0)'  


	if @StockType <> 'ALL STOCK'  
	begin  
		set @QueryTwo = @QueryTwo + ' -   
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
		) Group by BP.Product_Code HAVING Sum(BP.Quantity) > 0   
		),0)'  
	end  
  
	set @QueryTwo = @QueryTwo + ',   
	"> 1Year" = isnull((  
    select sum(Quantity)   
    from Batch_Products BP  
    where   
    BP.Product_Code = It.Product_Code   
    and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) > 365  Group by BP.Product_Code HAVING Sum(BP.Quantity) > 0 
	),0)'  

	if @StockType <> 'ALL STOCK'  
	begin  
		set @QueryTwo = @QueryTwo + ' -   
		isnull((  
		select sum(BP.Quantity)   
		from Batch_Products BP  
		where BP.Product_Code = It.Product_Code   
		and datediff(dd, isnull(BP.Pkd, Bp.CreationDate), Getdate()) > 365  
		and (  
		isnull(BP.Damage,0) <> 0 or        
		DBO.StripDateFromTime(isnull(BP.Expiry,getdate()+1))   
		<= DBO.StripDateFromTime(Getdate())  
		)  Group by BP.Product_Code HAVING Sum(BP.Quantity) > 0 
		),0)'  
	end  
  
	set @QueryTwo = @QueryTwo + ' from Items It,Batch_products  
                    Where It.Product_Code in (Select product_code COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpProd)
					and IT.Product_Code = Batch_products.Product_Code  
					Group by IT.Product_Code, It.ProductName HAVING Sum(Batch_products.Quantity) > 0 
					ORDER BY It.Product_Code '  

End

if IsNull(@Query, N'') = N''
Begin
	set @Query = N''
End

if IsNull(@QueryOne, N'') = N''
Begin
	set @QueryOne = N''
End

if IsNull(@QueryTwo, N'') = N''
Begin
	set @QueryTwo = N''
End

	exec(@Query + @QueryOne + @QueryTwo)   
end  

