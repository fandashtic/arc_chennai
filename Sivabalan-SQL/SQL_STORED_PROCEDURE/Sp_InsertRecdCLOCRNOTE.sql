Create Procedure Sp_InsertRecdCLOCRNOTE(@RecdDocID Int,@CustomerID nvarchar(15),@CLOType nvarchar(15),@CLOMonth nvarchar(8),@Amount decimal(18,6),@RefNumber nvarchar(50),@Active int,@Category nvarchar(256) = NULL, @PrintFlag int = 0)
As
Begin
Set DateFormat DMY
Insert Into Recd_CLOCrNote(RecdDocID,CustomerID,CLOType,CLOMonth,Amount,RefNumber,Active,CLODate,Category,PrintFlag)
Select @RecdDocID,@CustomerID,@CLOType,@CLOMonth,@Amount,@RefNumber,@Active,dbo.fn_ReturnDateforPeriod(@CLOMonth),isnull(@Category,''),@PrintFlag
End
