
Create Procedure dbo.FSU_sp_UpdateTblFSUSetup(@nFlag Int)
As 
Begin
    Declare @FromDate nVarchar(20)
    Declare @nCount int
    select @nCount = Count(*) from dbo.tblFSUSetup
    If @nCount = 0 
    begin
        Insert into [dbo].[tblFSUSetUp] (FromDate, ToDate, LastSyncDate) values (Null, Null, Null)
    End
    If @nFlag = 1 
    Begin
        Select @FromDate = IsNull(FromDate,'NULL') from dbo.tblFSUSetup
        If @FromDate = 'NULL'
        Begin
            Update dbo.tblFSUSetup set FromDate = Getdate()
        End
        Update dbo.tblFSUSetup set ToDate = Getdate()
    End
    Else If @nFlag = 2
    Begin
        Update dbo.tblFSUSetup set LastSyncDate = Getdate()
    End
    Else If @nFlag = 3
    Begin
        Update dbo.tblFSUSetup set FromDate = Null, ToDate = Null
    End
End
