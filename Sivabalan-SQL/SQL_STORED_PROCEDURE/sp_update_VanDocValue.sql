CREATE procedure sp_update_VanDocValue
@ToVan int,@TranValue decimal(18,6)
as
update vanstatementabstract set DocumentValue = DocumentValue + @TranValue where DocSerial=@ToVan



