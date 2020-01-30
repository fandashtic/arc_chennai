Create Procedure mERP_sp_validate_DSTraining_SalesmanDSTypeMap(@SalesmanID Int, @DSTypeID int)
as
Begin
	IF Not Exists(Select SalesmanID from Salesman Where SalesmanID = @SalesmanID and Active = 1)
    Begin
       Select -998
       Goto ExitDo
    End
    IF Not Exists(Select * from DSType_Details Where SalesmanId = @SalesmanID and DSTypeID = @DSTypeID)
    Begin
       Select -999
       Goto ExitDo
    End
	Select 1 
ExitDo:    
End
