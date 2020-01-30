Create Function dbo.fn_Get_ItemSchemeDetail_SR(@SRInvoiceid int,@SchemeId int,@ProdCode nVarchar(255),@TaxConfigFlag Int,@ItemSerial Int)
Returns nvarchar(4000) 
As
Begin
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
--Declare @TaxConfigFlag Int
Declare @InvoiceId Int
Declare @tmpSaleValue decimal(18,6)
Declare @ItemGroup int 
Declare @RefNum as nVarchar(255)
Declare @TOQ int
Declare @GSTFlag int

Select @GSTFlag = isnull(GSTFlag,0) From InvoiceAbstract Where InvoiceType = 4 and InvoiceID = @SRInvoiceID 

select @ItemGroup = ItemGroup from tbl_merp_schemeabstract where schemeid = @schemeid

Select @RefNum = isnull(ReferenceNumber,'') from InvoiceAbstract where invoicetype=4 and Invoiceid = @SRInvoiceID 

IF @GSTFlag = 0
Begin
	If isnumeric(@RefNum) = 0
		Set @InvoiceID = ( Select Top 1 InvoiceId from InvoiceAbstract where status & 128 = 0 and  DocumentId= ( select top 1 cast(ISnull(REVERSE(left(reverse(ReferenceNumber),PATINDEX(N'%[^0-9]%',Reverse(ReferenceNumber))-1)),0) as Integer) from InvoiceAbstract where invoicetype=4 and Invoiceid = @SRInvoiceID and isnull(referencenumber,'') <> '' and isnumeric(referencenumber) = 0 ) order by invoiceid desc) 
	Else
		Set @InvoiceID = ( Select Top 1 InvoiceId from InvoiceAbstract where status & 128 = 0 and DocumentId =  (Select ReferenceNumber from InvoiceAbstract where invoicetype=4 and Invoiceid = @SRInvoiceID and isnull(referencenumber,'') <> ''  ) order by invoiceid desc) 
End
Else
	Set @InvoiceID = (Select Top 1 SRInvoiceID From InvoiceAbstract Where InvoiceType = 4 and InvoiceID = @SRInvoiceID)


--Select @TaxConfigFlag = IsNull(Flag, 0) From tbl_merp_ConfigAbstract Where ScreenCode = 'RFA01'
--0 - w/o tax ,1 - with tax


select @Locality=isNull(Locality,1) from customer C,InvoiceAbstract IA WHERE IA.InvoiceId=@Invoiceid
and IA.CustomerID=C.CustomerID
--Amount & % free includes spl.cat.schemes
--Insert Primary Items into a temp table
Insert into @PrimaryItem 
select Product_Code,MultipleSchemeDetails,MultipleSplCategorySchDetail,Serial from invoicedetail where invoiceid=@Invoiceid
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


/* To chk whether the scheme has been applied  in the original invoice */
--If (Select Count(*) From @ItemBase Where SchemeId = @SchemeId) = 0 
--GoTo OverNOut

Delete from @PrimaryItem
--Item Free Schemes
Insert into @FreeItem 
select Product_Code,MultipleSchemeDetails,MultipleSplCategorySchDetail,Serial,FreeSerial,SplCatSerial,(Quantity * dbo.mERP_fn_GetMarginPTR(Product_code,InvoiceID,@Schemeid) ) SchValue,
case when isnull(TaxonQty,0) =0 then
	(Quantity * dbo.mERP_fn_GetMarginPTR(Product_code,InvoiceID,@Schemeid) + 
	(Quantity * dbo.mERP_fn_GetMarginPTR(Product_code,InvoiceID,@Schemeid) * 
	((case when @Locality =1 then isnull(TaxCode,0)/100 else isnull(TaxCode2,0)/100 end ))))  
else
(Quantity * dbo.mERP_fn_GetMarginPTR(Product_code,InvoiceID,@Schemeid) + 
	(Quantity * 
	(case when @Locality =1 then isnull(TaxCode,0) else isnull(TaxCode2,0) end )))
End as SchValueWithTax 
from invoicedetail where invoiceid=@Invoiceid
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
		--Select @tmpSchemeValue = sum(Quantity * PTR) from Invoicedetail where InvoiceID = @Invoiceid and Serial = @Serial			
		--select @tmpSchemeValue = 1 where isNull(@tmpSchemeValue,0) = 0
		--Getting SchemeSaleValue from the Primary Row
		Select @tmpSchemeSaleValue = Sum(Quantity * SalePrice) from InvoiceDetail where InvoiceId=@Invoiceid
		and Serial in (select ItemValue from dbo.fn_SplitIn2Rows_Int(@FreeSerial,','))		
		--Inserting Primary Item details
		Insert into @ItemBase(Product_code,SaleValue,SchemeID,SlabID,SchemePerc,SchemePercWithTax,SplCat) 
		select Product_Code,Sum(Quantity * SalePrice),@tmpSchemeId ,@tmpSlabID , 
              (Case sum(SalePrice) When 0 Then 0 else ((@tmpSchemeValue/sum(quantity * SalePrice))* 100.) end) SchemePerc,
              (Case sum(SalePrice) When 0 Then 0 else ((@tmpSchemeValueWithTax/sum(quantity * SalePrice)) * 100.) end) SchemePercWithTax,0 
        from InvoiceDetail where InvoiceId=@Invoiceid 
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
		--Select @tmpSchemeValue = sum(Quantity * PTR) from Invoicedetail where InvoiceID = @Invoiceid and Serial = @Serial			
		--select @tmpSchemeValue = 1 where isNull(@tmpSchemeValue,0) = 0
		--Getting SchemeSaleValue from the Primary Row
		Select @tmpSchemeSaleValue = Sum(Quantity * SalePrice) from InvoiceDetail where InvoiceId=@Invoiceid
		and Serial in (select ItemValue from dbo.fn_SplitIn2Rows_Int(@SplCatSerial,','))		
		--Inserting Primary Item details
		Insert into @ItemBase(Product_code,SaleValue,SchemeID,SlabID,SchemePerc,SchemePercWithTax,SplCat) 
		select Product_Code,Sum(Quantity * SalePrice),@tmpSchemeId ,@tmpSlabID ,
              (Case @tmpSchemeSaleValue when 0 Then 0 Else ((@tmpSchemeValue/@tmpSchemeSaleValue) * 100.) end) SchemePerc,
              (Case @tmpSchemeSaleValue when 0 Then 0 Else ((@tmpSchemeValueWithTax/@tmpSchemeSaleValue) * 100.) end) SchemePercWithTax,1 
        from InvoiceDetail where InvoiceId=@Invoiceid 
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
(select distinct Product_code,SchemeId,SchemePerc,SchemePercWithTax from @ItemBase where schemeId=@schemeid ) Final
Group By Final.Product_code

set @SchDet = ''
set @SplSchDet=''
--Update Product and SchemeWise percentage
DECLARE Crsr CURSOR FOR  
select Top 1 Product_code  from @Items where Product_code = @ProdCOde
OPEN Crsr  
FETCH NEXT FROM Crsr into @Product_Code
WHILE (@@FETCH_STATUS <> -1)  
Begin
	set @SchDet = ''
	set @SplSchDet=''
	--To Get Scheme details	
	Declare Crsr_Prd Cursor For	
	select distinct Product_code,(select sum(Quantity * Saleprice) from Invoicedetail where product_code= @Product_code and InvoiceID = @SRInvoiceID and Serial = @ItemSerial and (Isnull(MultipleschemeDetails,'')<>'' or isnull(MultipleSplCategorySchDetail,'')<>'' ) ) as SaleValue,SchemeId,SchemePerc,SchemePercWithTax,SplCat from @ItemBase where Product_Code=@Product_Code  and schemeid=@schemeid 
	Open Crsr_Prd
	FETCH NEXT FROM Crsr_Prd into @tmpProduct_code,@tmpSaleValue,@tmpSchemeId,@SchemePerc,@SchemePercWithTax,@SplCat
	WHILE (@@FETCH_STATUS <> -1)  
	Begin
		--Update Items set MultiSchDet = MultiSchDet + @SchemeId + '|0|0|' + @SchemePerc + '|' where Product_code=@Product_code
		if @SplCat = 0
			Begin
				if (@TaxConfigFlag=1)
					select @SchDet = @SchDet + cast(@tmpSchemeId as nvarchar) + '|0|'+ cast(@tmpSaleValue * (@SchemePercWithTax/100.) as nVarchar) + '|' + cast(@SchemePercWithTax as nVarchar) + char(15)
				else
					select @SchDet = @SchDet + cast(@tmpSchemeId as nvarchar) + '|0|'+ cast(@tmpSaleValue * (@SchemePerc/100.) as nVarchar) +'|' + cast(@SchemePerc as nVarchar) + char(15)
			End
		else
			Begin
				if (@TaxConfigFlag=1)
					select @SplSchDet = @SplSchDet + Cast(@tmpSchemeId as nVarchar)+ '|0|'+ cast(@tmpSaleValue * (@SchemePercWithTax/100.) as nVarchar) + '|' + cast(@SchemePercWithTax as nVarchar) + char(15)
				else
					select @SplSchDet = @SplSchDet + Cast(@tmpSchemeId as nVarchar)+ '|0|'+ cast(@tmpSaleValue * (@SchemePerc/100.) as nVarchar) +'|' + cast(@SchemePerc as nVarchar) + char(15)
			End
	FETCH NEXT FROM Crsr_Prd into @tmpProduct_Code,@tmpSaleValue,@tmpSchemeId,@SchemePerc,@SchemePercWithTax,@SplCat
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

OverNOut:
Return (Select (case when @Itemgroup = 1 then MultiSchDet else MultiSPlSchDet end) SchemeDetails from @Items where Product_code = @Prodcode)
--select distinct Product_code,SchemeId,SchemePerc from @ItemBase 

End
