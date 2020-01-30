CREATE Function Fn_GetSalesmanName(@DSType nvarchar(4000))    
Returns @SalesmanID Table (SalesmanID Int)    
As    
Begin    
	Declare @ParamDelimiter as Nvarchar(1)
	Set @ParamDelimiter = ','

	Declare @Delimiter as Char(1)        

	IF CHARINDEX(@ParamDelimiter , @DSType,1) > 0 
	Begin
		Set @Delimiter = @ParamDelimiter  
	End
	Else
	Begin
		Set @Delimiter = Char(15) 
	End

	If @DSType = N'%%'  or @DSType = N'%'  
	Begin  
		 Insert into @SalesmanID  
		 Select Distinct SalesmanID From Dstype_Details
	End    
	Else    
	Begin  
		Insert into @SalesmanID  
		Select Distinct Salesmanid from dstype_Details Where DSTypeId in 
		(select Distinct DSTypeID From DSType_Master Where DSTypeValue in((Select * from dbo.sp_SplitIn2Rows(@DSType,@Delimiter))))
	End     
	Return    
End    
