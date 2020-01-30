CREATE Procedure Sp_Acc_Get_CollectionID (@Fulldocid Int,@DocReference nVarchar(510))
as
If isnull(@Fulldocid,0) <> 0 and ltrim(rtrim(isnull(@DocReference,N''))) <> N''
Begin
	Select DocumentID from Collections 
	Where dbo.GetTrueVal(Collections.FullDocID) =  @Fulldocid
	and isnull(DocReference,N'') = @DocReference
	and (isnull(others,0) <> 0 or isnull(ExpenseAccount,0) <> 0)
	and ((IsNull(Status,0) & 128 = 0) Or (IsNull(Status,0) & 64 = 64))
End
Else if isnull(@Fulldocid,0) <> 0 and ltrim(rtrim(isnull(@DocReference,N''))) =N''
Begin
	Select DocumentID from Collections 
	Where dbo.GetTrueVal(Collections.FullDocID) =  @Fulldocid
	and (isnull(others,0) <> 0 or isnull(ExpenseAccount,0) <> 0)
	and ((IsNull(Status,0) & 128 = 0) Or (IsNull(Status,0) & 64 = 64))
End
Else if isnull(@Fulldocid,0) = 0 and ltrim(rtrim(isnull(@DocReference,N''))) <> N''
Begin
	Select DocumentID from Collections 
	Where isnull(DocReference,N'') = @DocReference
	and (isnull(others,0) <> 0 or isnull(ExpenseAccount,0) <> 0)
	and ((IsNull(Status,0) & 128 = 0) Or (IsNull(Status,0) & 64 = 64))
End


