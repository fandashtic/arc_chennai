Create Procedure sp_Get_SchemeItemPerc_SR(@Invoiceid int)
As
/*
select Product_Code,MultipleSchemeDetails,MultipleSplCategorySchDetail,* from invoicedetail 
where invoiceid=24205 and flagword=0 and 
(Isnull(MultipleschemeDetails,'')<>'' or isnull(MultipleSplCategorySchDetail,'')<>'' )
select * from tbl_merp_schemesale where invoiceid=24205
*/

Declare @PrimaryItem table (Product_code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SchDet nVarchar(4000),SplSchDet nVarchar(4000),Serial Int)
Declare @FreeItem table (Product_code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SchDet nVarchar(4000),SplSchDet nVarchar(4000),Serial Int,FreeSerial nvarchar(255),SplCatSerial nVarchar(255),SchValue decimal(18,6),SchValueWithTax decimal(18,6))
Declare @ItemBase table (Product_code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SaleValue decimal(18,6),SchemeId Int,SlabId Int,SchemeAmount Decimal(18,6),SchemePerc Decimal(18,6) default 0,SchemePercWithTax Decimal(18,6) default 0,SplCat int)
Declare @Items table (Product_code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SchemePerc decimal(18,6) default 0,SchemePercWithTax decimal(18,6) default 0,MultiSchDet nvarchar(4000) default '',MultiSplSchDet nvarchar(4000) default '' )
Declare @Product_Code nVarchar(255) 
Declare @SchDet nvarchar(4000)
Declare @SplSchDet nvarchar(4000)
Declare @Serial Int
Declare @tmpProduct_Code nVarchar(255)
Declare @tmpSchemeID Int
Declare @tmpSlabID Int
Declare @tmpSchemeValue decimal(18,6)
Declare @tmpSchemeValueWithTax decimal(18,6)
Declare @tmpSchemeSaleValue decimal(18,6)
Declare @FreeSerial nVarchar(255)
Declare @SplCatSerial nVarchar(255)
Declare @SchemePerc decimal(18,6)
Declare @SchemePercWithTax decimal(18,6)
Declare @SplCat Int
Declare @Locality Int
select @Locality=isNull(Locality,1) from customer C,InvoiceAbstract IA WHERE IA.InvoiceId=@InvoiceId
and IA.CustomerID=C.CustomerID
--Amount & % free includes spl.cat.schemes
--Insert Primary Items into a temp table
Insert into @PrimaryItem 
select Product_Code,MultipleSchemeDetails,MultipleSplCategorySchDetail,Serial from invoicedetail where invoiceid=@InvoiceId
and flagword=0 and 
(Isnull(MultipleschemeDetails,'')<>'' or isnull(MultipleSplCategorySchDetail,'')<>'' )


DECLARE Crsr CURSOR FOR  
select Product_code,SchDet,SplSchDet,Serial from @PrimaryItem 
OPEN Crsr  
FETCH NEXT FROM Crsr into @Product_Code,@SchDet,@SplSchDet,@Serial
WHILE (@@FETCH_STATUS <> -1)  
Begin
	if len(@SchDet) > 0
		Insert into @ItemBase (Product_Code,SchemeId,SlabId,SchemeAmount,SchemePerc,SchemePercWithTax,SplCat)
		select @Product_code,SchemeId,SlabId,SchemeAmount,SchemePerc,SchemePerc,0 from dbo.merp_fn_SplitIn2Cols_Sch(@SchDet,'|') 
	if len(@SplSchDet) > 0
		Insert into @ItemBase (Product_Code,SchemeId,SlabId,SchemeAmount,SchemePerc,SchemePercWithTax,SplCat)
		select @Product_code,SchemeId,SlabId,SchemeAmount,SchemePerc,SchemePerc,1 from dbo.merp_fn_SplitIn2Cols_Sch(@SplSchDet,'|') 
	
	FETCH NEXT FROM Crsr into @Product_Code,@SchDet,@SplSchDet,@Serial
End
Close CrSr
Deallocate CrSr

Delete from @PrimaryItem
--Item Free Schemes
Insert into @FreeItem 
select Product_Code,MultipleSchemeDetails,MultipleSplCategorySchDetail,Serial,FreeSerial,SplCatSerial,(Quantity * PTR ) SchValue,(Quantity * PTR + (Quantity * PTR * ((case when @Locality =1 then isnull(TaxCode,0)/100 else isnull(TaxCode2,0)/100 end )))) SchValueWithTax from invoicedetail where invoiceid=@InvoiceId
and flagword=1 and (isnull(freeserial,'') <> '' or isnull(SplCatserial,'') <> '') and 
(Isnull(MultipleschemeDetails,'')<>'' or isnull(MultipleSplCategorySchDetail,'')<>'' )
Order by Serial


DECLARE Crsr CURSOR FOR  
select Product_code,SchDet,SplSchDet,Serial,FreeSerial,SplCatSerial,SchValue,SchValueWithTax from @FreeItem 
OPEN Crsr  
FETCH NEXT FROM Crsr into @Product_Code,@SchDet,@SplSchDet,@Serial,@FreeSerial,@SplCatSerial,@tmpSchemeValue,@tmpSchemeValueWithTax
WHILE (@@FETCH_STATUS <> -1)  
Begin
	--Item free schemes
	if len(@SchDet) > 0
	Begin
		--Select schemeId and Slab id from MultipleSchemeDetails 
		--Since it is free item it will always hold the single scheme details not multi		
		select @tmpSchemeID=SchemeID,@tmpSlabID=SlabID from dbo.merp_fn_SplitIn2Cols_Sch(@SchDet,'|') 
		--Getting SchemeValue from free row
		--Select @tmpSchemeValue = sum(Quantity * PTR) from Invoicedetail where InvoiceID = @InvoiceID and Serial = @Serial			
		--select @tmpSchemeValue = 1 where isNull(@tmpSchemeValue,0) = 0
		--Getting SchemeSaleValue from the Primary Row
		Select @tmpSchemeSaleValue = Sum(Quantity * SalePrice) from InvoiceDetail where InvoiceId=@InvoiceID
		and Serial in (select ItemValue from dbo.fn_SplitIn2Rows_Int(@FreeSerial,','))		
		--Inserting Primary Item details
		Insert into @ItemBase(Product_code,SchemeID,SlabID,SchemePerc,SchemePercWithTax,SplCat) 
		select Product_Code,@tmpSchemeId ,@tmpSlabID ,
              (Case sum(SalePrice) When 0 Then 0 else ((@tmpSchemeValue/sum(quantity * SalePrice))* 100.) end) SchemePerc,
              (Case sum(SalePrice) When 0 Then 0 else ((@tmpSchemeValueWithTax/sum(quantity * SalePrice)) * 100.) end) SchemePercWithTax,0 
        from InvoiceDetail where InvoiceId=@InvoiceID 
		and Serial in  (select ItemValue from dbo.fn_SplitIn2Rows_Int(@FreeSerial,',')) and
		isNull(@tmpSchemeValue,0) > 0
		group by Product_code
	End
	--Spl. Category Free Item Schemes
	if len(@SplSchDet) > 0
	Begin
		--Select schemeId and Slab id from MultipleSchemeDetails 
		--Since it is free item it will always hold the single scheme details not multi		
		select @tmpSchemeID=SchemeID,@tmpSlabID=SlabID from dbo.merp_fn_SplitIn2Cols_Sch(@SplSchDet,'|') 
		--Getting SchemeValue from free row
		--Select @tmpSchemeValue = sum(Quantity * PTR) from Invoicedetail where InvoiceID = @InvoiceID and Serial = @Serial			
		--select @tmpSchemeValue = 1 where isNull(@tmpSchemeValue,0) = 0
		--Getting SchemeSaleValue from the Primary Row
		Select @tmpSchemeSaleValue = Sum(Quantity * SalePrice) from InvoiceDetail where InvoiceId=@InvoiceID
		and Serial in (select ItemValue from dbo.fn_SplitIn2Rows_Int(@SplCatSerial,','))		
		--Inserting Primary Item details
		Insert into @ItemBase(Product_code,SchemeID,SlabID,SchemePerc,SchemePercWithTax,SplCat) 
		select Product_Code,@tmpSchemeId ,@tmpSlabID ,
              (Case @tmpSchemeSaleValue when 0 Then 0 Else ((@tmpSchemeValue/@tmpSchemeSaleValue) * 100.) end) SchemePerc,
              (Case @tmpSchemeSaleValue when 0 Then 0 Else ((@tmpSchemeValueWithTax/@tmpSchemeSaleValue) * 100.) end) SchemePercWithTax,1 
        from InvoiceDetail where InvoiceId=@InvoiceID 
		and Serial in  (select ItemValue from dbo.fn_SplitIn2Rows_Int(@SplCatSerial,','))
		group by Product_code


	End


--	if len(@SplSchDet) > 0
--		Insert into @ItemBase (Product_Code,SchemeId,SlabId,SchemeAmount,SchemePerc)
--		select @Product_code,* from dbo.merp_fn_SplitIn2Cols_Sch(@SplSchDet,'|') 
	
	FETCH NEXT FROM Crsr into @Product_Code,@SchDet,@SplSchDet,@Serial,@FreeSerial,@SplCatSerial,@tmpSchemeValue, @tmpSchemeValueWithTax

End
Close CrSr
Deallocate CrSr




--Getting Product wise group Percentage
Insert into @Items (Product_Code,SchemePerc,SchemePercWithTax)
Select Final.Product_code,Sum(Final.SchemePerc) SchemePerc,Sum(Final.SchemePercWithTax) SchemePercWithTax from 
(select distinct Product_code,SchemeId,SchemePerc,SchemePercWithTax from @ItemBase ) Final
Group By Final.Product_code


--Update Product and SchemeWise percentage
DECLARE Crsr CURSOR FOR  
select Distinct Product_code  from @Items
OPEN Crsr  
FETCH NEXT FROM Crsr into @Product_Code
WHILE (@@FETCH_STATUS <> -1)  
Begin
	select @SchDet = '',@SplSchDet=''
	--To Get Scheme details	
	Declare Crsr_Prd Cursor For	
	select distinct Product_code,SchemeId,SchemePerc,SchemePercWithTax,SplCat from @ItemBase where Product_Code=@Product_Code  
	Open Crsr_Prd
	FETCH NEXT FROM Crsr_Prd into @tmpProduct_code,@tmpSchemeId,@SchemePerc,@SchemePercWithTax,@SplCat
	WHILE (@@FETCH_STATUS <> -1)  
	Begin
		--Update Items set MultiSchDet = MultiSchDet + @SchemeId + '|0|0|' + @SchemePerc + '|' where Product_code=@Product_code
		if @SplCat = 0
			select @SchDet = @SchDet + cast(@tmpSchemeId as nvarchar) + '|0|0|' + cast(@SchemePercWithTax as nVarchar)+ char(15)
		else
			select @SplSchDet = @SplSchDet + Cast(@tmpSchemeId as nVarchar)+ '|0|0|' + Cast(@SchemePercWithTax as nVarchar) + char(15)

	FETCH NEXT FROM Crsr_Prd into @tmpProduct_Code,@tmpSchemeId,@SchemePerc,@SchemePercWithTax,@SplCat
	End
	Close Crsr_Prd
	Deallocate Crsr_Prd
	If len(@SchDet) > 0 
		update @Items set MultiSchDet = substring( @SchDet,0,len(@SchDet)) where Product_code=@Product_Code
	If len(@SplSchDet) > 0
		update @Items set MultiSplSchDet = substring( @SplSchDet,0,len(@SplSchDet)) where Product_code=@Product_Code			
	--To Get Special Scheme details	
	--select distinct Product_code,SchemeId,SchemePerc from @ItemBase where Product_Code=@Product_Code and SplCat = 1

	
	FETCH NEXT FROM Crsr into @Product_Code
End
Close CrSr
Deallocate CrSr

Select Product_code, SchemePerc, MultiSchDet, MultiSPlSchDet  from @Items
--select distinct Product_code,SchemeId,SchemePerc from @ItemBase 


