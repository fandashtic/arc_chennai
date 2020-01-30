CREATE PROCEDURE [dbo].[SP_GST_PTR_UPDATE_Backup]    
as
BEGIN 
     
     IF EXISTS(  SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Batch_Products_GST_Backup]'))
     BEGIN
             
            DROP TABLE Batch_Products_GST_Backup
     
     END
     
     SELECT * INTO Batch_Products_GST_Backup
     from Batch_Products
    

END
