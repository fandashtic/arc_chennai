Create Procedure SP_Get_HHStatus 
AS   
BEGIN
	Set Dateformat DMY
	Select I.SalesmanID,S.Salesman_Name, case When isnull(I.Status,0)=0 Then 'New' When isnull(I.Status,0)=1 Then 'Running' When isnull(I.Status,0)=2 Then 'Completed' End  as [Status]
	from 	Inbound_Status I,Salesman S
	Where I.SalesmanID=S.SalesmanID
	And dbo.StripDateFromTime(ISNULL(I.CreationDate,GETDATE()))=dbo.StripDateFromTime(GETDATE())
	/* ITC UAT Point - only currently processing status should be shown in HHSync Screen */
	And isnull(I.Status,0)=1
	Order by S.Salesman_Name
END
