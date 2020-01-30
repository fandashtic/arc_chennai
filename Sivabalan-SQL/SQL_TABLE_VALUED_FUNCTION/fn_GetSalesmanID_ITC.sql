CREATE Function fn_GetSalesmanID_ITC(@GroupNames nvarchar(4000), @ParamDelimiter Char(1) = ',')    
Returns @SalesmanID Table (SalesmanID Int)    
As    
Begin    

Declare @Delimiter as Char(1)        

IF CHARINDEX(@ParamDelimiter , @GroupNames,1) > 0 
Begin
	Set @Delimiter = @ParamDelimiter  
End
Else
Begin
	Set @Delimiter = Char(15) 
End

If @GroupNames = N'%%'  or @GroupNames = N'%'  
Begin  
     Insert into @SalesmanID  
     Select Distinct SalesmanID From Salesman
End    
Else    
Begin  
	Insert into @SalesmanID  
	Select Distinct SalesManID From DSType_Details
	Where DSTypeID In (
	Select DSTypeID From tbl_mERP_DSTypeCGMapping
	Where GroupID In (Select GroupID From ProductCategoryGroupAbstract
	Where GroupName In (Select * from dbo.sp_SplitIn2Rows(@GroupNames,@Delimiter))
	))
End    
  
Return    
End    

