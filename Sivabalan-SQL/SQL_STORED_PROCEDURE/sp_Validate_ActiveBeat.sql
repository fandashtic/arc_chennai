
Create Procedure sp_Validate_ActiveBeat
(
	@frm int,	-- 1->Dispatch, 2->Invoice
	@TranID int = 0
)  
As  
Begin  
Declare @Active as int

If @frm = 1
Begin
		Select @Active=Active From Beat Where BeatID=(Select IsNull(BeatID,0) From DispatchAbstract Where DispatchID=@TranID)  
End
If @frm = 2
Begin
		Select @Active=Active From Beat Where BeatID=(Select IsNull(BeatID,0) From InvoiceAbstract Where InvoiceID=@TranID)  
End
Select IsNull(@Active,0)
End  
