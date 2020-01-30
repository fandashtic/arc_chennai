CREATE procedure SP_TaxCompDetail (@TaxCode as integer,@flag as integer) 
As 
select tax_percentage from taxComponents where lst_flag=@flag and tax_code =@TaxCode  
