
CREATE Procedure sp_SaveCG_ITC  (
				 @SalesmanID  int, 
				 @CGID  int,
				 @AG int)  
As  

If @AG = 2 
Begin
	Delete From DSHandle Where SalesmanID = @SalesmanID
End
if not exists (select * from DSHandle where Salesmanid=@SalesmanID and GroupId=@CGID and active=1)
Insert Into DSHandle (SalesmanID, GroupID, Active) 
Values (@SalesmanID, @CGID, 1)


