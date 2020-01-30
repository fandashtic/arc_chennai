Create Procedure Merp_SP_getOCG_salesman (@SManID nvarchar(50))
AS
BEGIN
	If (Select isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup')=1
	Begin
	Select Distinct GroupName from ProductCategoryGroupAbstract  
        where GroupID In 
		(Select GroupID from tbl_mERP_DSTypeCGMapping Where DSTypeID in 
		(Select DSTypeID From DSType_Details Where SalesmanID = @SManID)And Active = 1) 
		And Active=1
		And isnull(OCGType,0)=1
	End
	Else
	Begin
		Select 'GR1'
		Union
		Select 'GR2'
		Union
		Select 'GR3'
	End
END
