Create Procedure mERP_sp_InsertRecdLPCodeMap(@RecdID int, @Period nVarchar(30), @ProductScope nVarchar(510), @ProductCode  nVarchar(510), @ProductLevel Int,@ProgramType Nvarchar(255))
As
Begin
	Insert into LP_RecdCodeMap(RecdID, Period, ProductScope, ProductCode, ProductLevel,Program_Type) 
	values (@RecdID, @Period, @ProductScope, @ProductCode, @ProductLevel,@ProgramType)
End
