CREATE PROCEDURE mERP_sp_get_GRNAbs(@GRNID INT)
AS
-- Get grndate to load
-- in future we add some more req columns
Select GRNDate From GRNAbstract Where GRNID = @GRNID
