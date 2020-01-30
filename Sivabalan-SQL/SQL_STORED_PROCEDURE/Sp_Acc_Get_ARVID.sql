CREATE Procedure Sp_Acc_Get_ARVID (@ARVId Int,@DocReference nVarchar(510))
as
If isnull(@ARVID,0) <> 0 and ltrim(rtrim(isnull(@DocReference,N''))) <> N''
Begin
	Select Top 1 DocumentID from ARVAbstract
	Where dbo.GetTrueVal(ARVId) =  @ARVId
	and isnull(DocRef,N'') = @DocReference
	and ((IsNull(Status,0) & 128 = 0) Or (IsNull(Status,0) & 64 = 64))
	order by DocumentID Desc
End
Else if isnull(@ARVID,0) <> 0 and ltrim(rtrim(isnull(@DocReference,N''))) = N''
Begin
	Select Top 1 DocumentID from ARVAbstract
	Where dbo.GetTrueVal(ARVId) =  @ARVId
	and ((IsNull(Status,0) & 128 = 0) Or (IsNull(Status,0) & 64 = 64))
	order by DocumentID Desc
End
Else if isnull(@ARVID,0) = 0 and ltrim(rtrim(isnull(@DocReference,N''))) <> N''
Begin
	Select Top 1 DocumentID from ARVAbstract
	Where isnull(DocRef,N'') = @DocReference
	and ((IsNull(Status,0) & 128 = 0) Or (IsNull(Status,0) & 64 = 64))
	order by DocumentID Desc
End


