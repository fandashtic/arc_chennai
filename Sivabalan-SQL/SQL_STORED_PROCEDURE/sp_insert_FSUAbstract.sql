
CREATE PROCEDURE sp_insert_FSUAbstract(@SourcePath NVARCHAR(250),  
    @DestPath NVARCHAR(250))  
AS  
INSERT INTO FSUFileAbstract(SourcePath, DestPath)  
Values  (@SourcePath, @DestPath) 
Select @@Identity
