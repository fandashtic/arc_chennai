IF EXISTS (SELECT name FROM sys.indexes WHERE name = N'IX_Collections_Status') DROP INDEX IX_Collections_Status ON Collections;   
GO  
CREATE NONCLUSTERED INDEX IX_Collections_Status   ON Collections (Status);   
GO  

IF EXISTS (SELECT name FROM sys.indexes WHERE name = N'IX_Collections_DocumentDate') DROP INDEX IX_Collections_DocumentDate ON Collections;   
GO  
CREATE NONCLUSTERED INDEX IX_Collections_DocumentDate ON Collections (DocumentDate);   
GO  
