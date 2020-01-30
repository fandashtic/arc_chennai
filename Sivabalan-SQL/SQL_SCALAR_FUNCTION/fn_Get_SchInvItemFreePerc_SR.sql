CREATE Function dbo.fn_Get_SchInvItemFreePerc_SR(@SRInvoiceID as integer,@ParamSchemeID as integer)  
returns nvarchar(4000)
as  
Begin
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
Declare @TaxConfigFlag Int
Declare @InvoiceId Int
Declare @SaleValue decimal(18,6)
Declare @RefNum as nVarchar(255)

Select @RefNum = isnull(ReferenceNumber,'') from InvoiceAbstract where invoicetype=4 and Invoiceid = @SRInvoiceID 

If isnumeric(@RefNum) = 0
	Set @InvoiceID = ( Select Top 1 InvoiceId from InvoiceAbstract where Status & 128 = 0 and  DocumentId= ( select top 1 cast(ISnull(REVERSE(left(reverse(ReferenceNumber),PATINDEX(N'%[^0-9]%',Reverse(ReferenceNumber))-1)),0) as Integer) from InvoiceAbstract where invoicetype=4 and Invoiceid = @SRInvoiceID  and isnull(referencenumber,'') <> '' and isnumeric(referencenumber) = 0)) 
Else
	Set @InvoiceID = ( Select Top 1 InvoiceId from InvoiceAbstract where Status & 128 = 0 and DocumentId =  (Select ReferenceNumber from InvoiceAbstract where invoicetype=4 and Invoiceid = @SRInvoiceID and isnull(referencenumber,'') <> ''  )) 

select @Locality=isNull(Locality,1) from customer C,InvoiceAbstract IA WHERE IA.InvoiceId=@InvoiceId
and IA.CustomerID=C.CustomerID
Select @TaxConfigFlag = IsNull(Flag, 0) From tbl_merp_ConfigAbstract Where ScreenCode = 'RFA01'

select @MultiSchDet=multipleschemedetails from InvoiceAbstract where InvoiceId=@InvoiceID
If len(@MultiSchDet) = 0 
	goto EOP
If (Select Count(*) from dbo.merp_fn_SplitIn2Cols_Sch(@MultiSchDet,'|') Where SchemeID = @ParamSchemeID) = 0
	goto EOP


select @SchSalVal = Sum(isnull(Quantity,0) * isnull(SalePrice,0)) from Invoicedetail where Invoiceid =@invoiceid and flagword=0
select @SaleValue = Sum(Quantity * SalePrice) from InvoiceDetail where InvoiceId =@SRInvoiceId group by InvoiceID
--Splitting Scheme details into the temp table
Insert into @Items (SchemeId,SlabId,SchemeAmount,SchemePerc,SchemePercWithTax)
select SchemeId,SlabId,SchemeAmount,SchemePerc,SchemePerc from dbo.merp_fn_SplitIn2Cols_Sch(@MultiSchDet,'|')
select @MultiSchDet = ''
--To convert Item free value into percentage and to concat
Declare CrSr Cursor For
Select SchemeId,SlabId,SchemePerc,SchemePercWithTax  from @Items  where schemeid =@ParamSchemeID--order by schemeId --where SchemePerc =0
Open CrSr
FETCH NEXT from CrSr into @SchemeId ,@SlabId ,@SchemePerc,@SchemePercWithTax
WHILE ((@@FETCH_STATUS <> -1 ))
BEGIN
	
	--Select @SchVal = Sum(isnull(Quantity,0) * isnull(PTR,0) + (isnull(Quantity,0) * isnull(PTR,0) * (case when @Locality =1 then isnull(TaxCode,0)/100 else isnull(TaxCode2,0)/100 end )) ) 
	Select @SchVal = Sum(isnull(Quantity,0) * isnull(dbo.mERP_fn_GetMarginPTR(Product_code,InvoiceID,@Schemeid),0) ),
	@SchValWithTax = Sum(isnull(Quantity,0) * isnull(dbo.mERP_fn_GetMarginPTR(Product_code,InvoiceID,@Schemeid),0) + (isnull(Quantity,0) * isnull(dbo.mERP_fn_GetMarginPTR(Product_code,InvoiceID,@Schemeid),0) * (case when @Locality =1 then isnull(TaxCode,0)/100 else isnull(TaxCode2,0)/100 end )) ) 	
	from InvoiceDetail where invoiceid = @Invoiceid
	and SchemeID=@Schemeid and FreeSerial = 0 
	
	if @SchemePerc = 0
	Begin
		set @SchemePerc = (@SchVal/@SchSalVal ) * 100.
		set @SchemePercWithTax = (@SchValWithTax/@SchSalVal ) * 100.
		--Update @Items set SchemePerc = @SchemePerc	where SchemeId=@SchemeId and SlabId=@SlabId and SchemePerc =0
	End
	if (@TaxConfigFlag=1)
		set @MultiSchDet = 	@MultiSchDet + cast(@SchemeId as nvarchar) + '|'+ cast(@SlabId as nvarchar) + '|'+ cast((@SaleValue * (@SchemePercWithTax/100.)) as nVarchar) +'|'+ cast(@SchemePercWithTax as nvarchar) + char(15)
	else
		set @MultiSchDet = 	@MultiSchDet + cast(@SchemeId as nvarchar) + '|'+ cast(@SlabId as nvarchar) + '|'+ cast((@SaleValue * (@SchemePerc/100.)) as nVarchar) +'|'+ cast(@SchemePerc as nvarchar) + char(15)

FETCH NEXT from CrSr into @SchemeId ,@SlabId ,@SchemePerc,@SchemePercWithTax 
END
Close CrSr
Deallocate CrSr
if len(@MultiSchDet) > 0
	set @MultiSchDet = substring( @MultiSchDet ,0,len(@MultiSchDet ))
EOP:
--Select Sum(isnull(SchemePerc,0)) SchemePerc,@MultiSchDet MultiSchDet from @Items 

Return (@MultiSchDet)
End
