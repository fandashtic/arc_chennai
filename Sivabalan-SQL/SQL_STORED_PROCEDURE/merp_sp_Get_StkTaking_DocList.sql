Create Procedure merp_sp_Get_StkTaking_DocList(@FromDate DateTime, @ToDate DateTime, @DocSerialFrom Int = 0, @DocSerialTo Int = 0, @Option int = 1)  
As  
Begin  
  Declare @VoucherPrefix nvarchar(255)  
  Select @VoucherPrefix = Prefix from VoucherPrefix where TranID = 'PHYSICAL STOCK RECONCILIATION'  
  If @Option = 1 
    Begin
    SELECT ReconcileId, @VoucherPrefix + Cast(IsNull(DocID,0) as nVarchar(10)), IsNull(Description,''),
    Convert(nVarchar(10), CreationDate, 103), Case IsNull(DamageStock,0) When 0 Then 'Saleable' Else 'Damage' End
    FROM ReconcileAbstract Where /*IsNull(Status,0) = 0 and */ dbo.StripTimeFromDate(CreationDate) Between @FromDate and @ToDate And IsNull(DocID,0) > 0
    ORDER BY 1 
    End
  Else if @Option = 2 
    Begin
    SELECT ReconcileId, @VoucherPrefix + Cast(IsNull(DocID,0) as nVarchar(10)), IsNull(Description,''),
    Convert(nVarchar(10), CreationDate, 103), Case IsNull(DamageStock,0) When 0 Then 'Saleable' Else 'Damage' End 
    FROM ReconcileAbstract Where /*IsNull(Status,0) = 0 and */ IsNull(DocID,0) >= @DocSerialFrom and IsNull(DocID,0) <= @DocSerialTo And IsNull(DocID,0) > 0
    ORDER BY 1
    End 
End
