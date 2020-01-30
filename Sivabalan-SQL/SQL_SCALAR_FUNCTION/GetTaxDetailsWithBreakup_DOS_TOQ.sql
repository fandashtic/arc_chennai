CREATE Function [dbo].[GetTaxDetailsWithBreakup_DOS_TOQ] (@InvNo int)        
Returns nvarchar(2000)        
As        
Begin  
  
Declare @Result nvarchar(2000)
Declare @InvNos nvarchar(200)
Declare @AdjDocs Int
Declare @Tax int
Declare @SP_Per nvarchar(10)
Declare @Sale_Value Decimal(18,2)  
Declare @Tax_Amt Decimal(18,2)  
Declare @Total_Tax_Amt Decimal(18,2) 
Declare @Total_Sale_Value Decimal(18,2)  
Declare @Customer_Type int
Declare @SRValue int
Declare @TaxPercentage Decimal(18,3)

Declare @tmpInvTaxComp Table (IDS Int Identity(1, 1), InvoiceID Int, 
Product_Code nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, TaxType Int, Tax_Code Int, 
Tax_Component_Code Int, Tax_Percentage Decimal(18, 6), SP_Percentage Decimal(18, 6), 
Tax_Value Decimal(18, 6))


  Insert Into @tmpInvTaxComp 
  Select InvoiceId, product_code, taxtype, tax_code, tax_component_code, tax_percentage, sp_percentage, 
  	sum( tax_value ) tax_value 
  From invoicetaxcomponents where invoiceid  = @InvNo
  group by InvoiceId, product_code, taxtype, tax_code, tax_component_code, tax_percentage, sp_percentage 


Set @SRValue=-1
Set @InvNos= Cast(@InvNo as nvarchar(10)) + ','




Set @Result = '  |' + Space(10) +'Tax Details   ' + Space(10) + '|;'    
  
Set @Total_Tax_Amt= 0.00 
set @Total_Sale_Value=0.00
Set @Customer_Type=2 
  
Set @Result =  IsNull(@Result, N'') + '|TAX%   |   Sale   |Comp%|  TaxAmt  |' + ';'  


Declare TaxData Cursor Keyset For
select tax_code taxId, convert(Decimal(18, 2), NetSalesValue) NetSalesValue, convert(Decimal(18, 2),TaxSpr) TaxSpr,
    convert(Decimal(18, 2),TaxValue) TaxValue from (
    select taxId tax_code, (sum(Gr_amt)-sum(pr_dsc)-sum(tr_Dsc)) NetSalesValue,
    taxcode TaxSpr, sum(stpayable) TaxValue, taxcode percentage  from ( 
        select Id.serial, Id.taxId, max(taxcode) taxcode, max(stpayable) stpayable, 
        sum(quantity*saleprice) Gr_amt, max(Id.Discountvalue) pr_dsc, 
        ((sum(quantity*saleprice)-max(Id.Discountvalue))*max(Ia.additionaldiscount/100)) tr_Dsc  
        from Invoiceabstract Ia, InvoiceDetail Id 
        where Ia.InvoiceId = Id.InvoiceId and ia.invoiceid IN (Select * From dbo.sp_SplitIn2Rows(@InvNos, N','))
        and taxId Not In (select Tax_Code from Invoicetaxcomponents)
        group by Id.serial, Id.taxId) Id
    group by taxId, taxcode  

    union all 

    select ItComp.Tax_Code, 
    (Case when ItComp.ApplicableOn = 'price' then Idet.NetSalesValue Else ItComp.Tax_Value*100/ItComp.TaxSpr end) NetSalesValue, 
    ItComp.TaxSpr, ItComp.Tax_Value TaxValue, tax.percentage from (
        select Itc.Tax_Code, Itc.Tax_Component_Code, Itc.TaxSpr, sum(Tax_Value) Tax_Value, ApplicableOn from ( 
            select Itc.Product_Code, Itc.Tax_Code, Itc.Tax_Component_Code, max(Itc.Tax_Percentage) TaxSpr, 
            sum(Tax_Value) Tax_Value
            from Invoicetaxcomponents Itc
            where Itc.InvoiceId In (Select * From dbo.sp_SplitIn2Rows(@InvNos, N','))
            group by Itc.Product_Code, Itc.Tax_Code, Itc.Tax_Component_Code) Itc, taxcomponents tc
        where Itc.Tax_Code = tc.Tax_Code and Itc.Tax_Component_Code = tc.TaxComponent_Code and lst_flag = 1 
        group by Itc.Tax_Code, Itc.Tax_Component_Code, Itc.TaxSpr, tc.ApplicableOn ) ItComp , 

        (select sum(Gr_amt)-sum(pr_dsc)-sum(tr_Dsc) NetSalesValue, 
        taxId TaxCode, taxcode TaxSpr, sum(stpayable) TaxValue from ( 
            select Id.serial, Id.taxId, max(taxcode) taxcode, max(stpayable) stpayable, 
            sum(quantity*saleprice) Gr_amt, max(Id.Discountvalue) pr_dsc, 
            ((sum(quantity*saleprice)-max(Id.Discountvalue))*max(Ia.additionaldiscount/100)) tr_Dsc  
            from Invoiceabstract Ia, InvoiceDetail Id 
            where Ia.InvoiceId = Id.InvoiceId and ia.invoiceid In (Select * From dbo.sp_SplitIn2Rows(@InvNos, N','))
            and taxId In (select Tax_Code from Invoicetaxcomponents)
            group by Id.serial, Id.taxId) Id
        group by taxId, taxcode)Idet, tax    
    where ItComp.Tax_Code = tax.Tax_Code and ItComp.Tax_Code = Idet.TaxCode ) rst 
Order By Percentage desc, NetSalesValue Desc

Open TaxData        
Fetch From TaxData into @Tax,@Sale_Value,@SP_Per,@Tax_Amt
While @@Fetch_Status = 0        
Begin        
Set @TaxPercentage=0.00
If @Tax<>0 
Begin
	Set @TaxPercentage=(Select Percentage from Tax where Tax_code=@Tax)
End
Set @Result =  IsNull(@Result, N'') 
		 --+ '|' 
			+ Cast(@TaxPercentage as nvarchar(10)) + Space(8 -Len(Cast(@TaxPercentage as nvarchar(10))))  
         + '|' + Space(10 -len(Cast(@Sale_Value as nvarchar(13)))) + Cast(@Sale_Value as nvarchar(13))  
		 + '|' + Space(5 -Len(Cast(@SP_Per as nvarchar(10)))) + Cast(@SP_Per as nvarchar(10)) 
         + '|' + Space(10 -len(Cast(@Tax_Amt as nvarchar(10)))) + Cast(@Tax_Amt as nvarchar(10))
         + '|;'
  Set @Total_Tax_Amt=@Total_Tax_Amt + @Tax_Amt
  set @Total_Sale_Value=@Total_Sale_Value+@Sale_Value

Fetch Next From TaxData into @Tax,@Sale_Value,@SP_Per,@Tax_Amt
End        
  
Set @Result= @Result + '|Total ' 					 
					 --+ '|' + Space(14 - Len (Cast(@Total_Sale_Value as nvarchar(10)))) + Cast(@Total_Sale_Value as nvarchar(10)) 					 
					 + '|' + Space(27 - Len (Cast(@Total_Tax_Amt as nvarchar(10)))) + Cast(@Total_Tax_Amt as nvarchar(10)) 
					 + '|;'   
--Set @Result= @Result + '|' + REPLICATE('-',35) + '|;'
  
Set @Result = @Result--SubString(@Result, 3, Len(@Result) - 2)  
  
Close TaxData       

Deallocate TaxData    

Return @Result        
End
