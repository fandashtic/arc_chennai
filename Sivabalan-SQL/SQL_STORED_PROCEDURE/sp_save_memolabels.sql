
CREATE PROC sp_save_memolabels(@MEMOLABEL1 nvarchar(255),
			       @MEMOLABEL2 nvarchar(255),
			       @MEMOLABEL3 nvarchar(255))
AS
UPDATE setup SET MemoLabel1 = @MEMOLABEL1, MemoLabel2 = @MEMOLABEL2, MemoLabel3 = @MEMOLABEL3

