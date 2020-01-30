CREATE Function [dbo].[fn_GetTaxValueByComponent](    
@tax_code int,    
@taxcomponent_code int)   
--@Grossvalue decimal(18,6))    
Returns Decimal(18,6)    
As    
Begin 
--declare @tax_code as int
--declare @taxcomponent_code as int
--set @tax_code = 15
--set @taxcomponent_code = 2


DECLARE @tax as table(Tax_code int,	Taxcomponent_code int,	TaxComponent_desc nvarchar(255),	Tax_percentage decimal(18,6),	ComponentType int)
insert into @tax
select distinct t.tax_code,d.taxcomponent_code ,td.TaxComponent_desc,d.Tax_percentage,  
d.ComponentType  from tax t
join taxcomponents d with (nolock) on t.tax_code = d.tax_code and t.tax_code = @tax_code
join TaxComponentDetail td with (nolock) on td.taxcomponent_code = d.taxcomponent_code   
order by   t.tax_code,d.taxcomponent_code asc

--select * from @tax

Declare @Percentage as decimal(18,6)
select @Percentage = isnull(Tax_percentage,0) from @tax where Taxcomponent_code = @taxcomponent_code
--select @Percentage

Return isnull(@Percentage    ,0)
End

