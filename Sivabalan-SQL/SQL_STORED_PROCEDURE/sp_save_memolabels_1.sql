
CREATE PROC sp_save_memolabels_1(@MEMOLABEL1 nvarchar(255),
			       @MEMOLABEL2 nvarchar(255),
			       @MEMOLABEL3 nvarchar(255))
AS
UPDATE setup SET MemoLabel4 = @MEMOLABEL1, MemoLabel5 = @MEMOLABEL2, MemoLabel6 = @MEMOLABEL3

