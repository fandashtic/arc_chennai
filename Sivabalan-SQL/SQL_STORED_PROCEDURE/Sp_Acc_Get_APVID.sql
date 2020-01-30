CREATE Procedure Sp_Acc_Get_APVID (@APVId Int,@DocReference nVarchar(510))
as
If isnull(@APVId,0) <> 0 and ltrim(rtrim(isnull(@DocReference,N''))) <> N''
Begin
	Select Top 1 DocumentID from APVAbstract
	Where dbo.GetTrueVal(APVId) =  @APVId
	and isnull(Documentreference,N'') = @DocReference
	and ((IsNull(Status,0) & 128 = 0) Or (IsNull(Status,0) & 64 = 64))
	order by DocumentID Desc
End
Else if isnull(@APVId,0) <> 0 and ltrim(rtrim(isnull(@DocReference,N''))) = N''
Begin
	Select Top 1 DocumentID from APVAbstract
	Where dbo.GetTrueVal(APVId) =  @APVId
	and ((IsNull(Status,0) & 128 = 0) Or (IsNull(Status,0) & 64 = 64))
	order by DocumentID Desc
End
Else if isnull(@APVId,0) = 0 and ltrim(rtrim(isnull(@DocReference,N''))) <> N''
Begin
	Select Top 1 DocumentID from APVAbstract
	Where isnull(Documentreference,N'') = @DocReference
	and ((IsNull(Status,0) & 128 = 0) Or (IsNull(Status,0) & 64 = 64))
	order by DocumentID Desc
End


