CREATE Procedure mERP_sp_Update_XMLSplitup (@ReportID int,@Splitup int)
AS
-- This Stored Procedure is use to update or insert into XMLSplitup table
Declare @RepName nVarchar(128)
IF Exists (Select ReportName from XMLSplitup Where ReportDataID = @ReportID)
 Begin
  Update XMLSplitup Set Splitup = @Splitup , ModifyDate = getdate()
  Where ReportDataID = @ReportID
 End
Else
 Begin
  Select @RepName = Max(ReportName) From Reports_To_Upload where ReportDataID = @ReportID
  Insert Into XMLSplitup (ReportDataID, ReportName, Splitup)
  Values (@ReportID,@RepName,@Splitup)
 End
