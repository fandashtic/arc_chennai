CREATE Function fn_GetCatActDescription_ITC(@GroupNames nvarchar(4000),
											@ParamDelimiter Char(1) = ',', 
											@RFAppl nVarchar(5))    
Returns @CatID Table (Activitycode nVarchar(4000))    
As    
Begin    
  
Declare @CategoryID int      
Declare @Delimiter as Char(1)        

IF CHARINDEX(@ParamDelimiter , @GroupNames,1) > 0 
Begin
	Set @Delimiter = @ParamDelimiter  
End
Else
Begin
	Set @Delimiter = Char(15) 
End
  

declare @tmpActDesc Table(Description NVarChar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)  
    
if @GroupNames = N'%%'  or @GroupNames = N'%'  
Begin  
     Insert into @tmpActDesc   
     select ActivityCode From tbl_merp_SchemeAbstract 
	 Where SchemeType = 3 And IsNull(RFAApplicable, 0) = Case @RFAppl When 'Yes' Then 1 Else 0 End 
End    
Else    
Begin  
     Insert into @tmpActDesc   
     select ActivityCode From tbl_merp_SchemeAbstract 
     Where ActivityCode in    
        (Select * from dbo.sp_SplitIn2Rows(@GroupNames,@Delimiter))    
End    
  
  
Insert @CatID   
select Description from  @tmpActDesc 
--where HierarchyID In (Select HierarchyID From @tempItemhierarchy)    
  
Return    
 End    
  


