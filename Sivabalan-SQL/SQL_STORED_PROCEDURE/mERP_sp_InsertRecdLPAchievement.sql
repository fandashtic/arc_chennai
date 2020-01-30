Create Procedure mERP_sp_InsertRecdLPAchievement(@RecdID Int, @Period nVarchar(10), @TargetFrom DateTime, @TargetTo DateTime, @AchievedTo nVarchar(15),
@CustomerID nVarchar(30), @SequenceNo Int, @ProductScope nVarchar(510), @TargetVal Decimal(18,6), @AchievedVal Decimal(18,6),
@GraceDate DateTime,@ProgramType Nvarchar(255),@Print Nvarchar(25),@Label Nvarchar(25))
As
Begin
	Declare @nPrint Int
	If @Print = 'NULL'
	Begin
		Insert into LP_RecdAchievementDetail(RecdID, Period, TargetFrom, TargetTo, AchievedTo, CustomerID, SequenceNo, ProductScope, TargetVal, AchievedVal, GraceDate,Program_Type,[Print],Label)
		Values (@RecdID, @Period, @TargetFrom, @TargetTo, (Case When IsNull(@AchievedTo,'')='' Then NULL Else @AchievedTo End) , 
		@CustomerID, @SequenceNo, @ProductScope, @TargetVal, @AchievedVal, @GraceDate,@ProgramType,Null,@Label)
	End
	Else
	Begin
		Set @nPrint = Convert(Int,@Print)
		Insert into LP_RecdAchievementDetail(RecdID, Period, TargetFrom, TargetTo, AchievedTo, CustomerID, SequenceNo, ProductScope, TargetVal, AchievedVal, GraceDate,Program_Type,[Print],Label)
		Values (@RecdID, @Period, @TargetFrom, @TargetTo, (Case When IsNull(@AchievedTo,'')='' Then NULL Else @AchievedTo End) , 
		@CustomerID, @SequenceNo, @ProductScope, @TargetVal, @AchievedVal, @GraceDate,@ProgramType,@nPrint,@Label)
	End
End
