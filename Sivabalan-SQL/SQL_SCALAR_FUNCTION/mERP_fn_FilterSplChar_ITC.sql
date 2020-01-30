CREATE Function mERP_fn_FilterSplChar_ITC(@CharToFilter nVarchar(4000))    
Returns nVarchar(4000)
As    
Begin    

Set @CharToFilter = Replace(Replace(@CharToFilter, """", ""), "'", "''")
Return @CharToFilter

End
