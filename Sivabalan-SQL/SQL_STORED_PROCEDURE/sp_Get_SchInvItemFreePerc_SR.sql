CREATE Procedure sp_Get_SchInvItemFreePerc_SR(@InvoiceID as integer)  
as  
Declare @SchemeId Int
Declare @SlabId Int
Declare @SchemePerc decimal(18,6)
Declare @SchemePercWithTax decimal(18,6)
Declare @SchVal decimal(18,6)
Declare @SchValWithTax decimal(18,6)
Declare @SchSalVal decimal(18,6)
Declare @Items table (SchemeId Int default 0,SlabId Int default 0,SchemeAmount decimal(18,6) default 0,SchemePerc decimal(18,6) default 0,SchemePercWithTax decimal(18,6) default 0 )
Declare @MultiSchDet nvarchar(4000) 
Declare @Locality Int
select @Locality=isNull(Locality,1) from customer C,InvoiceAbstract IA WHERE IA.InvoiceId=@InvoiceId
and IA.CustomerID=C.CustomerID

select @MultiSchDet=multipleschemedetails from InvoiceAbstract where InvoiceId=@InvoiceID
If len(@MultiSchDet) = 0 
	goto EOP
select @SchSalVal = Sum(isnull(Quantity,0) * isnull(SalePrice,0)) from Invoicedetail where Invoiceid =@invoiceid and flagword=0
--Splitting Scheme details into the temp table
Insert into @Items (SchemeId,SlabId,SchemeAmount,SchemePerc,SchemePercWithTax)
select SchemeId,SlabId,SchemeAmount,SchemePerc,SchemePerc from dbo.merp_fn_SplitIn2Cols_Sch(@MultiSchDet,'|')
select @MultiSchDet = ''
--To convert Item free value into percentage and to concat
Declare CrSr Cursor For
Select SchemeId,SlabId,SchemePerc,SchemePercWithTax  from @Items  order by schemeId --where SchemePerc =0
Open CrSr
FETCH NEXT from CrSr into @SchemeId ,@SlabId ,@SchemePerc,@SchemePercWithTax
WHILE ((@@FETCH_STATUS <> -1 ))
BEGIN
	
	--Select @SchVal = Sum(isnull(Quantity,0) * isnull(PTR,0) + (isnull(Quantity,0) * isnull(PTR,0) * (case when @Locality =1 then isnull(TaxCode,0)/100 else isnull(TaxCode2,0)/100 end )) ) 
	Select @SchVal = Sum(isnull(Quantity,0) * isnull(PTR,0) ),
	@SchValWithTax = Sum(isnull(Quantity,0) * isnull(PTR,0) + (isnull(Quantity,0) * isnull(PTR,0) * (case when @Locality =1 then isnull(TaxCode,0)/100 else isnull(TaxCode2,0)/100 end )) ) 	
	from InvoiceDetail where invoiceid = @Invoiceid
	and SchemeID=@Schemeid and FreeSerial = 0 
	if @SchemePerc = 0
	Begin
		set @SchemePerc = (@SchVal/@SchSalVal ) * 100.
		set @SchemePercWithTax = (@SchValWithTax/@SchSalVal ) * 100.
		Update @Items set SchemePerc = @SchemePerc	where SchemeId=@SchemeId and SlabId=@SlabId and SchemePerc =0
	End

	set @MultiSchDet = 	@MultiSchDet + cast(@SchemeId as nvarchar) + '|'+ cast(@SlabId as nvarchar) + '|0|'+ cast(@SchemePercWithTax as nvarchar) + char(15)

FETCH NEXT from CrSr into @SchemeId ,@SlabId ,@SchemePerc,@SchemePercWithTax 
END
Close CrSr
Deallocate CrSr
if len(@MultiSchDet) > 0
	set @MultiSchDet = substring( @MultiSchDet ,0,len(@MultiSchDet ))
EOP:
Select Sum(isnull(SchemePerc,0)) SchemePerc,@MultiSchDet MultiSchDet from @Items 



SET QUOTED_IDENTIFIER OFF 
