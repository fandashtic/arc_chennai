
Create Procedure dbo.[FSU_sp_getUpdatePath](
@ReleaseID Int
)
As
 
select LocalFilePath +''+FullFileName as Filename from tblUpdatedetail where ReleaseID = @ReleaseID
