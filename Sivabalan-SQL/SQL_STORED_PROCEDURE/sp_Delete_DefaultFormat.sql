Create Procedure sp_Delete_DefaultFormat (@PrintID Int)
As
Delete CustomPrinting Where PrintID = @PrintID
