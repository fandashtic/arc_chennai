Create Procedure mERP_sp_InsertRecdLPScore(@RecdID int, @Period nVarchar(30),@CustomerID nVarchar(30), @MemberInfo nVarchar(50),
	 @Tier nVarchar(30), @SeqNo int, @Type nVarchar(30), @Particular nVarchar(510), @Description nVarchar(510), @Points Decimal(18,6), @GraceDate DateTime,@ProgramType Nvarchar(255))
As
Begin
	Insert into LP_RecdScoreDetail(RecdID, Period, CustomerID, MembershipNo, Tier, SequenceNo, [Type], Particular, Description, PointsEarned, GraceDate,Program_Type)
	values (@RecdID, @Period ,@CustomerID , @MemberInfo , @Tier , @SeqNo, @Type, @Particular , @Description , @Points, @GraceDate,@ProgramType)
End
